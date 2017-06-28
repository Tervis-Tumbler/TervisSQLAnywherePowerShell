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
    $WCSEnvironmentState = Get-WCSEnvironmentState -EnvironmentName $EnvironmentName
    $SybaseDatabaseEntryDetails = Get-PasswordstateSybaseDatabaseEntryDetails -PasswordID $WCSEnvironmentState.SybaseQCUserPasswordEntryID
    $SybaseDatabaseEntryDetails | ConvertTo-SQLAnywhereConnectionString
}