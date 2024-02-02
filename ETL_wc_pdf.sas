/***************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS   */
/***************************************/

/******************************************/
/* 1. FIND PATH FOR THE PROJECT FOLDER    */
/******************************************/
/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio. Otherwise specify your path.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

%put &=path;



/*****************************************************/
/* 2. DOWNLOAD THE PDF FILEs FROM WAKE COUNTY TO SAS */
/*****************************************************/
/* Can be found here: https://www.wake.gov/departments-government/tax-administration/tax-bill-help/tax-rates-fees                        */
/* a. Current to 2014: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf         */
/* b. 2013 and Prior: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf */


/* a. Download Current Year to 2014 PDf and save to SAS Viya */

/* Link to the PDF file */
%let pdf_curr_to_2014 = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf;

/* Path and name of the PDF file to create */
filename cur_pdf "&path/pdf_files/wc_property_2014-current.pdf";

/* Download PDF file from the internet and save it in SAS */
proc http
 	url="&pdf_curr_to_2014"
 	method="get" 
	out=cur_pdf;
run;



/************************************************/
/* 3. Create Caslib to the folder with the PDFs */
/************************************************/

/* Create a caslib to the PDF files */
caslib pdfs path="&path" subdirs;

/* Confirm the PDF files are available */
proc cas;
	table.fileInfo / 
		path = 'pdf_files', 
		caslib = 'pdfs' 
		allfiles=true;
quit;



/*********************************************/
/* 4. Load the PDF file as a CAS table       */
/*********************************************/
/* Read in all of the PDF files in the caslib as a single CAS table */
/* Each PDF will be one row of data in the CAS table                */
proc casutil;
    load casdata='pdf_files'                    /* To read in all files use an empty string. For a single PDF file specify the name and extension */
         incaslib='pdfs'                        /* The location of the PDF files to load */
         importoptions=(fileType="document",    /* Specify document import options   */
                        fileExtList = 'PDF', 
                        tikaConv=True)           
		 casout='wc_data' outcaslib='casuser'   /* Specify the output cas table info */
         replace;                          
quit;

/* Create a libref to the Caslib to use SAS procs on the CAS table */
libname casuser cas caslib = 'casuser';

proc print data=casuser.wc_data;
run;


/*********************************************/
/* 5. Create a text file from the CAS table  */
/*********************************************/
filename wc_curr "&path/data/wc_2014-current_tax.txt";
proc export data=casuser.wc_data(keep = content)
            dbms=dlm 
	        outfile=wc_curr 
            replace;
run;



/***********************************************/
/* 6. Clean the unstructured text              */
/***********************************************/
data colNames;
	infile wc_curr truncover;
	input content $2000.;

/* 	FormFieldsData = strip(content); */
/* 	FormFieldsData = tranwrd(content,'09'x,''); /* Remove tabs */
/* 	FormFieldsData = tranwrd(content,'0A'x,''); /* Remove carriage return line feed */

	/* 1. Delete the first four rows that contains random text info */
	if _N_ < 5 then delete;

	/* 2. Remove leading and trailing blanks from content */
	content = strip(content);

	/* 3. Find the taxing unit in the unstructured text */

	/* Search for the first numeric or punctuation character in the string */
	find_first_digit = anydigit(content) - 1;
	find_punctuation = anypunct(content) - 1;
	
	/* Determine which was found first, numeric value or punctuation */
	if find_first_digit < find_punctuation then find_county_position = find_first_digit;
		else find_county_position = find_punctuation;
	
	county_names = substr(content, 1, find_county_position);

	values = strip(substr(content, find_county_position));


/* 	if county_names = 'TAXING UNIT' then do; */
/* 		maxYearValue = scan(values, 1, ' '); */
/* 	    minYearValue = scan(values, -1, ' '); */
/* 		TotalYears = maxYearValue - minYearValue; */
/* 	end; */
	
	num_words_in_values_col = countw(values, ', ');
/*  */
/* 	find_first_value = scan(values,1,' ');  */
/* 	if length(content) = 1 then stop; */
/* 		else output; */
run;
proc print data=colNames;
run;

	county_name = substr(content,1,county_name_position);
	year_values = substr(content,county_name_position);
	/* 
/* 	colNames = find(strip(content), 'TAXING UNIT'); */
/* 	if colNames > 0 then do; */
/* 		colNames = strip(colNames); */
/* 		Taxing_Unit = substr(content, 1, anydigit(content) - 1); */
/* 		Year_Columns = substr(content, anydigit(content)); */
/* 		Total_Years = countw(Year_Columns); */
/* 		do years = 1 to Total_Years; */
/* 			 */
/* 		end; */
/* 		output; */
/* 		stop; */
/* 	end; */
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