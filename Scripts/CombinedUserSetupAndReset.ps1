param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell; running it in ISE doesn't work !!!---
# This script combines multiple functionalities for setting up and resetting a user environment.
# It deletes a specified user and their profile, creates a new user, removes paired Bluetooth devices, resets Wi-Fi profiles and network configuration
# Includes a -Test switch to simulate actions without making changes.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# Set the username for the new user.
$UserName = 'your_username_here'

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

# --- Part 1: Remove User and Profile ---

# --Check if User Account Exists--
$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

# --User Account Exists Condition--
if ($UserAccount) {
    if ($Test) {
        Write-Host "[Test Mode] Would delete user '$UserName' and their profile folder."
    } else {
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
    }
} else {
    if (-not $Test) {
        Write-Host "User '$UserName' doesn't exist."
    }
}


# --- Part 2: Create User ---

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
        Add-LocalGroupMember -Group "Users" -Member $UserName 2>&1 | Out-Null
        Write-Host "User '$UserName' created successfully."
    } else {
        Write-Host "[Test Mode] Would create user '$UserName' and add to Administrators group."
    }
} else {
    if (-not $Test) {
        Write-Host "User '$UserName' already exists."
    }
}

# --Set or Change User Password--
if (-not $Test) {
    $password = Read-Password -Prompt "Enter password for user '$UserName'"
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    Set-LocalUser -Name $UserName -Password $securePassword 2>&1 | Out-Null
    Write-Host "Password for user '$UserName' has been set/changed successfully."
} else {
    Write-Host "[Test Mode] Would prompt for and set password for user '$UserName'."
}

# --- Part 3: Remove Bluetooth Devices ---

# --Import Bluetooth Removal Function--
$Source = @"
    [DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
    [return: MarshalAs(UnmanagedType.U4)]
    static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);
    public static UInt32 Unpair(UInt64 BTAddress) {
        GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
        IntPtr pAddress     = pinnedAddr.AddrOfPinnedObject();
        UInt32 result       = BluetoothRemoveDevice(pAddress);
        pinnedAddr.Free();
        return result;
    }
"@

# --Get Bluetooth Device Information--
Function Get-BTDevice {
    Get-PnpDevice -class Bluetooth |
        ?{$_.HardwareID -match 'DEV_'} |
            select Status, Class, FriendlyName, HardwareID,
                @{N='Address';E={[uInt64]('0x{0}' -f $_.HardwareID[0].Substring(12))}}
}

# --Initialize Bluetooth Remover and Get Devices--
$BTR       = Add-Type -MemberDefinition $Source -Name "BTRemover" -Namespace "BStuff" -PassThru
$BTDevices = @(Get-BTDevice)

# --Loop for Bluetooth Device Removal--
$RemovedDevices = @()

If ($BTDevices.Count) {
    ForEach ($device in $BTDevices) {
        if ($Test) {
            $RemovedDevices += "[Test Mode] Would remove device: $($device.FriendlyName) ($($device.Address))"
        } else {
            $Result = $BTR::Unpair($device.Address)
            If (!$Result) {
                $RemovedDevices += "Removed device: $($device.FriendlyName) ($($device.Address))"
            } Else {
                $RemovedDevices += "Error removing device: $($device.FriendlyName) ($($device.Address)), Return code: $Result"
            }
        }
    }
}

# --Display Removed Devices--
$RemovedDevices | ForEach-Object { Write-Host $_ }

# If no devices were found
if ($RemovedDevices.Count -eq 0) {
    Write-Host "No Bluetooth devices found."
}

# --- Part 4: Remove Wi-Fi Profiles and Reset Network ---

# Remove all Wi-Fi profiles
$list = ((netsh.exe wlan show profiles) -match '\s{2,}:\s') -replace '.*:\s' , ''
Foreach ($item in $list) {
    if ($Test) {
        Write-Host "[Test Mode] Would remove Wi-Fi profile: $item"
    } else {
        Netsh.exe wlan delete profile name="$item" 2>&1 | Out-Null
    }
}

# Reset Network Configuration
if (-not $Test) {
    ipconfig /flushdns 2>&1 | Out-Null
    ipconfig /release 2>&1 | Out-Null
    ipconfig /renew 2>&1 | Out-Null
    netsh int ip reset 2>&1 | Out-Null
    netsh advfirewall reset 2>&1 | Out-Null
    netsh winsock reset 2>&1 | Out-Null
} else {
    Write-Host "[Test Mode] Would reset network configuration."
}

# Restart the system if not in Test mode
if (-not $Test) {
    Write-Host "Restarting the system in 10 seconds..."
    shutdown -f -r -t 10 -d p:5:20
} else {
    Write-Host "[Test Mode] Would restart the system."
}

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
