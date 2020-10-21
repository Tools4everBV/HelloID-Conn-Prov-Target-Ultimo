#region Configuration Data
$config = ConvertFrom-Json $configuration 

$script:url = ($config.Url).TrimEnd("/")
$apiKey = $config.Apikey
$t4eGroupGuidUrl = $config.t4eGroupGuid  # ultimo uses a GUID in the apipoint to get the groups        #Example: https://coloriet.ultimo.com/api/V1/Action/56ea89e2-2dfe-42da-f11a-234e38706d80?
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

try{
    $resultGroup= (Invoke-UltimoRestMethod -EndpointUrl $t4eGroupGuidUrl -ApiKey $ApiKey).properties.data
}catch{
    Write-Verbose =verbose "$($_.Exception.Message)"
}


# Group Persmission Formatter HELLOID
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
   

Write-Output ($permissions |ConvertTo-Json)