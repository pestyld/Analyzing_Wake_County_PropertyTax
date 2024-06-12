/****************************************************************
 Dynamically find the first year and last year in the data
****************************************************************/

%macro get_max_min_years(inputFile);
/*
	Creates the maxYearValue and minYearValue global macro variables to dynamically read in the
    unstructured text files to determine the number of columns to create.

	args:
		inputFile (str) : File name and path of input extracted text file.

	returns:
		- maxYear macro variable - Finds max year.
		- minYear macro variable - Finds min year.
		- TotalYearColumns - maxYear - minYear + 1 for total number of years in data.
*/

	%global maxYear minYear TotalYearColumns;

	/* Input text file */
	filename f_in &inputFile;

	data _null_;
		/* Read in txt file */
		infile f_in truncover;
	
		/* Read entire row as a string into the content column */
		input;
		content = _infile_;
		
		/* Set lengths of new columns */
		length yearValues $500 
			   maxYearValue minYearValue $10;
	
		/* Find the min and max years from the string */
		if find(content, 'TAXING UNIT') > 0 then do;
	
			/* Find the first numeric value in the string */
			findFirstDigit = anydigit(content);   
	
			/* Obtain all numeric year values from the string starting at the position above */                 
			yearValues = strip(substr(content, findFirstDigit));   
			
			/* Find first year, which is the max value, current year */
			maxYearValue = scan(yearValues, 1, ' '); 
	
			/* Find minimum year, last value in the string */              
		    minYearValue = scan(yearValues, -1, ' ');              
	
			/* Create macro variables storing the year info */
			call symputx('maxYear', maxYearValue);                 
			call symputx('minYear', minYearValue);
	
			/* Stop execution */
		    stop;
		end;
	run;

	/*Get the total years in the data */
	data _null_;
		TotalYearsColumns = &maxYear - &minYear + 1;
		call symputx('TotalYearColumns', TotalYearsColumns);
	run;

	%put NOTE: **********************************************;
	%put NOTE: Min and Max Years Found in the Text File: &=maxYear &=minYear;
	%put NOTE: Total Years found in the data: &=TotalYearColumns;
	%put NOTE: **********************************************;
%mend;