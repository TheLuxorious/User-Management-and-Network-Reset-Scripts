# Thanks for using my script.
# ---!!! Run this script as a shortcut or directly in PowerShell; running it in ISE doesn't work !!!---
# This script checks if the default Administrator account is enabled. If not, it prompts you to enable it.
# Change the password to your liking (replace 'your_password_here').
# Once done, press any key to exit the script.

# Change the password to your liking (replace 'your_password_here').
$Password = 'your_password_here'

# "Retrieve Administrator Account Status"
# Retrieves the status of the 'Administrator' local user account.
$adminAccount = Get-LocalUser -Name 'Administrator' -ErrorAction SilentlyContinue

# "Check If Administrator Account is Enabled"
# Checks if the 'Administrator' account is enabled and prompts the user if it is disabled.
if ($adminAccount) {
    if ($adminAccount.Enabled) {
        Write-Host "Administrator account is enabled."
    } else {
        # Prompt the user to enable the Administrator account.
        Write-Host "Administrator account is disabled."
        $response = Read-Host -Prompt "Do you want to enable it? (Enter 'Yes', 'Y', or 'y' to enable, or any other key to continue without enabling.)"

        if ($response.ToLower() -eq "yes" -or $response.ToLower() -eq "y") {
            # Enable Administrator account
            net user administrator $Password /active:yes
            Write-Host "Administrator account has been enabled."
        } else {
            Write-Host "Administrator account remains disabled."
        }
    }
} else {
    Write-Host "Administrator account does not exist on this system."
}

# Pause the script to view the output before it exits.
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
