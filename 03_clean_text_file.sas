/***************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS   */
/***************************************/

/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio. Otherwise specify your path.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

%put &=path;


/* out file */
/* filename fout "&path/data/out_test.txt"; */
/*  */
/* data _null_; */
/* 	infile f truncover; */
/* 	input content $2000.; */
/* 	file fout; */
/* 	put content; */
/* run; */

/***********************************************/
/* 6. Clean the unstructured text              */
/***********************************************/

filename wc_curr "&path/data/wc_2014-current_tax.txt";

data years;
	infile wc_curr truncover;
	input content $2000. ;
	if find(content, 'TAXING UNIT') > 0 then do;
		yearValues = strip(substr(content, anydigit(content)));
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
proc print data=years;
run;







data colNames;
	infile wc_curr truncover;
	input content $2000. ;
	retain TotalYears &TotalYearColumns;

/* 	FormFieldsData = strip(content); */
/* 	FormFieldsData = tranwrd(content,'09'x,''); /* Remove tabs */
/* 	FormFieldsData = tranwrd(content,'0A'x,''); /* Remove carriage return line feed */

	/* 1. Delete the first four rows that contains random text info */
	if _N_ < 5 then delete;

	/* 2. Remove leading and trailing blanks from content */
	content = strip(content);

	/* 3. Find the taxing unit in the unstructured text */

	/* Search for the first character position going right to left */
	find_first_character = anyalpha(content, -length(content)) + 1;

	county_names = substr(content, 1, find_first_character);

	values = strip(substr(content, find_first_character));
	values = tranwrd(strip(values), ' ', ',');
	num_of_values = countw(values,',');

	if totalYears ne num_of_values then do;
		do value_position=1 to num_of_values;
			find_value = scan(values,value_position,',');
		end;
	end;
	else do;
		values_cleaned = values;
	end;
	if length(content) = 1 then stop;
		else output;

	drop ;
run;
proc print data=colNames;
run;









/***********************************************************/
/* CONNECT TO CAS AND LOAD PDF FILES INTO A CAS TABLE      */
/***********************************************************/
/* loadTable action (has the import option info - https://go.documentation.sas.com/doc/en/pgmsascdc/default/caspg/cas-table-loadtable.htm */
/* PROC CASUTIL - https://go.documentation.sas.com/doc/en/pgmsascdc/default/casref/n03spmi9ixzq5pn11lneipfwyu8b.htm#n1nj5zckmttquen1siwyi8gfsf0q */
/* Create a caslib to the folder with the PDFs in the PDF_files folder */
caslib my_pdfs path="&path./PDF_files" subdirs;