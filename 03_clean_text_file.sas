/***************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS   */
/***************************************/

/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio. Otherwise specify your path.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

%put &=path;


/* Input text file */
/* filename wc_curr "&path/data/wc_2014-current_tax.txt"; */
/* data test; */
/* 	infile wc_curr truncover; */
/* 	input content $2000. ; */


/***********************************************/
/* 6. Clean the unstructured text              */
/***********************************************/

/* Input text file */
filename wc_curr "&path/data/wc_tax_data_raw.txt";

/* a. Dynamically find the first year and last year in the data */
data years;
	infile wc_curr truncover;
	input content $2000. ;
	if find(content, 'TAXING UNIT') > 0 then do;
		findFirstDigit = anydigit(content);
		yearValues = strip(substr(content, findFirstDigit));
		maxYearValue = scan(yearValues, 1, ' ');
	    minYearValue = scan(yearValues, -1, ' ');
		TotalYearsColumns = maxYearValue - minYearValue + 1;
	    output;
		call symputx('maxYear', maxYearValue);
		call symputx('minYear', minYearValue);
		call symputx('TotalYearColumns', TotalYearsColumns);
	  stop;
	end;
run;
%put &=maxYear &=minYear &=TotalYearColumns;



/* b. Clean the unstructured text */

/* Create output CSV file */
filename fout "&path/data/wc_2014-current_rates_clean.csv";

data wake_county_tax_2014_curr;
	/* Read in the input text file */
	infile wc_curr truncover;

	/* Read in entire string into a single column */
	input content $2000.;

	/* Set lengths */
	length values_cleaned_csv $200.  
           new_first_row_col_values $200.;

	/* Create the total number of years column to use to identify if extra values are in the tax rates */
	retain TotalYears &TotalYearColumns;

	/* 1. Delete the first four rows that contains random text info */
	if _N_ < 5 then delete;

	/* 2. Remove leading and trailing blanks from content */
	content = strip(content);

	/******* 3. Find the taxing unit in the unstructured text *******/

	/* 3a. Search for the first character position going right to left */
	find_first_character = anyalpha(content, -length(content)) + 1;

	/* 3b. Extract the taxing unit county */
	county_name = substr(content, 1, find_first_character);

	/******** 4. Obtain the taxing values by year *******/

	/* 4a. Extract taxing values */
	values = strip(substr(content, find_first_character));
	
	/* 4b. Replace blanks with commas */
	values = tranwrd(strip(values), ' ', ',');

	/* 4c. Count the number of values. This occurs because additional info is in the text for some counties */
	num_of_values = countw(values,',');

	/* 4d. Loop over values for each county and extract only tax values */
	if totalYears ne num_of_values then do;
		do value_position = 1 to num_of_values;
			find_value = scan(values, value_position, ',');
			if find_value < 1 then values_cleaned_csv = catx(',',values_cleaned_csv, find_value);
		end;
	end;
	else do;
		values_cleaned_csv = values;
	end;


	/******* 5. Rename first row and add Year<yearnum> for wide csv file *******/
	if upcase(County_name) = 'TAXING UNIT' then do;

		/* 5a. Add underscore to Taxing_Unit */
		County_Name = tranwrd(strip(County_Name),' ','_');

		/* 5b. Add 'Year' prior to the year values to avoid column name issues */
		do value_position = 1 to num_of_values;
			find_value = scan(values, value_position, ',');
			new_value_with_year = cats('Year',find_value);
			new_first_row_col_values = catx(',', new_first_row_col_values, new_value_with_year);
		end;
		values_cleaned_csv = new_first_row_col_values;

	end;

	/* 6. Combine taxing unit county and tax values */
	values_cleaned_csv = catx(',',county_name,values_cleaned_csv);

	/* 7. a. Create output data to a SAS table and text file       */
    /*    b. Stop DATA step when a blank row is encountered        */

	file fout;

	if length(content) > 1 then do;
		output;
		put values_cleaned_csv;
	end;
	else do;
		stop;
	end;

	/* 8. Drop unnecessary columns */
	drop ;
run;

proc print data=wake_county_tax_2014_curr;
run;


/* test import */
proc import datafile='/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/Workshops/Analyzing_Wake_County_PropertyTax/data/out_test.csv'
			dbms=csv
			out=test;
run;