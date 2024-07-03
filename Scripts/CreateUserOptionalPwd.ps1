param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# The script includes a -Test switch to simulate the actions without making actual changes.
# Usage: .\scriptname.ps1 -Test

# This script is used to set up a local user on reissued laptops quickly.
# It adjusts privacy settings to skip the OOBE experience, checks if the user exists, and creates the user if needed.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# Set the username (and optionally the password) for the new user.
$UserName = 'your_username_here'
$Password = 'your_password_here'

# --Set OOBE and Security Settings--
if (-not $Test) {
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "PrivacyConsentStatus" /t REG_DWORD /d 1 /f 2>&1 | Out-Null
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipMachineOOBE" /t REG_DWORD /d 1 /f 2>&1 | Out-Null
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "ProtectYourPC" /t REG_DWORD /d 3 /f 2>&1 | Out-Null
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipUserOOBE" /t REG_DWORD /d 1 /f 2>&1 | Out-Null
} else {
    Write-Host "[Test Mode] Would set OOBE and security settings."
}

# --Check if User Exists--
$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

# --Create User if Not Exists--
if ($UserAccount -eq $null) {
    if (-not $Test) {
        Write-Host "User '$UserName' does not exist. Creating user..."
        New-LocalUser -Name $UserName -NoPassword | Set-LocalUser -PasswordNeverExpires:$true 2>&1 | Out-Null
        # Uncomment the next line to set a password (Note: Do this before creating the user, else it doesn't work)
        # Set-LocalUser -Name $UserName -Password $Password
        Add-LocalGroupMember -Group "Users" -Member $UserName 2>&1 | Out-Null
        Write-Host "User '$UserName' created successfully."
    } else {
        Write-Host "[Test Mode] Would create user '$UserName' and add to Users group."
    }
} else {
    if (-not $Test) {
        Write-Host "User '$UserName' already exists."
    }
}


# Wait for a few seconds before exiting
Start-Sleep -Seconds 5

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
