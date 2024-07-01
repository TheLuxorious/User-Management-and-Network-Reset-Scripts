# Thanks for using my script.
# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# This script is used for a local-user deployment where resetting or re-imaging a device takes ages (mostly used on continuously reissued laptops).
# The script changes the privacy settings for the OOBE experience, removing the yes/no part of the 'new user OOBE'.
# Then it checks if the user exists and creates it if needed.
# Once done, press any key to exit the script.

# Change the username to whatever you want the username to be. (Password is optional, see the commented section for adding a password)
$UserName = 'USER'
#$Password = 'password'

# --Set Privacy Consent Status in OOBE--
# This command sets the privacy consent status to '1', indicating that privacy consent has been given.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "PrivacyConsentStatus" /t REG_DWORD /d 1 /f | Out-Null

# --Skip Machine OOBE--
# This command sets the SkipMachineOOBE flag to '1', skipping the machine out-of-box experience during setup.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipMachineOOBE" /t REG_DWORD /d 1 /f | Out-Null

# --Set Protect Your PC to Recommended Settings--
# This command sets the ProtectYourPC value to '3', configuring recommended security settings for the PC.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "ProtectYourPC" /t REG_DWORD /d 3 /f | Out-Null

# --Skip User OOBE--
# This command sets the SkipUserOOBE flag to '1', skipping the user out-of-box experience during setup.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipUserOOBE" /t REG_DWORD /d 1 /f | Out-Null

# --Check if User Exists--
# This command checks if the local user specified by the $UserName variable exists and stores the result in the $UserAccount variable.
$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

# --Create User if Not Exists--
# If the user does not exist, this block creates the user with no password, sets the password to never expire, and adds the user to the Administrators group.
# If necessary, you can add a password by uncommenting the $Password variable and the Set-LocalUser command.
if ($UserAccount -eq $null) {
    Write-Host "User '$UserName' does not exist. Creating user..."
    New-LocalUser -Name $UserName -NoPassword | Set-LocalUser -PasswordNeverExpires:$true
    # Uncomment the next line to set a password (Note: Do this before creating the user, else it doesn't work)
    # Set-LocalUser -Name $UserName -Password (ConvertTo-SecureString $Password -AsPlainText -Force)
    Add-LocalGroupMember -Group "Administrators" -Member $UserName
    Write-Host "User '$UserName' created successfully."
} else {
    # Confirm User Exists
    # If the user already exists, this block notifies the user.
    Write-Host "User '$UserName' already exists."
}

# Pause the script to view the output before it exits
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
