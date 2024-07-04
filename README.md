# User Management and Network Reset Scripts

This repository contains a collection of PowerShell scripts designed for managing user accounts and resetting network settings on Windows machines. These scripts can be used individually or in combination to automate various tasks related to user account management and network configuration.

## Script Overview

- **`CreateUserWithPwd.ps1`**
  - **Description:** Creates a new local user account with a specified password.
  - **Functionality:**
    - Sets OOBE and security settings.
    - Checks if the user exists and creates the user if it doesn't.
    - Prompts for a secure password input for the new user.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), set the desired username, and execute.

- **`CreateUserWithOptionalPwd.ps1`**
  - **Description:** Creates a new local user account with an optional password.
  - **Functionality:**
    - Sets OOBE and security settings.
    - Checks if the user exists and creates the user if it doesn't.
    - Allows setting a password if desired; otherwise, creates the user without a password.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), set the desired username and optionally set a password in the script, and execute.

- **`EnableAdministratorAccount.ps1`**
  - **Description:** Enables the default Administrator account if it is disabled.
  - **Functionality:**
    - Checks the status of the Administrator account.
    - Enables the Administrator account and sets a specified password if it is disabled.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), set the desired password for the Administrator account in the script, and execute.

- **`RemoveUserAndProfile.ps1`**
  - **Description:** Deletes a specified local user and removes their profile folder.
  - **Functionality:**
    - Checks if the user account exists.
    - Deletes the user account and changes ownership of the user's folder to Administrators.
    - Deletes the user's profile folder.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), set the desired username to be deleted in the script, and execute.

- **`ResetBluetoothAndWifi.ps1`**
  - **Description:** Removes all paired Bluetooth devices and resets network configuration including Wi-Fi profiles.
  - **Functionality:**
    - Removes all paired Bluetooth devices.
    - Removes all saved Wi-Fi profiles.
    - Resets network configuration including DNS, IP, firewall, and Winsock settings.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), and execute.

- **`CombinedUserSetupAndReset.ps1`**
  - **Description:** Combines multiple functionalities for setting up and resetting a user environment.
  - **Functionality:**
    - Deletes a specified user and their profile.
    - Creates a new user with a specified password.
    - Removes paired Bluetooth devices and resets network configuration.
  - **User Instructions:** Run the script directly in PowerShell (not in ISE), set the desired usernames and passwords in the script, and execute.
    
## Instructions for Use
- Ensure you run these scripts with administrator privileges.
- Customize the scripts by setting the desired usernames and passwords where applicable.
- Execute the scripts directly in PowerShell (not in ISE).
- Use the `-Test` switch where available to simulate actions without making changes.

By following these instructions, you can effectively manage user accounts and reset network settings on your Windows machines.
