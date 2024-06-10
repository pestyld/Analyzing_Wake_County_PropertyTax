
%macro find_min_max_years(inputFile);

%global maxYear minYear TotalYearColumns;

data _null_;
	infile &inputFile truncover;
	input content $2000. ;
	if find(content, 'TAXING UNIT') > 0 then do;
		findFirstDigit = anydigit(content);                    /* Find the first numeric value in the string */
		yearValues = strip(substr(content, findFirstDigit));   /* Obtain all year values from the string */
		maxYearValue = scan(yearValues, 1, ' ');               /* Find first year (max value, current year */
	    minYearValue = scan(yearValues, -1, ' ');              /* Find minimum year */
		call symputx('maxYear', maxYearValue);                 /* Create macro variables storing the year info */
		call symputx('minYear', minYearValue);
	   stop;
	end;
run;


data _null_;
	TotalYearsColumns = &maxYear - &minYear + 1;
	call symputx('TotalYearColumns', TotalYearsColumns);
run;

%put NOTE: &=maxYear &=minYear &=TotalYearColumns;

%mend;

%find_min_max_years(f_in)