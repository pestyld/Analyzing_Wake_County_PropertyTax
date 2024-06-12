/****************************************************************************
 WAKE COUNTY PROPERTY TAX ANALYSIS               
*****************************************************************************
 01 - DOWNLOAD PDF FILES FROM THE WAKE COUNTY WEBSITE 
*****************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
	- Must have a mounted location the CAS and Compute can access.
****************************************************************************/



/******************************************
 1. REQUIRED - SET PATHS    
******************************************/
/* Gets the path of the current folder */
%getcwd(path)



/********************************************************************************** 
 PATH WHERE TO DOWNLOAD THE PDF FILES
   - REQUIRED: You must specify any path that the CAS + Compute server can access.
   - (wc_pdfs) Is a path to a subdirectory in the Casuser where the PDFs will be downloaded to.
   - This environment has the Casuser path mounted and available to the Compute server in Studio.
**********************************************************************************/

/* Create the subdirectory wc_pdfs in the Casuser caslib to store the PDF files */
proc cas;
	table.addCaslibSubdir / name="casuser", path="wc_pdfs";
quit;

/* REQUIRED - Specify the path of the subdirectory */
%let pdf_outpath =%sysget(HOME)/casuser/wc_pdfs;
%put &=pdf_outpath;


/**********************************************************************************************************
 2. DOWNLOAD THE PDF FILEs FROM WAKE COUNTY WEBSITE 
**********************************************************************************************************
 Files can be found here: https://www.wake.gov/departments-government/tax-administration/tax-bill-help/tax-rates-fees   
**********************************************************************************************************    
 Direct Links:                
 a. Current to 2014: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf         
 b. 2013 and Prior: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf
**********************************************************************************************************/

/* Display PDF samples */
%showImage("&path/images/wc_pdf_files.png")


/* Macro variables with links to the PDF files on the Wake County website */
%let pdf_2014_to_curr = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf;
%let pdf_1987_to_2013 = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf;


/* Download 1987 - 2013 PDF */
%download_pdf(pdf_url="&pdf_1987_to_2013", 
              save_file="&pdf_outpath/wc_property_1987_2013.pdf")

/* Download 2014 - Current PDF */
%download_pdf(pdf_url="&pdf_2014_to_curr", 
              save_file="&pdf_outpath/wc_property_2014-current.pdf")