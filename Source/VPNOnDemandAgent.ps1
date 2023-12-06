#ABOUT THIS SOFTWARE -----------------------------------------------------------------------------------------------------------------

#VPNOnDemandAgent by SpanishDexter/JDSoft
#For auto-connecting and disconnecting your VPN client based on outbound WAN IP addresses on a blacklist on your web server.

#Version 1.00
#Updated 12/5/2023

#my website: https://www.jdsoft.rocks/
#my github repos: https://github.com/spanishdexter

#LICENSE: Modify, brand and use however you see fit as long as it's not illegal or immoral. Uses MIT license. See LICENSE.TXT.

#DISCLAIMER: Use this software at your own risk. I take no responsibility if you deploy this and damage occurs, be it a business environment or home environment. You as the IT professional are responsible for testing and making sure this script is compatible with your environment and configuration.
#-------------------------------------------------------------------------------------------------------------------------------------

#set script path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#--------get variables from registry--------------------------------------------------------------------------------------------------
#The URL where your IP list text file lives
$ListServerURL = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ListServerURL

#This URL is where your WAN IP is checked - this could be ipinfo.io or a self hosted solution such as ipinfo.tw
$ConnectionTestURL = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ConnectionTestURL

#user name for the basic HTTP authentication where your IP list text file exists
$ListServerUser = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ListServerUser

#user password for the basic HTTP authentication where your IP list text file exists
$ListServerPassword = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ListServerPassword

#the command line command used to disconnect your VPN client of choice
$ClientDisconnectCmd = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ClientDisconnectCmd

#the command line command used to connect your VPN client of choice
$ClientConnectCmd = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty ClientConnectCmd

#the windows service name of your VPN client software - if the service is not running this script will not proceed
$VPNServiceName = (Get-ItemProperty "HKLM:\SOFTWARE\VPNOnDemandForWin") | Select-Object -ExpandProperty VPNServiceName
#-------------------------------------------------------------------------------------------------------------------------------------

#-----perform check for blank variables-----------------------------------------------------------------------------------------------
#if any of these variables are blank the script will exit

if ($ListServerURL -eq $null) {

#exit script
exit

}

if ($ConnectionTestURL -eq $null) {

#exit script
exit

}

if ($ListServerUser -eq $null) {

#exit script
exit

}

if ($ListServerPassword -eq $null) {

#exit script
exit

}

if ($ClientDisconnectCmd -eq $null) {

#exit script
exit

}

if ($ClientConnectCmd -eq $null) {

#exit script
exit

}

if ($VPNServiceName -eq $null) {

#exit script
exit

}

#-------------------------------------------------------------------------------------------------------------------------------------

#check if the VPN service is running--------------------------------------------------------------------------------------------------
#if not exit script

$ServiceName = $VPNServiceName
$arrService = Get-Service -Name $ServiceName

while ($arrService.Status -ne 'Running')
{

#exit the script
exit

}
#------------------------------------------------------------------------------------------------------------------------------------

#--------get $ClientConnectCmd and $ClientDisconnectCmd into batch files--------------------------------------------------------------

#Delete the old ClientDisconnectCmd if it exists
$paths =  "$env:TEMP\ClientDisconnectCmd.bat"
foreach($filePath in $paths)
{
    if (Test-Path $filePath) {
        Remove-Item $filePath -verbose
    } else {
        Write-Host "Path doesn't exist"
    }
}

#Delete the old ClientConnectCmd if it exists
$paths =  "$env:TEMP\ClientConnectCmd.bat"
foreach($filePath in $paths)
{
    if (Test-Path $filePath) {
        Remove-Item $filePath -verbose
    } else {
        Write-Host "Path doesn't exist"
    }
}

#create the VPN disconnect batch file from $ClientDisconnectCmd
$ClientDisconnectCmd | Out-File "$env:TEMP\ClientDisconnectCmd.bat"

#create the VPN connect batch file from $ClientConnectCmd
$ClientConnectCmd | Out-File "$env:TEMP\ClientConnectCmd.bat"
#-------------------------------------------------------------------------------------------------------------------------------------

#--------check if $ListServerURL and $ConnectionTestURL are reachable-----------------------------------------------------------------

#check if list server is reachable - if not disconnect then exit
$url = $ListServerURL
$hostname = [System.Uri]$url | Select-Object -ExpandProperty Host
$isReachable = Test-Connection -ComputerName $hostname -Quiet
if ($isReachable) {
    Write-Host "$url is reachable."
} else {
    #disconnect VPN client
    Start-Process -FilePath "$env:TEMP\ClientDisconnectCmd.bat" -Wait -NoNewWindow
    #exit script
    exit
}

#check if connection test server is reachable - if not disconnect then exit
$url = $ConnectionTestURL
$hostname = [System.Uri]$url | Select-Object -ExpandProperty Host
$isReachable = Test-Connection -ComputerName $hostname -Quiet
if ($isReachable) {
    Write-Host "$url is reachable."
} else {
    #disconnect VPN client
    Start-Process -FilePath "$env:TEMP\ClientDisconnectCmd.bat" -Wait -NoNewWindow
    #exit script
    exit
}


#-------------------------------------------------------------------------------------------------------------------------------------

#get current ip from ipinfo page
$CurrentIPresponse = Invoke-RestMethod -Uri $ConnectionTestURL -Method GET

#---------get list of IPs from web server hosting list ------------------------------------------------------------------------------

#create the request header for HTTP Basic Authentication with credentials from $ListServerUser and $ListServerPassword
$pair = "$($ListServerUser):$($ListServerPassword)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

#perform web request with completed auth header in $Headers
$WANList = Invoke-WebRequest -Uri $ListServerURL -Headers $Headers
#------------------------------------------------------------------------------------------------------------------------------------

#get correct properties from web request results - you can modify these properties as needed depending on the web services your using

#gets the content field from the web response within $WANList and puts it in $WANIPList
$WANIPList = $WANList.Content

#gets the ip field from the web response within $CurrentIPresponse and puts it in $CurrentWANIP
$CurrentWANIP = $CurrentIPresponse.ip

#check if IP address is in list and compare to addresses in list
#if match found perform the disconnect action otherwise perform connection action
ForEach ($content in $WANIPList) {
  
     if( $content.contains("$CurrentWANIP")){
       #Run VPN Client Disconnect command batch file created from $ClientDisconnectCmd - if current WAN IP matches IP in $WANIPList
        Start-Process -FilePath "$env:TEMP\ClientDisconnectCmd.bat" -Wait -NoNewWindow
           } else {
       #Run VPN Client Connect command batch file created from $ClientConnectCmd - if current WAN IP does not match IP in $WANIPList
        Start-Process -FilePath "$env:TEMP\ClientConnectCmd.bat" -Wait -NoNewWindow
           }
         }

#cleanup - delete bat files from TEMP folder ----------------------------------------------------------------------------------------------

#Delete the old ClientDisconnectCmd if it exists
$paths =  "$env:TEMP\ClientDisconnectCmd.bat"
foreach($filePath in $paths)
{
    if (Test-Path $filePath) {
        Remove-Item $filePath -verbose
    } else {
        Write-Host "Path doesn't exist"
    }
}

#Delete the old ClientConnectCmd if it exists
$paths =  "$env:TEMP\ClientConnectCmd.bat"
foreach($filePath in $paths)
{
    if (Test-Path $filePath) {
        Remove-Item $filePath -verbose
    } else {
        Write-Host "Path doesn't exist"
    }
}
#--------------------------------------------------------------------------------------------------------------------------------------------