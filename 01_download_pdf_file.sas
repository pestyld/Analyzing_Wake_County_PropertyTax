/***************************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS               */
/***************************************************/
/* DOWNLOAD PDF FILES FROM THE WAKE COUNTY WEBSITE */
/***************************************************/


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


/* Macro variables with links to the PDF files on the Wake County website */
%let pdf_2014_to_curr = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf;
%let pdf_1987_to_2013 = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf;


/* Download 2014 - Current PDF */
/* Path and name of the PDF file to create */
filename pdf_file "&path/pdf_files/wc_property_2014-current.pdf";

/* Download PDF file from the internet and save it in SAS */
proc http
 	url="&pdf_2014_to_curr"
 	method="get" 
	out=pdf_file;
run;


/* Download 1987 - 2013 PDF */
/* Path and name of the PDF file to create */
filename pdf_file "&path/pdf_files/wc_property_1987-2013.pdf";

/* Download PDF file from the internet and save it in SAS */
proc http
 	url="&pdf_1987_to_2013"
 	method="get" 
	out=pdf_file;
run;