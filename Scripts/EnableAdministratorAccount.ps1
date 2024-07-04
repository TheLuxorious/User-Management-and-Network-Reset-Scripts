param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell; running it in ISE doesn't work !!!---
# This script enables the default Administrator account if it is disabled.
# Change the password to your liking (replace 'your_password_here').
# Includes a -Test switch to simulate actions without making changes.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# Set the password for the Administrator account.
$Password = 'your_password_here'

# "Retrieve Administrator Account Status"
$adminAccount = Get-LocalUser -Name 'Administrator' -ErrorAction SilentlyContinue

# "Enable Administrator Account if Disabled"
if ($adminAccount) {
    if ($adminAccount.Enabled) {
        Write-Host "Administrator account is enabled."
    } else {
        if (-not $Test) {
            # Enable Administrator account
            net user administrator $Password /active:yes 2>&1 | Out-Null
            Write-Host "Administrator account has been enabled."
        } else {
            Write-Host "[Test Mode] Would enable the Administrator account."
        }
    }
} else {
    Write-Host "Administrator account does not exist on this system."
}

# Wait for a few seconds before exiting
Start-Sleep -Seconds 5

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
