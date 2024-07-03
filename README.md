**Windows Local User Management Scripts**

Welcome to the Windows Local User Management Scripts repository, where you'll find a collection of PowerShell scripts designed to streamline the management of local user accounts and system settings on Windows machines. These scripts are particularly useful in environments requiring efficient device deployment and user account management.

### Scripts Overview:

- **CreateUserWithPwd.ps1**
  - **Description:** Automates the creation of a local user account with a password configuration and addition to the Administrators group.
  - **Affected Settings:** Creates a new local user account, sets privacy settings, and skips various Out-of-Box Experience (OOBE) prompts during setup.
  - **Instructions:** 
    - Change `$UserName` variable to desired username.

- **CreateUserOptionalPwd.ps1**
  - **Description:** Automates the creation of a local user account with an optional password configuration and addition to the Administrators group.
  - **Affected Settings:** Creates a new local user account, sets privacy settings, and skips various Out-of-Box Experience (OOBE) prompts during setup.
  - **Instructions:** 
    - Change `$UserName` variable to desired username.
    - Uncomment `$Password` variable and `Set-LocalUser` command to set a password.

- **RemoveUser.ps1**
  - **Description:** Deletes a specified local user account and removes the associated user profile folder.
  - **Affected Settings:** Changes folder ownership to Administrators, deletes the user account and associated files.
  - **Instructions:** 
    - Change `$UserName` variable to the username to be removed.

- **EnableAdministratorAccount.ps1**
  - **Description:** Checks and enables the default Administrator account if it is disabled.
  - **Affected Settings:** Enables the built-in Administrator account, requiring a specified password.
  - **Instructions:** 
    - Replace `'your_password_here'` with the desired password in the `$Password` variable.

### Usage Notes:
- Run these scripts in PowerShell directly or as shortcuts for optimal functionality.
- Avoid running them in PowerShell Integrated Scripting Environment (ISE) due to potential compatibility issues.
- Ensure to review and modify script variables as per your specific environment and security requirements.

These scripts aim to simplify administrative tasks related to user management and system configuration on Windows machines, enhancing operational efficiency and maintaining consistent configuration across deployments.

<sub> Made by TheLuxorious </sub>
<sub> © 2024 TheLuxorious. All rights reserved. </sub>
