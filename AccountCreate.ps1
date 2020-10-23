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
$p = $person | ConvertFrom-Json;
$m = $manager | ConvertFrom-Json;
$config = ConvertFrom-Json $configuration 
$success = $False;
$auditMessage = "for person " + $p.DisplayName;
$script:url = $config.Url
$ApiKey = $config.apikey
$t4eUserGroupGuidUrl = $config.t4eUserGroupGuid
$t4UpdateGuidUrl = $config.t4eUpdateGuid


#Change mapping here
$account = [PSCustomObject]@{
    EmployeeId = $p.externalId      # Employee Number AFAS
    UserId     = $p.Accounts.MicrosoftActiveDirectory.SamAccountName; # UserName Ultmio (User AD)
}

if (-Not($dryRun -eq $true)) {
    try {
      
        $createUserRequest = @{       
            _AuthId      = "$((Get-Date).ToString("yyyyMMddhhmmssMs"))"
            _AuthEmpId   = $account.EmployeeId 
            _AuthUserId  = $account.UserId 
            _AuthGroupId = ""    
        } | ConvertTo-Json 

        $userResult = ( Invoke-UltimoRestMethod -EndpointUrl $t4UpdateGuidUrl -ApiKey $ApiKey -body $createUserRequest).properties.message
        # TODO Function is not fully functional in Ultimo (When this is done the error handling must be modified)
        if ( $userResult -match "Geen medewerker gevonden") {  
            throw $userResult
        }
        #TODO 
        # If Users already exist (Get user) At moment of writing the connector in Ultimo is not implemented  ?
       
        $filter = @{
            filteruserid = $account.UserId
        } | ConvertTo-Json
        $userResult = ( Invoke-UltimoRestMethod -EndpointUrl $t4eUserGroupGuidUrl -ApiKey $ApiKey -body $filter ).properties.Output.collection

        if ($userResult) {
            write-verbose -verbose ($userResult | ConvertTo-Json)
            write-verbose "Correlation found user record $($userResult.UserId)" -verbose
        }    

        $accountRef = $account.UserId
        $auditMessage = ": Successfully"
        $success = $true
    } catch {
        $auditMessage = ": $($_.Exception.Message)"
    }
}


#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $accountRef
    AuditDetails     = $auditMessage;
    Account          = $account;
};

#send result back
Write-Output $result | ConvertTo-Json -Depth 10