# Thanks for using my script.
# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# This script is a revised version of my other CreateUser script, however, this one asks for a password in a pop-up box! even when the user exists!
# There where a few other users who asked, so i made it :)
# Once done, press any key to exit the script.

# Change the username to whatever you want the username to be.
$username = 'USER'

# Function to read the password securely
function Read-Password {
    param(
        [string]$Prompt = "Enter Password: "
    )
    $secureString = Read-Host -AsSecureString -Prompt $Prompt
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    )
    return $password
}

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
# This command checks if the local user specified by the $username variable exists and stores the result in the $UserAccount variable.
$UserAccount = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

# --Create User if Not Exists--
# If the user does not exist, this block creates the user with no password, sets the password to never expire, and adds the user to the Administrators group.
if ($UserAccount -eq $null) {
    Write-Host "User '$username' does not exist. Creating user..."
    New-LocalUser -Name $username -NoPassword | Set-LocalUser -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group "Administrators" -Member $username
    Write-Host "User '$username' created successfully."
} else {
    # Confirm User Exists
    # If the user already exists, this block notifies the user.
    Write-Host "User '$username' already exists."
}

# --Set or Change User Password--
# Prompt for the password securely and set it for the user
$password = Read-Password -Prompt "Enter password for user '$username'"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
Set-LocalUser -Name $username -Password $securePassword

Write-Host "Password for user '$username' has been set/changed successfully."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
