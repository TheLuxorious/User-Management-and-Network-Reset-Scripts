# Thanks for using my script.
# This script is used in combincation with the 'create user' script. (can also be used without ofcourse)
# It will delete the created user and remove the userprofile folder.
# Once done, press any key to exit the script
# 
# Change 'Gebruiker' into whatever the username is. (use replace option).


# "Check if User Account Exists"
# This line checks if a local user account named 'Gebruiker' exists.
$UserAccount = Get-LocalUser -Name Gebruiker -ErrorAction SilentlyContinue

# "User Account Exists Condition"
# If the user account exists, the following steps are executed to remove the user and associated files.
if ($UserAccount) {
    # "Delete User Account"
    # Deletes the user account named 'Gebruiker'.
    Write-Host "User exists, deleting content..."
    Remove-LocalUser -Name 'Gebruiker'
    
    # "Change Folder Ownership"
    # Changes the owner of the 'Gebruiker' folder to 'Administrators' recursively.
    icacls.exe "C:\Users\Gebruiker\" /setowner "Administrators" /T /C /q
    
    # "Delete User Folder"
    # Deletes the folder of the user 'Gebruiker', including all subfolders and files.
    &cmd.exe /c rd /s /q "c:\users\Gebruiker"
    
    # "Confirmation Message and Pause"
    # Confirms that the user and files have been removed and pauses the execution.
    Write-Host "User 'Gebruiker' and files have been removed."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} else {
    # "User Account Does Not Exist"
    # If the user account does not exist, the following steps are executed to remove the associated files.
    &cmd.exe /c rd /s /q "c:\users\Gebruiker"
    
    # "Change Folder Ownership"
    # Changes the owner of the 'Gebruiker' folder to 'Administrators' recursively.
    icacls.exe "C:\Users\Gebruiker\" /setowner "Administrators" /T /C /q
    
    # "User Not Found Message and Pause"
    # Reports that the user does not exist and pauses the execution.
    Write-Host "User 'Gebruiker' doesn't exist, but the files are still removed"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
