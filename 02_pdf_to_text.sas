/***************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS   */
/***************************************/

/************************************************/
/* 3. Create Caslib to the folder with the PDFs */
/************************************************/

/* Confirm the PDF files are available */
proc cas;
	table.fileInfo / 
		caslib = 'casuser' 
		allfiles=true;
quit;



/*********************************************/
/* 4. Load the PDF file as a CAS table       */
/*********************************************/
/* Read in all of the PDF files in the caslib as a single CAS table */
/* Each PDF will be one row of data in the CAS table                */
proc casutil;
    load casdata='wake_county_tax'                 /* To read in all files use an empty string. For a single PDF file specify the name and extension */
         incaslib='casuser'                        /* The location of the PDF files to load */
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
filename fout "&path/data/wc_tax_data_2014_curr_raw.txt";
proc export data=casuser.wc_data(keep = content obs=1)
            dbms=dlm 
	        outfile=fout 
            replace;
run;


filename fout "&path/data/wc_tax_data_1987_2013_raw.txt";
proc export data=casuser.wc_data(keep = content firstobs=2)
            dbms=dlm 
	        outfile=fout 
            replace;
run;