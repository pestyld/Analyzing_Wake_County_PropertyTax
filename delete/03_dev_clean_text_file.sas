/****************************************************************************
 WAKE COUNTY PROPERTY TAX ANALYSIS               
*****************************************************************************
 03 - CLEAN UNSTRUCTURED TEXT
*****************************************************************************
 REQUIREMENTS: 
	- Must run the 
		- workshop/utility/00_utility_macros.sas program prior
	    - 01_download_pdf_files.sas
		- 02_pdf_to_text.sas
****************************************************************************/
%getcwd(path)


/****************************************************************
 1. CLEAN XXX UNSTRUCTURED TEXT
****************************************************************/
%let inputFile="&path/data/wc_tax_data_2014_curr_raw.txt";
%let final_table_name=wc_2014_current;



/* a. Dynamically find the first year and last year in the data */
%get_max_min_years(inputFile="&path/data/wc_tax_data_2014_curr_raw.txt")



filename f_in &inputFile;

data work.get_property_values;

	/* Read in the input text file */
	infile f_in truncover;

	/* Read in entire string into a single column */
	input content $2000.;

	/* Set lengths */
	length tax_values_cleaned $200.  
           new_first_row_col_values $200.;

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
	CountyName = substr(content, 1, find_first_character);


	/******** 2. Obtain the taxing values by year *******/

	/* 2a. Extract taxing values */
	values = strip(substr(content, find_first_character));
	
	/* 2b. Replace blanks with commas */
	values = tranwrd(strip(values), ' ', ',');

	/* 2c. Count the number of values. 
           This occurs because additional info is in the text at the beginning for some counties */
	num_of_values = countw(values,',');

	/* 2d. Loop over values for each county and extract only tax values */
	if totalYears ne num_of_values then do;
		do value_position = 1 to num_of_values;
			find_value = scan(values, value_position, ',');
			/* If less than 1 then it's a tax value */
			if find_value < 1 then tax_values_cleaned = catx(',',tax_values_cleaned, find_value);
		end;
	end;
	else do;
		tax_values_cleaned = values;
	end;

	/* Stop processing after Zebulon when you find an * */
	if substr(strip(content),1,1) = '*' then do;
		stop;
	end;

	/* Keep columns */
	*keep content tax_values_cleaned CountyName	values;
run;
proc print data=get_property_values;
run;


/* Obtain the year and if it's an appraisal year by searching for '*' */
data appraisal_years;
	set get_property_values(obs=1);
	do Year=&MAXYEAR to &MINYEAR by -1;
		counter + 1;
		get_year_value = scan(tax_values_cleaned,counter,',');
		if find(get_year_value,'*') > 0 then AppraisalYear='Yes';
			else AppraisalYear='No';
		output;
	end;
	keep Year AppraisalYear;
run;
proc print data=appraisal_years;
run;


/* Create narrow table with county/year/property tax */
data wc_property_values;
	set get_property_values(firstobs=2);

	counter = 0;

	do Year=&MAXYEAR to &MINYEAR by -1;
		counter + 1;
		PropertyTax = scan(tax_values_cleaned,counter,',');
		output;
	end;

	*keep content CountyName Year PropertyTax;
run;
proc print data=wc_property_values;
run;


/* create final table */
proc sql;
	create table &final_table_name as
	select		
		wc.CountyName label='County Name',
		wc.Year,
		ay.AppraisalYear label='Appraisal Year',
		wc.PropertyTax label='Property Tax Rate'
	from wc_property_values wc inner join appraisal_years ay
		on wc.Year=ay.Year;
quit;
proc print data=&final_table_name label;
run;






























































data wake_county_tax_2014_curr;

	/* Read in the input text file */
	infile f_in truncover;

	/* Read in entire string into a single column */
	input content $2000.;

	/* Set lengths */
	length values_cleaned_csv $200.  
           new_first_row_col_values $200.;

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
	county_name = substr(content, 1, find_first_character);


	/******** 2. Obtain the taxing values by year *******/

	/* 2a. Extract taxing values */
	values = strip(substr(content, find_first_character));
	
	/* 2b. Replace blanks with commas */
	values = tranwrd(strip(values), ' ', ',');

	/* 2c. Count the number of values. This occurs because additional info is in the text for some counties */
	num_of_values = countw(values,',');

	/* 2d. Loop over values for each county and extract only tax values */
	if totalYears ne num_of_values then do;
		do value_position = 1 to num_of_values;
			find_value = scan(values, value_position, ',');
			if find_value < 1 then values_cleaned_csv = catx(',',values_cleaned_csv, find_value);
		end;
	end;
	else do;
		values_cleaned_csv = values;
	end;

	/******* 3. Rename first row and add Year<yearnum> for wide csv file *******/
	if upcase(County_name) = 'TAXING UNIT' then do;

		/* 3a. Add underscore to Taxing_Unit */
		County_Name = tranwrd(strip(County_Name),' ','_');

		/* 3b. Add 'Year' prior to the year values to avoid column name issues */
		do value_position = 1 to num_of_values;
			find_value = scan(values, value_position, ',');
			new_value_with_year = cats('Year',find_value);
			new_first_row_col_values = catx(',', new_first_row_col_values, new_value_with_year);
		end;
		values_cleaned_csv = new_first_row_col_values;

	end;

	/* 4. Combine taxing unit county and tax values */
	values_cleaned_csv = catx(',',county_name,values_cleaned_csv);

	/* 5. a. Create output data to a SAS table and text file       */
    /*    b. Stop DATA step when a blank row is encountered        */
	file f_out;

	if substr(strip(content),1,1) = '*' then do;
		stop;
	end;
	else if length(content) > 1 then do;
		output;
		put values_cleaned_csv;
	end;


	/* 6. Drop unnecessary columns */
/* 	drop ; */
run;



proc print data=wake_county_tax_2014_curr;
run;


/* test import */
proc import datafile=fout
			dbms=csv
			out=test replace;
run;