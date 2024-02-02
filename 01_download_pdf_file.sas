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