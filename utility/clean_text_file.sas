/****************************************************************************
 WAKE COUNTY PROPERTY TAX ANALYSIS               
*****************************************************************************
 CLEAN UNSTRUCTURED TEXT
 Cleans the unstructured text from the PDF file for each.
	- Reads in the specified input TXT file.
	- Creates a final SAS table.
*****************************************************************************
 REQUIREMENTS: 
	- Must run the 
		- workshop/utility/00_utility_macros.sas program prior
	    - 01_download_pdf_files.sas
		- 02_pdf_to_text.sas
		- 03_clean_text_file.sas - Specify input file and final table name.
****************************************************************************/


/* Read the input file */
filename f_in &inputFile;

/* Create the temporary property values wide table */
data work.get_property_values;

	/* Read in the input text file */
	infile f_in truncover;

	/* Read in entire string into a single column */
	input content $2000.;

	/* Set lengths */
	length tax_values_cleaned $200.  
/*            new_first_row_col_values $200. */
;

	/* Create the total number of years column to use to identify if extra values are in the tax rates */
	retain TotalYears &TotalYearColumns
           start_reading_at_row_n 9999; /* <-- dummy start number */

	/* Only read in lines that have text */
	if length(content) > 1;

	/* Remove leading and trailing blanks from content */
	content = strip(content);

	/* Document where the Tax Rates value was found to start reading in values */
	if find(content, 'Tax Rates') > 0 then start_reading_at_row_n = _N_;

	/* Delete the initial rows prior to Tax Rates for houses */
	if _N_ > start_reading_at_row_n;


	/******* 1. Find the taxing unit in the unstructured text *******/

	/* 1a. Search for the first character position going right to left */
	find_first_character = anyalpha(content, -length(content)) + 1;

	/* 1b. Extract the taxing unit county */
	CountyName = substr(content, 1, find_first_character-1);


	/******** 2. Obtain the taxing values by year *******/

	/* 2a. Extract taxing values */
	original_values = strip(substr(content, find_first_character));
	
	/* 2b. Replace blanks with commas */
	original_values = tranwrd(strip(original_values), ' ', ',');

	/* 2c. Count the number of values. 
           This occurs because additional info is in the text at the beginning for some counties */
	num_of_values = countw(original_values,',');

	/* 2d. Loop over values for each county and extract only tax values */
	if totalYears ne num_of_values then do;
		do value_position = 1 to num_of_values;
			find_value = scan(original_values, value_position, ',');
			
			/* If less than 1 then it's a tax value */
			if find_value < 1 then tax_values_cleaned = catx(',',tax_values_cleaned, find_value);
		end;
	end;
	else do;
		tax_values_cleaned = original_values;
	end;

	/* Stop processing after Zebulon when you find an * */
	if substr(strip(content),1,1) = '*' then do;
		stop;
	end;

	/* Keep columns */
	drop start_reading_at_row_n 
		 value_position;
run;

proc print data=get_property_values;
run;




/* Create a table to obtain the year and if it's an appraisal year by searching for '*' */
data appraisal_years;
	set get_property_values(obs=1);
	
	/* Loop over the max year to the min year by 1 year */
	do Year=&MAXYEAR to &MINYEAR by -1;
		counter + 1;
		get_year_value = scan(tax_values_cleaned,counter,',');

		/* If the year contains an * then it was an appraisal year */
		if find(get_year_value,'*') > 0 then AppraisalYear='Yes';
			else AppraisalYear='No';
		
		/* Output row */
		output;
	end;
	keep Year AppraisalYear;
run;
proc print data=appraisal_years;
run;


/* Create narrow table with county/year/property tax */
data wc_property_values;
	set get_property_values(firstobs=2); /* Skip over TAXING UNIT - YEARS row */

	counter = 0;

	/* List contains values starting from the max year and decreasing to the min */
	do Year=&MAXYEAR to &MINYEAR by -1;
		counter + 1;
		PropertyTax = input(scan(tax_values_cleaned,counter,','),best12.);
		output;
	end;

	drop num_of_values find_value counter  original_values;
run;

proc print data=wc_property_values;
run;




/* Create the final table with rates + appraisal years */
proc sql;
	create table &final_table_name as
	select		
		wc.CountyName label='County Name',
		mdy(1,1,wc.Year) as Year format=YEAR4.,
		ay.AppraisalYear label='Appraisal Year',
		wc.PropertyTax label='Property Tax Rate'
	from wc_property_values wc inner join appraisal_years ay
		on wc.Year=ay.Year
	order by wc.CountyName, wc.Year;
quit;

proc print data=&final_table_name label;
run;