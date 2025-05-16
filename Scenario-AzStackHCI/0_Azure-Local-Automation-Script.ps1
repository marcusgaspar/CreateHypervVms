# https://github.com/bfrankMS/CreateHypervVms
# https://www.youtube.com/watch?v=_8QimlTNQpI
# https://www.youtube.com/watch?v=A_zNSNHOKJU
# https://www.youtube.com/watch?v=jSOpU0RmDvw&list=PLDk1IPeq9PPfzWKW08Gs7_n9mP3TzqtML

#######################################################################################
# Azure
#######################################################################################

# Register Providers on Azure
Register-AzResourceProvider -ProviderNamespace "Microsoft.HybridCompute" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.GuestConfiguration" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.HybridConnectivity" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.AzureStackHCI" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.Kubernetes" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.KubernetesConfiguration" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.ExtendedLocation" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.ResourceConnector" 
Register-AzResourceProvider -ProviderNamespace "Microsoft.HybridContainerService"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Attestation"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Storage"

# Permissions
# Subscription
#   Reader 
#   Azure Stack HCI Administrator 
# RG
#   Key Vault Data Access Administrator
#   Key Vault Secrets Officer
#   Key Vault Contributor
#   Storage Account Contributor
# Entra ID
#   Cloud Application Administrator >    

cd C:\AzureLocal\CreateHypervVms-master\Scenario-AzStackHCI

Set-ExecutionPolicy Unrestricted
#Get-ExecutionPolicy -List

.\CreateVhdxFromIso.ps1 -IsoPath "C:\AzureLocal\Images\win_2k22_en-us.iso" -VhdxPath 'C:\AzureLocal\Images\W2k22.vhdx' -SizeBytes 80GB -ImageIndex 4
.\CreateVhdxFromIso.ps1 -IsoPath "C:\AzureLocal\Images\AzureLocal24H2.26100.1742.LCM.12.2504.0.3142.x64.en-us.iso" -VhdxPath 'C:\AzureLocal\Images\AzureLocal24H2_en-us.vhdx' -SizeBytes 80GB -ImageIndex 1
# you can use .iso files with OS from Microsoft.
# -ImageIndex 1 : is the first image in the install.wim 
# -ImageIndex 1 : mostly is a Server Standard Core
# -ImageIndex 4 : mostly is a Server Datacenter with GUI
# Mount .iso and run Get-WindowsImage -ImagePath "X:\sources\install.wim" to find out what imageindex to choose.

# Edit files: 1_VMs.psd1, 2_UnattendSettings.psd1, 3_PostInstallScripts.psd1
.\CreateHypervVms.ps1

#######################################################################################
# [On the physical Host] When the VMs are created enable vlans on the smb adapters.
#######################################################################################
# This will make the nested HCIs storage adapters allow vlan usage  
Get-VMNetworkAdapter -vmname '00-HCI-1' -Name smb* | Set-VMNetworkAdapterVlan -Trunk -NativeVlanId 0 -AllowedVlanIdList 711-712
Get-VMNetworkAdapter -vmname '00-HCI-2' -Name smb* | Set-VMNetworkAdapterVlan -Trunk -NativeVlanId 0 -AllowedVlanIdList 711-712

# Validate
Get-VMNetworkAdapterVlan -vmname '00-HCI-1'
Get-VMNetworkAdapterVlan -vmname '00-HCI-2'

## Make sure you have a time server set (NTP)
Get-VMIntegrationService -VMName "00-HCI-1" 
Get-VMIntegrationService -VMName "00-HCI-1" |Where-Object {$_.name -like "T*"}|Disable-VMIntegrationService
Get-VMIntegrationService -VMName "00-HCI-2" |Where-Object {$_.name -like "T*"}|Disable-VMIntegrationService

#######################################################################################
# on DC run
#######################################################################################
c:\temp\step_HCIADprep.ps1


#######################################################################################
# [do this on every HCI node]
#######################################################################################
# check connectivity
ping ibm.com

# check hyper-v installed
Get-WindowsFeature

# disable ipv6
Disable-NetAdapterBinding -InterfaceAlias * -ComponentID ms_tcpip6

#w32tm /config /manualpeerlist:de.pool.ntp.org /syncfromflags:manual /reliable:yes /update
#w32tm /resync /force
w32tm /query /status
w32tm /config /manualpeerlist:"ntpserver.contoso.com" /syncfromflags:manual /update

# Onboard your AzStack HCI hosts to Azure using e.g.
#Define the subscription where you want to register your machine as Arc device
$Subscription = "subscription ID"

#Define the resource group where you want to register your machine as Arc device
$RG = "rg-azurelocal"

#Define the region to use to register your server as Arc device
#Do not use spaces or capital letters when defining region
$Region = "eastus"

#Define the tenant you will use to register your machine as Arc device
$Tenant = "entra tenant id"

#Define the proxy address if your Azure Local deployment accesses the internet via proxy
#$ProxyServer = "http://proxyaddress:port"

#Connect to your Azure account and Subscription
Connect-AzAccount -SubscriptionId $Subscription -TenantId $Tenant -DeviceCode

#Get the Access Token for the registration
$ARMtoken = (Get-AzAccessToken -WarningAction SilentlyContinue).Token

#Get the Account ID for the registration
$id = (Get-AzContext).Account.Id

#Invoke the registration script. Use a supported region.
Invoke-AzStackHciArcInitialization -SubscriptionID $Subscription -ResourceGroup $RG -TenantID $Tenant -Region $Region -Cloud "AzureCloud" -ArmAccessToken $ARMtoken -AccountID $id -verbose








