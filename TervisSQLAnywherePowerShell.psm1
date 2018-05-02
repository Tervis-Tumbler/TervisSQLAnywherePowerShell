function Get-TervisSQLAnywhereConnection {
    param (
        [Parameter(Mandatory)]$EnvironmentName
    )
    $ConnectionString = Get-TervisSQLAnywhereConnectionString -EnvironmentName $EnvironmentName
    Get-SQLAnywhereConnection -ConnectionString $ConnectionString
}

function Remove-TervisSQLAnywhereConnection {
    param (
        [Parameter(Mandatory)]$EnvironmentName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]$ID
    )
    begin {
        $ConnectionString = Get-TervisSQLAnywhereConnectionString -EnvironmentName $EnvironmentName
    }
    process {        
        Remove-SQLAnywhereConnection -ConnectionString $ConnectionString -ID $ID
    }
}

function Get-TervisSQLAnywhereConnectionString {
    param (
        [Parameter(Mandatory)]$EnvironmentName
    )
    $SybaseDatabaseEntryDetails = Get-TervisSQLAnywhereCredential -EnvironmentName $EnvironmentName
    $SybaseDatabaseEntryDetails | ConvertTo-SQLAnywhereConnectionString
}

function Get-TervisSQLAnywhereCredential {
    param (
        [Parameter(Mandatory)]$EnvironmentName
        )
    $WCSEnvironmentState = Get-WCSEnvironmentState -EnvironmentName $EnvironmentName
    Get-PasswordstateSybaseDatabaseEntryDetails -PasswordID $WCSEnvironmentState.SybaseQCUserPasswordEntryID
}

function Invoke-TervisDBUnloadToWCSGitRepository {
    param (
        [Parameter(Mandatory)]$EnvironmentName
    )

    $ConnectionString = Get-TervisSQLAnywhereConnectionString -EnvironmentName $EnvironmentName
    $SybaseDatabaseEntryDetails = Get-TervisSQLAnywhereCredential -EnvironmentName $EnvironmentName
    $DBUnloadOutputPath = "C:\dbunload.sql"
    $DBUnloadOutputPathRemote = $DBUnloadOutputPath | ConvertTo-RemotePath -ComputerName $SybaseDatabaseEntryDetails.ServerName
    $DBUnloadDestinationPath = "$(Get-WCSJavaApplicationGitRepositoryPath)\DBUnload\$($EnvironmentName)"
    
    Invoke-Command -ComputerName $SybaseDatabaseEntryDetails.ServerName -ScriptBlock {
        dbunload -no -c "$using:ConnectionString" -r "$using:DBUnloadOutputPath" -y
    }

    try {
        Move-Item -Path $DBUnloadOutputPathRemote -Destination $DBUnloadDestinationPath -Force -ErrorAction Stop
    } catch {
        throw "No SQL file was generated from DBUnload"
    }
}