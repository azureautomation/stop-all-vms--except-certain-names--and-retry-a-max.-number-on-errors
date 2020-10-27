Stop all VMs, except certain names, and retry a max. number on errors
=====================================================================

            

**Description**


This runbook will connect to an Azure subscription and switch all Virtual Machines to a Stopped (Deallocated) State but can skip any machine with a certain name. It uses a do-loop, in combination with a try-catch to retry a maximum number of 30 times should
 any exceptions occur.


I run this on a schedule to switch off all my VMs (which are testmachines) at a specific time, just in case I forgot to turn them off, to avoid unnecessary costs.


Since my VMs all run in a single cloudservice, I leave one running all the time to make sure I do not loose the external VIP adress.


**Requirements**


You need to have a Connection asset in your automation account. 


**Runbook Content**


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
