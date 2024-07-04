param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# This script deletes the specified user and removes the user profile folder.
# Includes a -Test switch to simulate actions without making changes.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# Set the username to whatever you want the username to be.
$UserName = 'your_username_here'

# --Check if User Account Exists--
$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

# --User Account Exists Condition--
if ($UserAccount) {
    if (-not $Test) {
        Write-Host "User '$UserName' exists, deleting content... (This might take a while)"
        
        # Start timer
        $startTime = Get-Date

        # --Delete User Account--
        Remove-LocalUser -Name $UserName -ErrorAction SilentlyContinue
        
        # --Change Folder Ownership--
        try {
            takeown /f "C:\Users\$UserName\" /A /R /D y 2>&1 | Out-Null
            icacls.exe "C:\Users\$UserName\" /setowner "Administrators" /T /C /q 2>&1 | Out-Null

            # --Delete User Folder--
            &cmd.exe /c rd /s /q "C:\Users\$UserName" 2>&1 | Out-Null

            # Stop timer
            $endTime = Get-Date
            $elapsedTime = $endTime - $startTime

            Write-Host ("User '$UserName' and files have been removed. Time taken: {0:N2} seconds." -f $elapsedTime.TotalSeconds)
        } catch {
            Write-Host "An error occurred while removing user files for '$UserName'."
        }
    } else {
        Write-Host "[Test Mode] Would delete user '$UserName' and their profile folder."
    }
} else {
    if (-not $Test) {
        Write-Host "User '$UserName' doesn't exist."
    }
}

# Wait for a few seconds before exiting
Start-Sleep -Seconds 5

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
