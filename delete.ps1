#region Functions
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

#Initialize default properties
$config = ConvertFrom-Json $configuration
$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json;
$success = $False;
$auditMessage = $p.DisplayName;

$script:url = $config.Url 
$ApiKey = $config.apikey
$t4eUserGroupGuidUrl = $config.t4eUserGroupGuid
$t4UpdateGuidUrl = $config.t4eUpdateGuid

#Change mapping here 
$account = [PSCustomObject]@{
    EmployeeId = $p.externalId  # Employee Number
    UserId     = $aRef              # UserName Ultmio (User AD)
}

if (-Not($dryRun -eq $true)) { 
    try { 
        $UpdateUserRequest = @{       
            _AuthId      = "$((Get-Date).ToString("yyyyMMddhhmmssMs"))"
            _AuthEmpId   = $account.EmployeeId 
            _AuthUserId  = $account.UserId 
            _AuthGroupId = ""
        } | ConvertTo-Json 
       
        $userResult = ( Invoke-UltimoRestMethod -EndpointUrl $t4UpdateGuidUrl -ApiKey $ApiKey -body $UpdateUserRequest).properties.message
      
        if ( $userResult -match "Geen medewerker gevonden") {  
            throw $userResult
        }     
        $auditMessage = "Successfully"
        $success = $true
     
    } catch {
        $auditMessage = " : $($_.Exception.Message)"
    }
}
    

#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $aRef
    AuditDetails     = $auditMessage;
    Account          = $account; 
};

#send result back
Write-Output $result | ConvertTo-Json -Depth 10
