function Get-TervisSQLAnywhereConnections {
    param (
        [Parameter(Mandatory)]$EnvironmentName
    )

    $WCSEnvironmentState = Get-WCSEnvironmentState -EnvironmentName $EnvironmentName
    $SybaseDatabaseEntryDetails = Get-PasswordstateSybaseDatabaseEntryDetails -PasswordID $WCSEnvironmentState.SybaseQCUserPasswordEntryID
    $ConnectionString = $SybaseDatabaseEntryDetails | ConvertTo-SQLAnywhereConnectionString

    Get-SQLAnywhereConnections -ConnectionString $ConnectionString
}