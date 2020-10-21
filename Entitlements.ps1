#region Configuration Data
$config = ConvertFrom-Json $configuration 

$script:url = ($config.Url).TrimEnd("/")
$apiKey = $config.Apikey
$t4eGroupGuidUrl = $config.t4eGroupGuid
#endregion Configuration Data

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

try {
    $resultGroup = (Invoke-UltimoRestMethod -EndpointUrl $t4eGroupGuidUrl -ApiKey $ApiKey).properties.data
} catch {
    Write-Verbose =verbose "$($_.Exception.Message)"
}


# Group persmission formatter HelloID
$permissions = [System.Collections.Generic.List[psobject]]::new()
foreach ($g in $resultGroup) {
    $permission = @{
        DisplayName    = $g.groupid
        Identification = @{
            Id = $g.groupid
        }
    }
    $permissions.add( $permission )
}
   

Write-Output ($permissions | ConvertTo-Json)