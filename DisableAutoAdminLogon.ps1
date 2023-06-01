Begin {
    #Set global variables
    $directory = "C:\Temp"

    #Log Function
    Function Write-LogEntry {
        param (
            [parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$Value,
            [parameter(Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$FileName = "SetAutoAdminLogonRegistry.log",
            [switch]$Stamp
        )

        #Build Log File appending System Date/Time to output
        $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
        $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
        $Date = (Get-Date -Format "MM-dd-yyyy")

        If ($Stamp) {
            $LogText = "<$($Value) <time=""$($Time)"" date=""$($Date)"">"
        }
        else {
            $LogText = "$($Value)"
        }

        Try {
            Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
        }
        Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
    }
     Function DisableAutoLogin {
        #Create registry file values
         $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
         $AutoLogonPath = "AutoAdminLogon"
         $StatusValue= "0"

         #End script if registry doesn't exist
        if (!(Test-Path $RegKeyPath)) {
	        Exit
        }

        Try {
            Write-Host "Checking value of $AutoLogonPath registry..."
            Write-LogEntry -Value "Checking value of $AutoLogonPath registry..."
            $CheckRegistryValue = Get-ItemProperty -Path $RegKeyPath
            $AutoLogonValue = $CheckRegistryValue.AutoAdminLogon
            Write-Host "Successfully found registry"
            Write-LogEntry -Value "Successfully found registry"
        }       
        Catch [System.Exception] {
            Write-Host " (Failed)"
            Write-LogEntry -Value "Failed to find registry"
        }
        if ($AutoLogonValue -eq "0") {
            Write-Host "Value is already set to 0, ending script"
            Write-LogEntry -Value "Value is already set to 0, ending script"
            exit
        }

        if(!$AutoLogonPath) {
            Write-Host "Value is already set to 0, ending script"
            Write-LogEntry -Value "Value is already set to 0, ending script"
            exit
        }

        Try {
            Write-Host "Value of $AutoLogonPath is $AutoLogonValue"
            Write-LogEntry -Value "Value of $AutoLogonPath is $AutoLogonValue"
            Write-Host "Attempting to change value of $AutoLogonPath to 0"
            Write-LogEntry -Value "Attempting to change value of $AutoLogonPath to 0"
            Set-ItemProperty -Path $RegKeyPath -Name $AutoLogonPath -Value $StatusValue -Force | Out-Null
            Write-Host "Successfully changed value to 0"
            Write-LogEntry -Value "Successfully changed value to 0"
        }
        Catch [System.Exception] {
            Write-Host " (Failed)" $_.Exception
            Write-LogEntry -Value "Failed to find registry"
        }
    }

    Write-LogEntry -Value "##################################"
    Write-LogEntry -Stamp -Value "Set AutoAdminLogon Registry Started"
    Write-LogEntry -Value "##################################"

    Try {
        DisableAutoLogin
    }
    Catch [System.Exception] {
        Write-Warning $_.Exception
        Write-LogEntry -Value "$($_.Exception)"
    }
}
