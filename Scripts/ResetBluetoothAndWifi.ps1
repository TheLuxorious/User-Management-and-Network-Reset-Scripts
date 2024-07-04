param (
    [switch]$Test
)

# Check for Administrator Privileges
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# ---!!! Run this script as a shortcut or directly in PowerShell; running it in ISE doesn't work !!!---
# This script removes all paired Bluetooth devices and resets network configuration including Wi-Fi profiles.
# Includes a -Test switch to simulate actions without making changes.

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.

# ******** SCRIPT STARTS FROM HERE ********

# --- Part 1: Remove Bluetooth Devices ---

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

# --- Part 2: Remove Wi-Fi Profiles and Reset Network ---

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

# Wait for a few seconds before exiting
Start-Sleep -Seconds 5

# Made by TheLuxorious
# © 2024 TheLuxorious. All rights reserved.
