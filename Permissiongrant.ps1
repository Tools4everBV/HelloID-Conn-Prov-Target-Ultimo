#region Functions
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls10 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
function Invoke-UltimoRestMethod ($EndpointUrl, $ApiKey, $body , $Proxy) {
    try {        
        $requestUrl = "$($script:url)/$($EndpointUrl)?ApiKey=$ApiKey"    
        $responseRestMethod = Invoke-RestMethod -uri  $requestUrl -Method POST -Body $body  -Proxy:$proxy  -UseBasicParsing -ContentType "application/json"
        Write-Output $responseRestMethod   
    } catch {    
        throw $_.exception.message       
    }
}
#endregion Functions

#region Configuration Data
$success = $False;
$auditMessage = "for person " + $p.DisplayName;
    
$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json;
$pRef = $permissionReference | ConvertFrom-json; 
$config = ConvertFrom-Json $configuration
$script:url = $config.Url 
$ApiKey = $config.apikey
$t4UpdateGuidUrl = $config.t4eUpdateGuid 
#endregion Configuration Data

#Change mapping here
$account = [PSCustomObject]@{
    EmployeeId = $p.externalId  # Employee Number
    UserId     = $aRef          # UserName Ultmio (User AD)
    GroupId    = $pRef.id
}    
    
if (-Not($dryRun -eq $true)) {
    try {   
        $UpdateUserRequest = @{       
            _AuthId      = "$((Get-Date).ToString("yyyyMMddhhmmssMs"))"
            _AuthEmpId   = $account.EmployeeId 
            _AuthUserId  = $account.UserId 
            _AuthGroupId = $account.groupId
        } | ConvertTo-Json 

        $userResult = ( Invoke-UltimoRestMethod -EndpointUrl $t4UpdateGuidUrl -ApiKey $ApiKey -body $UpdateUserRequest).properties.message

        if ( $userResult -match "Geen medewerker gevonden") {  
            throw $userResult
        }   
    
        $auditMessage = " successfully"
        $success = $true
    } catch {
        $auditMessage = " : $($_.Exception.Message)"
    }
}
    
    
#build up result
$result = [PSCustomObject]@{ 
    Success      = $success;
    AuditDetails = $auditMessage;
    Account      = $account;
};
    
Write-Output $result | ConvertTo-Json -Depth 10;