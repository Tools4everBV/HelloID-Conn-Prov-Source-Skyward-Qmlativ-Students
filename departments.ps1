$config = ConvertFrom-Json $configuration;

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

#region Support Functions
function Group-ObjectHashtable {
    param
    (
        [string[]]
        $Property
    )

    begin
    {
        # create an empty hashtable
        $hashtable = @{}
    }

    process
    {
        # create a key based on the submitted properties, and turn it into a string
        $key = $(foreach($prop in $Property) { $_.$prop }) -join ','
        
        # check to see if the key is present already
        if ($hashtable.ContainsKey($key) -eq $false)
        {
        # add an empty array list 
        $hashtable[$key] = [Collections.Arraylist]@()
        }

        # add element to appropriate array list:
        $null = $hashtable[$key].Add($_)
    }

    end
    {
        # return the entire hashtable:
        $hashtable
    }
}

function get_oauth_access_token {
    [cmdletbinding()]
    Param (
        [string]$ClientKey,
        [string]$ClientSecret,
        [string]$IntegrationKey
    )
    Process
    {
        $headers = @{ 
                            "Content-Type" = "application/x-www-form-urlencoded"
                            "Suppress-Development-Permissions" = $true
        }

        $body = "grant_type=client_credentials&client_id={0}&client_secret={1}" -f [System.Web.HttpUtility]::UrlEncode($ClientKey), [System.Web.HttpUtility]::UrlEncode($ClientSecret)
        
        $uri =  "https://skyward-api.global.cloud.nimsuite.com/{0}/oauth/token" -f $IntegrationKey
        Write-Information ($uri)
        try{
        $result = Invoke-RestMethod -Method POST -Headers $headers -Uri $uri -Body $body -UseBasicParsing
        }catch
        {
            Write-Information ($error[0].exception.innerexception)
        }
        @($result)
    }
}
  
