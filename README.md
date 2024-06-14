# SAS Viya Platform End-to-End Data Engineering Demo: Analyzing Wake County Property Tax Rates 1987-2023

## Requirements
- Access to SAS Viya.

## Description
![JupyterLab](https://raw.githubusercontent.com/pestyld/Wake_County_PropertyTax_PDF_ETL/main/images/Project%20Workflow.png)


In this hands-on workshop, you will embark on a comprehensive journey through the SAS Viya Platform to analyze Wake County property tax rates on a town-by-town basis. This workshop offers a practical demonstration of end-to-end data engineering using the SAS Viya Platform. Participants will explore the process of extracting and cleaning unstructured data from PDF files sourced from the Wake County website. By leveraging SAS CAS, attendees will transform this data into actionable insights, culminating in the creation of interactive dashboards highlighting property tax rates by town.

By the end of the workshop, participants will learn the data engineering skills to extract text from PDF files, transform the data using the DATA step, then load the data to the distributed CAS server to create informative dashboards that will provide insights into property tax rates for the last 35 years.

Data is from: [WAKE COUNTY VIEW TAX RATE & FEE CHARTS:](https://www.wake.gov/departments-government/tax-administration/tax-bill-help/tax-rates-fees)

Here's a breakdown of the key topics covered:

1. **Downloading PDF Files** - Accessing the Wake County website to download relevant PDF files containing property tax information using the HTTP procedure.

2. **Text Extraction from PDFs** - Use the CAS server in SAS Viya to easily extract text from the downloaded PDF files.

3. **Data Cleaning** - Learn differenet techniques with the DATA step for cleaning and preparing the unstructured text data for analysis.

4. **Loading Data into the CAS Server** - Demonstrating how to load the cleaned data into the CAS server to utilize the SAS Viya Platform's visualization capabilities to create informative dashboards showcasing property tax rates by town.

### Conclusion
Learn how to use the SAS Viya platform for end to end capabilities. From data extraction, transformation, loading and deriving insights.


## Setup (REQUIRED)
1. You will need to run the **00_utility_macros.sas** program from the **utility** folder to create the necessary macro programs for the workshop.

## Workshop Notes
Most of the this workshop should run in your SAS Viya environment as is. You will have to make sure the CAS + Compute server have access to the location of the PDF files. Otherwise you will have to move them where CAS can access them.

If your Viya environment is in lockdown mode you will have to manually upload the PDFs to your environment and skip program **01_download_pdf_files.sas**.


## Folder descriptions

### data
Contains the extracted text from the PDF files in a txt file.
- wc_tax_data_1987_2013_raw.txt
- wc_tax_data_2014_curr_raw.txt

### images 
Contains a quick snapshot image of the PDF files, the final table, and an example visualization.

### pdf_files
Contains the 2 downloaded PDF files from the [WAKE COUNTY VIEW TAX RATE & FEE CHARTS:](https://www.wake.gov/departments-government/tax-administration/tax-bill-help/tax-rates-fees) website.
- wc_property_1987_2013.pdf
- wc_property_2014-current.pdf

### utility
Contains three programs:
- **00_utility_macros.sas** - Series of utility macro programs.
- **01_get_min_max_years** - Macro program to dynamically find the min and max years in the unstructured text, as well as to count the total number of years in the data. 
- **clean_text_file.sas** - DATA step code to clean the instructured text files and create structured tables. This could be put into a macro program if desired. Currently left as is for training purposes.