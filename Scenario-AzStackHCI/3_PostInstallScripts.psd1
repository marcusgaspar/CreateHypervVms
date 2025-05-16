@{
    VM0 = @{
        vmPostInstallSteps = @(
            @{
                stepHeadline    = 'Step0 - TimeStamp'           # Headline of the step - ! steps will be performed in alphabetical order !
                scriptFilePath  = 'step_AddDateTimeToLog.ps1'   # Path to the script to be executed
                requiresRestart = $false                        # Does the step require a restart of the VM?
            }
            @{
                stepHeadline       = 'Step1 - PrepareAdminBox'              # This needs to be adjusted to your network!!!!
                scriptFilePath     = 'step_PrepareAdminBox.ps1'
                scriptArgumentList = @('Ext', 'aMGMT', '192.168.1.30/24', '192.168.1.1', '8.8.8.8')  # ??? This needs to be adjusted to your network!!!!
                requiresRestart    = $false                                                    # external adapter name (don't change), internal adapter name (don't change), assign an external adapter IP (routable on your network), external adatper gateway (router on your network), google DNS will be used as upstream DNS
            }
            @{
                stepHeadline       = 'Step2 - This will create a domain '
                scriptArgumentList = @('HCI00.org', '<add your complex password>' )        # ??? Don't change: domain name, !!!!Add!!! a password for the domain admin account. Password complexity requirements (12+ characters long, a lowercase and uppercase character, a numeral, and a special character)
                scriptFilePath     = 'step_CreateDomain.ps1'
                requiresRestart    = $false
            }
            @{
                stepHeadline    = 'Step3 - Output Prepare Active Directory for Azure Stack HCI to temp folder'
                scriptFilePath  = 'step_HCIADprep.ps1'       # have a look at the script. you can use it to prep this AD for Azure Stack HCI install
                requiresRestart = $false
            }
        )
    }
    VM1 = @{
        vmPostInstallSteps = @(
            @{
                stepHeadline    = 'Step0 - TimeStamp'
                scriptFilePath  = 'step_AddDateTimeToLog.ps1'
                requiresRestart = $false
            }
            @{
                stepHeadline    = 'Step1 - Install Hyper-V'
                scriptFilePath  = 'step_InstallHyperV.ps1'
                requiresRestart = $true
            }<# You should not be doing updates yourself - this is part or the AzStack install
            @{
                stepHeadline    = 'Step2 - Windows Update'
                scriptFilePath  = 'step_DoWindowsUpdates.ps1'
                requiresRestart = $false
            }#>
            @{
                stepHeadline       = 'Step2 - Create another local admin account'
                scriptArgumentList = @('asLocalAdmin', '<add your complex password>' )     # ??? Azure Stack HCI local admin account to be used in Azure deployment. Password complexity requirements (12+ characters long, a lowercase and uppercase character, a numeral, and a special character)
                scriptFilePath     = 'step_AzLocalAdmin.ps1'
                requiresRestart    = $false
            }
        )
    }
    VM2 = @{
        vmPostInstallSteps = @(
            @{
                stepHeadline    = 'Step0 - TimeStamp'
                scriptFilePath  = 'step_AddDateTimeToLog.ps1'
                requiresRestart = $false
            }
            @{
                stepHeadline    = 'Step1 - Install Hyper-V'
                scriptFilePath  = 'step_InstallHyperV.ps1'
                requiresRestart = $true
            }
            @{
                stepHeadline       = 'Step2 - Create another local admin account'
                scriptArgumentList = @('asLocalAdmin', '<add your complex password>' )     # ??? Azure Stack HCI local admin account to be used in Azure deployment. Password complexity requirements (12+ characters long, a lowercase and uppercase character, a numeral, and a special character)
                scriptFilePath     = 'step_AzLocalAdmin.ps1'
                requiresRestart    = $false
            }
        )
    }
}
