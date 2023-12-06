; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "VPNOnDemandAgent"
#define MyAppVersion "1.0"
#define MyAppPublisher "JDSoft"
#define MyAppURL "https://www.jdsoft.rocks/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{8668C903-3BAC-4411-A04E-17F7314A7E44}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\JDSoft\{#MyAppName}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\Info.txt
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=C:\Users\Jordan\OneDrive\Project Source Code\InnoSetup_Output
OutputBaseFilename=VPNODSetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SignTool=signtool

[Run]
Filename: "{app}\AddTask.bat"; Description: "Launch application"; \
    Flags: postinstall shellexec waituntilterminated runhidden

[UninstallRun]
Filename: "{app}\RemoveTask.bat"; \
    Flags: shellexec waituntilterminated runhidden

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\VPNOnDemandAgent.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\VPNOnDemandAgent.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\Readme.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\AddTask.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\RemoveTask.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\Info.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Jordan\OneDrive\Project Source Code\VPNOnDemand\Source\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

