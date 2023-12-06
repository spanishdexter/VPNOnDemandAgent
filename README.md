# VPNOnDemandAgent
For auto-connecting and disconnecting your Remote Access VPN client based on outbound public IP addresses on a list on your web server.

my website: https://www.jdsoft.rocks/
my github repos: https://github.com/spanishdexter

# LICENSE
Modify, brand and use however you see fit as long as it's not illegal or immoral. Uses an MIT License. See LICENSE.TXT.

# DISCLAIMER 

Use this software at your own risk. I take no responsibility if you deploy this and damage occurs, be it a business environment or home environment. You as the IT professional are responsible for testing and making sure this script is compatible with your environment and configuration.

# Description
This script will allow a VPN client of your choice on your Windows device to connect or disconnect based on it's outbound internet IP address.

This can allow for scenarios where your on-premise, on your trusted network and DO NOT want to have your VPN client running to avoid routing, DNS issues, conflicts, etc. Great for VPN clients that don't natively support this.


# Requirements

-A web server with basic HTTP authentication in place to host a text file containing a list of public IP addresses that are trusted and seen as where your "on-premise" network is, so the client will not connect when your on those networks, there is no need for your Remote Access VPN while on-premise, since presumably your servers are on the local lan or over your router's site to site VPN tunnels.

-An IP address information service you can use such as ipinfo.io or a self-hosted one such as ipinfo.tw by Pete Dave Hello (https://github.com/PeterDaveHello/ipinfo.tw)

-A VPN client that has a command line interface running in Windows, that allows control over the disconnect and connect operations

-The ability to work in the windows registry on the endpoint client devices running the VPN client. You will need to define the appropriate settings in order for this script to work properly. As such you'll need administrative rights on your windows device running the VPN client to do this and you should not proceed with setup, if you do not have experience with the windows registry. If this is a business environment or for production use in a business environment, please consult with your IT department before doing anything with this software.

-Although not required, if your deploying this to multiple machines, a method to define registry settings on more than one computer should be considered. Group Policy or an RMM tool can be useful for this. A method should also be in place to silently install this script on each machine in a fleet.

# About the registry settings
The following settings must be set in windows at the following key path: HKLM:\SOFTWARE\VPNOnDemandForWin
If these are not set, the script will detect it and exit as a failsafe.


ListServerURL - The URL where your IP list text file lives

ConnectionTestURL - This URL is where your WAN IP is checked - this could be ipinfo.io or a self hosted solution such as ipinfo.tw

ListServerUser - user name for the basic HTTP authentication where your IP list text file exists

ListServerPassword - user password for the basic HTTP authentication where your IP list text file exists

ClientDisconnectCmd - the command line command used to disconnect your VPN client of choice

ClientConnectCmd - the command line command used to connect your VPN client of choice

VPNServiceName - the windows service name that powers your VPN client software - if the service is not running this script will not proceed

You can set these manually if that's feasable for you, or in an automated fashion using Group Policy, if your running an Active Directory environment or via an RMM solution.

# Installing the software using the pre-complied EXE installer
You can execute VPNODSetup.exe as an administrator to install the software on your machine. Using the /S switch on command line will silently install it. This is helpful for silent deployment via RMM or software deployment tools.
It will install at C:\Program Files (x86)\JDSoft\VPNOnDemandAgent

# Installing the software using .zip package:
You will be manually installing and executing the powershell script in the zip file as you see fit for your environment. Works best for environments that want more customization or for those that want to include or integrate the script in a larger project. The .bat files can import or remove the scheduled task defined in the .xml file. You will need to modify these files for the file paths you want to use for the script and it's components.

The installer is code signed and a copy of the self-signed certificate is provided in the github repo under the codesign folder. Import this certificate into your Trusted Publishers and Trusted Root Certification Authorites stores.

# Custom Installer
The INNO setup files have been included in the innosetup folder on this repo, so you can build your own installer and code sign it with your own certificate if you wish. You will need to modify the paths in the .iss file and you will need the INNO Script Studio installed and the signtool.exe from the Windows SDK, if you want to code sign the installer.

# Uninstalling the software
Run Uninstall.exe in C:\Program Files (x86)\JDSoft\VPNOnDemandAgent. Using the /S switch on command line will silently uninstall it, this is helpful if you need to execute the removal in an automated fashion via RMM or software deployment tools.

# The Task Scheduler Task
On install a task will be created called VPNOnDemandAgent. This will be set to run every 15 minutes as a trigger and upon change in network connection state (Event ID 10000). It will also run upon system startup. You can modify this event to fit your needs, but the default setup should work for most environments.

# Expected behavior
Every 15 minutes or when you connect to a network on your Windows endpoint, the script should run and perform a check against your web server containing a list of your trusted public internet addresses. If your Windows device happens to be on one of the networks using any of those outbound internet addresses, the VPN client will disconnect. If you roam and connect to a different network and the check is run again, and that outbound internet address is not on the list, your VPN client will connect.

If your VPN client's service in Windows is not running, the script will exit on each run until the service is running again. This is to allow a window of opportunity for your VPN client to get upgraded or re-installed without conflicts, or allow you to change VPN client providers and re-configure without causing widespread issues on your end
