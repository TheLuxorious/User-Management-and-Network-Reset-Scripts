# Thanks for using my script.
# This script is used for a local-user deployment where resetting a device takes ages. (mostly used on continuously reissued laptops)
# The script changes the privacy settings for the OOBE experience, this removes the yes/no part out of the 'new user OOBE'.
# Then it checks if the user exists, and creates it if needed.
# Once done, press any key to exit the script
# 
# Change 'Gebruiker' into whatever the username is. (use replace option).


# Set Privacy Consent Status in OOBE
# This command sets the privacy consent status to '1', indicating that privacy consent has been given.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "PrivacyConsentStatus" /t REG_DWORD /d 1 /f | Out-Null

# Skip Machine OOBE
# This command sets the SkipMachineOOBE flag to '1', skipping the machine out-of-box experience during setup.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipMachineOOBE" /t REG_DWORD /d 1 /f | Out-Null

# Set Protect Your PC to Recommended Settings
# This command sets the ProtectYourPC value to '3', configuring recommended security settings for the PC.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "ProtectYourPC" /t REG_DWORD /d 3 /f | Out-Null

# Skip User OOBE
# This command sets the SkipUserOOBE flag to '1', skipping the user out-of-box experience during setup.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "SkipUserOOBE" /t REG_DWORD /d 1 /f | Out-Null

# Check if User Exists
# This script checks if the local user 'Gebruiker' exists and stores the result in the $UserAccount variable.
$UserAccount = Get-LocalUser -Name 'Gebruiker' -ErrorAction SilentlyContinue

# Create User if Not Exists
# If the user 'Gebruiker' does not exist, this block creates the user with no password, sets the password to never expire, and adds the user to the Administrators group.
if ($UserAccount -eq $null) {
    Write-Host "User 'Gebruiker' does not exist. Creating user..."
    New-LocalUser -Name Gebruiker -NoPassword | Set-LocalUser -PasswordNeverExpires:$true
    Net localgroup Administrators Gebruiker /add
    Write-host "User 'Gebruiker' created successfully"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} else {
    # Confirm User Exists
    # If the user 'Gebruiker' already exists, this block notifies the user.
    Write-Host "User 'Gebruiker' already exists."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

