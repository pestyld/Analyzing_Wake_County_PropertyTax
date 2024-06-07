/***************************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS               */
/***************************************************/
/* DOWNLOAD PDF FILES FROM THE WAKE COUNTY WEBSITE */
/***************************************************/


/******************************************
 1. FIND PATH FOR THE PROJECT FOLDER    
******************************************/
%getcwd(path)



/**********************************************************************************************************
 2. DOWNLOAD THE PDF FILEs FROM WAKE COUNTY WEBSITE 
**********************************************************************************************************
 Files can be found here: https://www.wake.gov/departments-government/tax-administration/tax-bill-help/tax-rates-fees   
**********************************************************************************************************    
 Direct Links:                
 a. Current to 2014: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf         
 b. 2013 and Prior: https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf
**********************************************************************************************************/

/* Macro variables with links to the PDF files on the Wake County website */
%let pdf_2014_to_curr = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/TaxRates2023.pdf;
%let pdf_1987_to_2013 = https://s3.us-west-1.amazonaws.com/wakegov.com.if-us-west-1/s3fs-public/documents/2023-06/PriorTaxRates2013back.pdf;


/* Download 1987 - 2013 PDF */
%download_pdf(pdf_url="&pdf_1987_to_2013", 
              save_file="&path/pdf_files/wc_property_1987_2013.pdf")

/* Download 2014 - Current PDF */
%download_pdf(pdf_url="&pdf_2014_to_curr", 
              save_file="&path/pdf_files/wc_property_2014-current.pdf")