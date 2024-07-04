param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# This script sets up a local user on reissued laptops quickly.
# It adjusts privacy settings to skip the OOBE experience, checks if the user exists, and creates the user if needed.
# Includes a -Test switch to simulate actions without making changes.
# Asks for a password in a pop-up box, even when the user exists.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# Set the username for the new user.
$username = 'your_username_here'

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
$UserAccount = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

# --Create User if Not Exists--
if ($UserAccount -eq $null) {
    if (-not $Test) {
        Write-Host "User '$username' does not exist. Creating user..."
        New-LocalUser -Name $username -NoPassword | Set-LocalUser -PasswordNeverExpires:$true 2>&1 | Out-Null
        Add-LocalGroupMember -Group "Administrators" -Member $username 2>&1 | Out-Null
        Write-Host "User '$username' created successfully."
    } else {
        Write-Host "[Test Mode] Would create user '$username' and add to Administrators group."
    }
} else {
    if (-not $Test) {
        Write-Host "User '$username' already exists."
    }
}

# --Set or Change User Password--
if (-not $Test) {
    $password = Read-Password -Prompt "Enter password for user '$username'"
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    Set-LocalUser -Name $username -Password $securePassword 2>&1 | Out-Null
    Write-Host "Password for user '$username' has been set/changed successfully."
} else {
    Write-Host "[Test Mode] Would prompt for and set password for user '$username'."
}

# Wait for a few seconds before exiting
Start-Sleep -Seconds 5

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