function get_data_objects {
    [cmdletbinding()]
    Param (
        [string]$ModuleName,
        [string]$ObjectName,
        [array]$SearchFields = @('*'),
        [System.Collections.Hashtable]$LongSearchCondition = @{}
    )
    Process
    {
        #######ACCESS TOKEN##########
        Write-Information ("Retrieving Access Token - {0}" -f (Get-Date))
         
        $AccessToken = (get_oauth_access_token `
            -ClientKey $config.ClientKey `
            -ClientSecret $config.ClientSecret `
            -IntegrationKey $config.IntegrationKey).access_token
         
        $headers = @{ Authorization = "Bearer $($AccessToken)" }
        
        #####GET DATA########
        Write-Information "Getting Data Objects for ( $($ModuleName) : $($ObjectName) )"
        Write-Information "Search Fields: $($SearchFields)"
        $result = [System.Collections.Generic.List[object]]::new()
        $object_uri = "$($config.BaseURI)/Generic/$($config.EntityId)/$($ModuleName)/$($ObjectName)"
        $page_uri = "$($object_uri)/1/$($config.PageSize)"
        $request_params = @{}
        
        #--SCHOOL YEAR--#
        if($config.SchoolYearId.Length -gt 0)
        {
            $request_params['SchoolYearID'] = "$($config.SchoolYearId)"
            Write-Verbose "Enforcing SchoolYearID $($config.SchoolYearId)"
        }
        
        #--FISCAL YEAR--#
        if($config.FiscalYearId.Length -gt 0)
        {
            $request_params['FiscalYearID'] = "$($config.FiscalYearId)"
            Write-Verbose "Enforcing FiscalYearID $($config.FiscalYearId)"
        }
        
        #--SEARCH FIELDS--#                
        if($SearchFields.Length -gt 0 -OR $null -eq $SearchFields)
        {
            # WILDCARD CHECK #
            if(($SearchFields.Length -eq 1 -AND $SearchFields[0] -eq "*") -OR $null -eq $SearchFields)
            {
                $fields_uri = "$($config.BaseURI)/Generic/$($config.EntityId)/$($ModuleName)/$($ObjectName)"
                $fields_result = Invoke-RestMethod -Method GET -Uri $fields_uri -Headers $headers -UseBasicParsing
                $SearchFields = $fields_result.psobject.Properties | ? Name -notin "ValidationRules","Relationships" | Select-Object -ExpandProperty Name 
                Write-Information "Search Fields: $($SearchFields)"
            }

            $i = 0
            foreach ($field in $SearchFields)
            {
                $request_params["searchFields[$($i)]"] = "$($field)"
                $i++
            }
        }
        $page_result = $null

        # Handle the LongSearchCondition logic. This uses a POST instead of a GET call.
        if($LongSearchCondition.Count -gt 0){
            Write-Information 'LongSearchCondition Detected.  Using POST Logic.'
            $body_params = @{
                "SearchCondition" = @{
                    "LongSearchCondition" = $LongSearchCondition
                }
            }

            $query_params = "?"
            #--SEARCH FIELDS--#                
            if($SearchFields.Length -gt 0)
            {
                $i = 0
                foreach ($field in $SearchFields)
                {
                    $query_params = $query_params + "searchFields[$($i)]=" + "$($field)&";
                    $i++;
                }
            }

            #--SCHOOL YEAR--#
            if($config.SchoolYearId.Length -gt 0)
            {
                $query_params = $query_params + "SchoolYearID=$($config.SchoolYearId)&";
                Write-Verbose "Enforcing SchoolYearID $($config.SchoolYearId)";
            }
 
            #--FISCAL YEAR--#
            if($config.FiscalYearId.Length -gt 0)
            {
                $query_params = $query_params + "FiscalYearID=$($config.FiscalYearId)&";
                Write-Verbose "Enforcing FiscalYearID $($config.FiscalYearId)";
            }
            
            #Write-Verbose -Verbose ($page_uri + $query_params)
            $page_result = Invoke-RestMethod -Method POST -Uri ($page_uri + $query_params) -Body ($body_params | ConvertTo-Json) -Headers $headers -ContentType 'application/json' -UseBasicParsing;
        } else 
        {
            $page_result = Invoke-RestMethod -Method GET -Uri $page_uri -Headers $headers -UseBasicParsing -body $request_params
        }

        $previous_page_uri = $page_uri
        $next_page_uri = "$($config.BaseURI)$($page_result.Paging.Next)"
        
        Write-Verbose ("URI: {0}" -f $page_uri)
        Write-Verbose ("Query Params: {0}" -f $query_params)
        Write-Verbose ("Headers: {0}" -f ($headers | ConvertTo-Json))
        Write-Verbose ("Request_Params: {0}" -f ($request_params | ConvertTo-Json))

        if($page_result.Objects.Count -eq 0)
        {
            Write-Information "No Objects returned.  Returning entire Page_Result object."
            $result.Add($page_result)
        }
        else
        {
            Write-Information "Querying $($ModuleName)/$($ObjectName), $($page_result.Objects.Count) Record(s) returned"
            $result.AddRange($page_result.Objects)
        
            while($next_page_uri -ne $config.BaseURI -and $next_page_uri -ne $previous_page_uri)
            {
                $next_page_uri = "$($next_page_uri)"
                Write-Information "Next Page URI: $next_page_uri"
                $page_result = $null
                try{
                    if($LongSearchCondition.Count -gt 0)
                    {
                        #Write-Information ("New URI: {0}" -f ($next_page_uri + $query_params))
                        $page_result = Invoke-RestMethod -Method POST -Uri ($next_page_uri + $query_params) -Body ($body_params | ConvertTo-Json) -Headers $headers -ContentType 'application/json' -UseBasicParsing;

                    } else
                    {
                        $page_result = Invoke-RestMethod -Method GET -Uri $next_page_uri -Body $request_params -Headers $headers -UseBasicParsing -ErrorAction 'Stop'
                    }
                } catch
                {
                    if ($_.ErrorDetails.Message -Match 'Token has expired')
                    {
                        Write-Warning ("Refreshing Token: {0}" -f ($_ | ConvertTo-JSON))
                        $AccessToken = (get_oauth_access_token `
                            -BaseURI $config.BaseURI `
                            -ClientKey $config.ClientKey `
                            -ClientSecret $config.ClientSecret).access_token
         
                        $headers = @{ Authorization = "Bearer $($AccessToken)" }
                        if($LongSearchCondition.Count -gt 0)
                        {
                            $page_result = Invoke-RestMethod -Method POST -Uri ($next_page_uri + $query_params) -Body ($body_params | ConvertTo-Json) -Headers $headers -ContentType 'application/json' -UseBasicParsing;

                        } else
                        {
                            $page_result = Invoke-RestMethod -Method GET -Uri $next_page_uri -Body $request_params -Headers $headers -UseBasicParsing -ErrorAction 'Stop'
                        }
                    } else
                    {
                        throw $_
                    }
                }
             
                $previous_page_uri = $next_page_uri
                $next_page_uri = "$($config.BaseURI)$($page_result.Paging.Next)"
             
                Write-Information  ("{0} Record(s) returned ({1})" -f $page_result.Objects.Count, ($result.Count + $page_result.Objects.Count))
                $result.AddRange($page_result.Objects)
            }
        }
         
        Remove-Variable -Name "SearchFields" -ErrorAction SilentlyContinue
         
        Write-Information "Total of $($result.Count) Record(s) returned"                
		Write-Information "############################################"
        $result
    }
}
#endregion Support Functions


try{
$Entity = get_data_objects `
        -ModuleName "District" `
        -ObjectName "Entity" `
        -SearchFields @( ("EntityID,Code,CodeName,Name") -split ",")
 
foreach($e in $entity)
{
    $row = @{
              ExternalId = $e.EntityID;
              DisplayName = $e.Name;
              Code = $e.Code
              CodeName = $e.CodeName;
    }
 
    $row | ConvertTo-Json -Depth 10
}
 
}catch
{
    throw $_;
}
