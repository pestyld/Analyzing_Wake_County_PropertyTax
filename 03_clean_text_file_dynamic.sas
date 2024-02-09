/***************************************/
/* WAKE COUNTY PROPERTY TAX ANALYSIS   */
/***************************************/

/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio. Otherwise specify your path.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

%put &=path;



/***********************************************/
/* 6. Clean the unstructured text              */
/***********************************************/



/* Input text file */
filename f_in "&path/data/wc_tax_data_2014_curr_raw.txt";

/* Dynamically find the first year and last year in the data */
%find_min_max_years(f_in)



