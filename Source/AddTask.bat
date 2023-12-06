REM adds the scheduled task from XML file
schtasks /create /xml "%~dp0VPNOnDemandAgent.xml" /tn "VPNOnDemandAgent" /ru "SYSTEM"