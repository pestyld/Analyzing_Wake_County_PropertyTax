/*********************************************************
 UTILITY MACROS
*********************************************************/


/******************************************
 FIND PATH FOR THE PROJECT FOLDER    
******************************************/
/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path specified variable. Valid in SAS Studio. */

%macro getcwd(variable);
	/*
	  variable : Macro variable name that stores the workshop path.
	*/
	%global &variable;

	%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
	%let current_path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

	%let &variable=&current_path;
	%PUT NOTE: *****************************************************;
	%PUT NOTE: Current directory path: &current_path;
	%PUT NOTE: *****************************************************;
%mend;




/******************************************
 DOWNLOAD PDF FILES FROM THE INTERNET AND SAVE TO VIYA 
******************************************/
/* Saves a PDF file from the internet to the SAS Viya environment to the specified path. */

%macro download_pdf(pdf_url, save_file);
/*
	pdf_url (str)   : Add a quoted string of the path of the PDF file to download.
	save_file (str) : Add a quoted string for the path and file name of where to save the PDF file in SAS.
*/

	/* Path and name of the PDF file to create */
	filename pdf_file &save_file;
	
	/* Download PDF file from the internet and save it in SAS */
	proc http
	 	url=&pdf_url
	 	method="get" 
		out=pdf_file;
	run;

	%if &SYS_PROCHTTP_STATUS_CODE = 200 %then %do;
		%PUT NOTE: *****************************************************;
		%PUT NOTE: Downloaded PDF file to;
        %PUT NOTE: &save_file;
		%PUT NOTE: *****************************************************;
	%end;
	%else %do;
		%PUT WARNING: Could not download file.;
	%end;
	
%mend;





/******************************************
 CONVERT PDF FILE TO A TEXT FILE    
******************************************/
%macro pdf_to_txt(casTable, pdfFile, fileOut);
/*
	casTable (plain text) : Specify caslib.castablename
	pdfFile (str) : PDF file to convert to text. Example: "abc/path/test.pdf"
	fileOut (str) : Add a quoted string for the path and file name of where to save the PDF file in SAS.
					Example: "abc/path/newfile.txt"
*/

	%PUT NOTE: *****************************************************;
	%PUT NOTE: Save CAS table &casTable to as a;
	%PUT NOTE: text file: &fileOut;
	%PUT NOTE: *****************************************************;

	filename fout &fileOut;
	proc export data=casuser.wc_data(where=(fileName=&pdfFile))
	            dbms=dlm 
		        outfile=fout 
	            replace;
	run;

%mend;


%getcwd(utility_path)
%include "&utility_path/get_min_max_years.sas";