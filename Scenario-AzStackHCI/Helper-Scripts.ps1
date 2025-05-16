#region Get VM status
###############################
Get-VM -Name "00-DC-2" | Select-Object Name, State
###############################
#endregion

#region Unblock powershell files
###############################
# Caminho da pasta onde estão os arquivos .ps1
$pasta = "C:\AzureLocal\CreateHypervVms-master\Scenario-AzStackHCI"

# Pega todos os arquivos .ps1 na pasta (não recursivo)
$arquivos = Get-ChildItem -Path $pasta -Filter *.ps1

# Aplica Unblock-File em cada arquivo
foreach ($arquivo in $arquivos) {
    try {
        Unblock-File -Path $arquivo.FullName
        Write-Host "Desbloqueado: $($arquivo.Name)"
    } catch {
        Write-Warning "Erro ao desbloquear: $($arquivo.Name) - $($_.Exception.Message)"
    }
}
###############################
#endregion

#region Teste Invoke-Command 
###############################
# Defina os parâmetros
$vmName = "00-DC-2"
$cred = Get-Credential # Insira as credenciais de administrador da VM HCI00\Administrator
$scriptPath = "C:\AzureLocal\teste\Teste.ps1"
$args = @("Olá, Marcus! Este é um teste.")

# Execute o script dentro da VM
Invoke-Command -VMName $vmName `
               -Credential $cred `
               -FilePath $scriptPath `
               -ArgumentList $args `
               -Verbose
###############################
#endregion

#region Tests VMIntegrationService
###############################
$cred = Get-Credential # Insira as credenciais de administrador da VM HCI00\Administrator
$vmName = "00-DC-1"
Get-VMIntegrationService $vMName -Name 'Heartbeat' -Credential $cred

(Get-VMIntegrationService -VMName $vmName -Name 'Heartbeat').PrimaryStatusDescription.ToString().ToLower()

###############################
#endregion

#region Test Clean scheduled shutdown
###############################
Invoke-Command -VMName $vmName -Credential $cred { 'shutdown /a' }

###############################
#endregion

#region Change Password
###############################
# Nome do usuário
$usuario = "asLocalAdmin"

# Nova senha segura
$novaSenha = Read-Host "Digite a nova senha" -AsSecureString

# Alterar a senha
Set-LocalUser -Name $usuario -Password $novaSenha

###############################
#endregion

#region Update Windows license Key
###############################
# Ativar licença Windows Server 2022 Datacenter Edition no DC
DISM /online /Get-CurrentEdition
DISM /online /Get-TargetEditions
DISM /online /Set-Edition:ServerDatacenter /ProductKey:<key> /AcceptEula

###############################
#endregion

