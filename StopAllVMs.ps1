<#
.SYNOPSIS 
    Stop all VMs in an Azure subscription except anything with MNG in the name

.DESCRIPTION
    This runbook connects to an Azure subscription and puts all VMs in a Stopped (Deallocated) state
    except any machine with MNG in it's name

.EXAMPLE
    StopAllVMs 
   
.NOTES
    AUTHOR: Elmar Calbo
    LASTEDIT: October 30, 2014
#>

workflow StopAllVMs
{
    param (
    )
       
    $Stoploop = $false
    [int]$Retry = "0"

    $ErrorActionPreference = "Stop"

    do {
        
        # Change this to the Azure connection assetname
        $AzureConnectionName = "my Azure connection"
        
        # Any VM with this name (can use wildcards) will be skipped
        $ExceptName = "*MNG*"
        
        # Get the Azure connection asset that is stored in the Auotmation service based on the name that was passed into the runbook 
        $AzureConn = Get-AutomationConnection -Name $AzureConnectionName
        if ($AzureConn -eq $null)
        {
            throw "Could not retrieve '$AzureConnectionName' connection asset. Check that you created this first in the Automation service."
        }
    
        # Get the Azure management certificate that is used to connect to this subscription
        $Certificate = Get-AutomationCertificate -Name $AzureConn.AutomationCertificateName
        if ($Certificate -eq $null)
        {
            throw "Could not retrieve '$AzureConn.AutomationCertificateName' certificate asset. Check that you created this first in the Automation service."
        }
    
        # Set the Azure subscription configuration
        Set-AzureSubscription -SubscriptionName $AzureConnectionName -SubscriptionId $AzureConn.SubscriptionID -Certificate $Certificate

        # Select the Azure subscription configuration
        Select-AzureSubscription -Current $AzureConnectionName

        try {

            $VMs = Get-AzureVM
    
            ForEach ($VM in $VMs) {
        
                    $VMname = $VM.Name
                    $VMservice = $VM.ServiceName
                    $VMstate = $VM.Status
                    if ($VMname -like $ExceptName) {
                        echo "Skipping $VMname. The current state of this Virtual Machine is: $VMstate" 
                    } else {
                        if ($VM.Status -eq "StoppedDeallocated") {
                            echo "$VMname on $VMservice is already in a Stopped (Deallocated) State"
                        } else {
                            echo "Sending stop command to $VMname on $VMservice"
                            Stop-AzureVM -ServiceName $VMservice -Name $VMname -Force
                        }
                    }
            }
            $Stoploop = $true
            echo "The runbook had to retry $Retry times"
        }
        catch {
            if ($Retry -gt 30) {
                echo "Azure service failed to respond after 30 retries"
                $Stoploop = $true
            } else {
                echo "Azure service non-responsive. Retrying in 1 minute ($Retry)"
                Start-Sleep -Seconds 60
                $Retry++
            }
        }

    }
    While ($Stoploop -eq $false)
}
