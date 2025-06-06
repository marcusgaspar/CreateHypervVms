﻿@{
    'VM0' = @{                                                          # VM0 is the first VM to be created - do not change this name
        vmName                = "Test-N1"                               # Name of the VM in Hyper-V
        vmPath                = ""
        #GoldenImagePath       = "c:\images\W2k22.vhdx"                 # If you have specific golden image just for this VM
        #ExposeVirtualizationExtensions = $true                         # Expose virtualization extensions to the VM - only required if you want to run Hyper-V inside this VM
        vmMemory              = 8GB                                    # ??? Memory in GB of the VM
        vmGeneration          = 2                                      # Gen 2 VM - you should not use Gen 1 VMs anymore
        vmProcCount           = 4                                      # ??? Number of vCPUs
        vmAutomaticStopAction = "ShutDown"                             # What to do when the host is shut down - saves disk space.
        enableVMTPM           = $true                                  # This will enable a virtual TPM to be available inside the VM (default = $false)
        vmNics                = @{                                     # NICs of the VM  - make sure your hyper-v switch names are correct!
            "aMGMT" = @{"Switch" = "Internal"; "VLANID" = "" <#; "MacAddressSpoofing" = $true #> }   # The first NIC in alphabetical order will receive IP address as per 2_UnattendSettings.psd1 #MacAddressSpoofing is probably only required if you want to run Hyper-V inside this VM
            "Ext"   = @{"Switch" = "SetSwitch"; "VLANID" = "" }        # ??? SetSwitch -> is your external switch name on the physical host
        }
        vmDataDisks           = @(                                      # (optional) Data disks of the VM
            @{"DiskName" = "dd-1.vhdx"; "DiskSize" = 30GB }
            @{"DiskName" = "dd-2.vhdx"; "DiskSize" = 30GB }
        )
        VMIntegrationService  = @{                                     # lets you set the integration services behaviour for the VM 
            "Guest Service Interface" = $false                         # these are the defaults if you don't intent to change you can remove this section see example below
            "Heartbeat"               = $true
            "Key-Value Pair Exchange" = $true
            "Shutdown"                = $true
            "Time Synchronization"    = $true
            "VSS"                     = $true
        }                                                                   
    }
    'VM1' = @{
        vmName                = "Test-N2"
        vmPath                = ""                                      # (optional) alternative Path to store the VM files - leave empty to use default (i.e. $vmDirectoryPrefix in CreateHyperVVM.ps1)
        vmMemory              = 2GB
        vmGeneration          = 2
        vmProcCount           = 4
        vmAutomaticStopAction = "ShutDown"
        vmNics                = @{
            "a" = @{"Switch" = "SetSwitch"; "VLANID" = "" }             # single NIC with no VLAN
        }
        vmDataDisks           = @()                                     # no data disks
    }
    <#
    'VM2' = @{
        vmName                = "yourvmname"
        vmPath                = ""
        vmMemory              = 2GB
        vmGeneration          = 2
        vmProcCount           = 4
        vmAutomaticStopAction = "ShutDown"
        vmNics                = @{
            "MGMT" = @{"Switch" = "SetSwitch"; "VLANID" = "" }
        }
        vmDataDisks           = @()
    }
    .
    .
    .
    #>
}