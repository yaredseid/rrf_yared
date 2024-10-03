/*******************************************************************************
							Template Main do-file							   
*******************************************************************************/

	* Set version
	clear all 
	version 18

	* Set project global(s)	
	// User: you 
	display "`c(username)'" 	//Check username and copy to set project globals by user
	
	* Add file paths to DataWork folder and the Github folder for RRF2024
	if "`c(username)'" == "wb484182" {
        global onedrive "C:\Users\wb484182\OneDrive - WBG\1ys_EPL\zOtherTrainings\Reproducible Research Fundamentals - Sept 2024\DataWork"
		global github 	"C:\Users\wb484182\0GitHub\rrf_yared"
    }
	
	
	* Set globals for sub-folders 
	global data 	"${onedrive}/Data"
	global code 	"${github}/Stata/Code"
	global outputs 	"${github}/Stata/Outputs"
	
	sysdir set PLUS "${code}/ado"

/*
	* Install packages 
	local user_commands	ietoolkit iefieldkit winsor sumstats estout keeporder grc1leg2 //Add required user-written commands

	foreach command of local user_commands {
	   capture which `command'
	   if _rc == 111 {
		   ssc install `command'
	   }
	}
*/
	* Run do files 
	* Switch to 0/1 to not-run/run do-files 
	if (1) do "${code}/01-processing-data.do"
	if (1) do "${code}/02-constructing-data.do"
	if (1) do "${code}/03-analyzing-data.do"

* End of do-file!	
exit 