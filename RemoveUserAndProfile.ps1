# Thanks for using my script.
# ---!!! Run this script as a shortcut or directly in PowerShell, running it in ISE doesn't work !!!---
# This script is used in combination with the 'create user' script (can also be used independently).
# It will delete the specified user and remove the user profile folder.
# Once done, press any key to exit the script.

# Change the username to whatever you want the username to be.
$UserName = 'USER'

# --Check if User Account Exists--
# This command checks if a local user account specified by the $UserName variable exists.
$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

# --User Account Exists Condition--
# If the user account exists, the following steps are executed to remove the user and associated files.
if ($UserAccount) {
    Write-Host "User '$UserName' exists, deleting content... (This might take a while)"

    # --Delete User Account--
    # Deletes the user account specified by the $UserName variable.
    Remove-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    
    # --Change Folder Ownership--
    # Changes the owner of the user folder to 'Administrators' recursively.
    try {
        takeown /f "C:\Users\$UserName\" /A /R /D y 2>&1 | Out-Null
        icacls.exe "C:\Users\$UserName\" /setowner "Administrators" /T /C /q 2>&1 | Out-Null

        # --Delete User Folder--
        # Deletes the folder of the user, including all subfolders and files.
        &cmd.exe /c rd /s /q "C:\Users\$UserName" 2>&1 | Out-Null

        # --Confirmation Message and Pause--
        # Confirms that the user and files have been removed and pauses the execution.
        Write-Host "User '$UserName' and files have been removed."
    } catch {
        Write-Host "An error occurred while removing user files for '$UserName'."
    }
} else {
    # --User Account Does Not Exist--
    # Reports that the user does not exist.
    Write-Host "User '$UserName' doesn't exist."
}

# Pause the script to view the output before it exits
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
