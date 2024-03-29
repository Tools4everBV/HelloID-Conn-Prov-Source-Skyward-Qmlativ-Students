$InformationPreference = "Continue"
$WarningPreference = "Continue"
$ErrorPreference = "Stop"

## Enforce TLS Protocol ##
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

#region Initialize Variables
$config = ConvertFrom-Json $configuration
#endregion Initialize Variables

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

#region Get Data
try{
		#SchoolYears
		$splat = @{
			ModuleName = "District"
			ObjectName = "SchoolYear"
			SearchFields = ("SchoolYearID,Description,IsCurrentYearForProvidedEntity,NumericYear,NextNumericYear") -split ","
			LongSearchCondition = @{
					#HasStudentEntityYearForCurrentSchoolYear
						"ConditionType"= "Equal"
						"FieldName"="IsCurrentYearForProvidedEntity"
						"Value"=1
				}
		}

		$SchoolYear = get_data_objects @splat
		if([string]::IsNullOrEmpty($config.SchoolYearId))
		{
			Write-Information ("Using SchoolYear ID: {0},  Name: {1}" -f $SchoolYear.SchoolYearID,$SchoolYear.Description)
			$config.SchoolYearId = $SchoolYear.SchoolYearID
		}
		
		## STUDENT BASE DATA ##
		#Students
		$splat = @{
			ModuleName = "Student"
			ObjectName = "Student"
			SearchFields = ( ("GradYear,Grade,GradeNumeric,GraduationDate,IsCurrentActive,IsGraduated,MaskedStudentNumber,NameID,StudentID,StudentNumber") -split ",")
			<#LongSearchCondition = @{
					#IsCurrentActive
						"ConditionType"= "Equal"
						"FieldName"="IsCurrentActive"
						"Value"=1
			}#>
            
		}
		$Students = get_data_objects @splat

		#Staff  (used for Roster Group Names)
		$splat = @{
			ModuleName = "Staff"
			ObjectName = "Staff"
			SearchFields = ( ("StaffID,FullNameFL,FullNameFML,IsActiveForDistrict,IsCurrentStaffEntityYear,NameID,StaffNumber") -split ",")
		}
		$Staff = get_data_objects @splat
        $Staff_ht_StaffID = $Staff | Group-ObjectHashtable -Property 'StaffID'
		
		#Demographic Name
		$splat = @{
			ModuleName = "Demographics"
			ObjectName = "Name"
			SearchFields = ("NameID,Age,BirthDate,CalculatedPrimaryFormattedPhoneNumber,FirstName,FullNameFL,Gender,Initials,IsCurrentStudent,IsStudentInDistrict,IsStudentName,LastName,MiddleName,NameKey,SkywardID" -split ',')
			<#LongSearchCondition = @{
				"ConditionType"= "Equal"
				"FieldName"="IsStudentInDistrict"
				"Value"=1
			}#>
		}
		$Demographics = get_data_objects @splat
		$Demographics_ht = $Demographics | Group-ObjectHashtable -Property 'NameID'

		#Email Types
		$splat = @{
			ModuleName = "Demographics"
			ObjectName = "EmailType"
			SearchFields = ("EmailTypeID,Code,CodeDescription,Description" -split ',')
		}
		$EmailType = get_data_objects @splat
		$EmailType_ht = $EmailType | Group-Object 'EmailTypeID' -AsHashTable -AsString

		#Demographic Emails
		$splat = @{
			ModuleName = "Demographics"
			ObjectName = "NameEmail"
			SearchFields = ("NameEmailID,EmailAddress,EmailTypeID,NameID,Note,Rank" -split ',')
			LongSearchCondition = @{
				"ConditionType"= "Equal"
				"FieldName"="Rank"
				"Value"=1
			}
		}
		$Email = get_data_objects @splat
        $Email | % {$_ | Add-Member -Force -NotePropertyName 'EmailTypeDescription' -NotePropertyValue ($(if ($null -ne $EmailType_ht["$($_.EmailTypeID)"]){$EmailType_ht["$($_.EmailTypeID)"][0].description}else{''}))}
		$Email_ht = $Email | Group-ObjectHashtable -Property 'NameID'
		$Email_empty = @{}
		$Email[0].PSObject.Properties.ForEach({$Email_empty[$_.name -Replace '\W','_'] = ''})

		#Enrollment EntryWithdrawal
		$splat = @{
			ModuleName = "Enrollment"
			ObjectName = "EntryWithdrawal"
			SearchFields = ("EntryWithdrawalID,EndDate,EntityID,IsDefaultEntity,SchoolID,SchoolYearID,StartDate,StudentID,StudentTypeID,WithdrawalDate" -split ',')
		}
		$Enrollments = get_data_objects @splat
		$Enrollments_ht = $Enrollments | Group-ObjectHashtable -Property 'StudentID'
		$Enrollments_empty = @{}
			$Enrollments[0].PSObject.Properties.ForEach({$Enrollments_empty[$_.name -Replace '\W','_'] = ''})
		
		#Student Types
		$splat = @{
			ModuleName = "Enrollment"
			ObjectName = "StudentType"
			SearchFields = ("StudentTypeID,Code,CodeDescription,Description" -split ',')
		}
		$StudentTypes = get_data_objects @splat
		$StudentTypes_ht = $StudentTypes | Group-Object StudentTypeID -AsHashTable -AsString
		$StudentTypes_empty = @{}
			$StudentTypes[0].PSObject.Properties.ForEach({$StudentTypes_empty[$_.name -Replace '\W','_'] = ''})

		## CLASSES DATA ##
		#StudentSection
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "StudentSection"
			#SearchFields = ('EndDate,EntityIDCourse,IsCurrentStudentSection,IsForCurrentSchoolYear,SchoolYearIDCourse,SectionID,StartDate,Status,StatusCode,StatusString,StudentID,StudentSectionCode,StudentSectionID,TransferCourseName,TransferDistrictName' -split ',') #' -split ',')   # ,IsFutureEnrolled,IsPreviouslyEnrolled
            SearchFields = ('StudentSectionID,EndDate,SectionID,StartDate,Status,StatusCode,StatusString,StudentID' -split ',') #' -split ',')   # ,IsFutureEnrolled,IsPreviouslyEnrolled
			LongSearchCondition = @{
				"ConditionType"= "Equal"
				"FieldName"="IsForCurrentSchoolYear"
				"Value"=1
			}
		}
		$StudentSection = get_data_objects @splat
		$StudentSection_ht = $StudentSection | Group-ObjectHashtable -Property 'StudentID'
		$StudentSection_empty = @{}
			$StudentSection[0].PSObject.Properties.ForEach({$StudentSection_empty[$_.name -Replace '\W','_'] = ''})

        # Meet
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "Meet"
			SearchFields = ('MeetID,SectionID' -split ',')
		}
		$Meet = get_data_objects @splat
		$Meet_ht = $Meet | Group-ObjectHashtable -Property 'SectionID'
        
        # StaffMeet
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "StaffMeet"
			SearchFields = ('MeetID,HasGradebookAccess,SectionID,StaffID,IsPrimary' -split ',')
		}
		$StaffMeet = get_data_objects @splat
		$StaffMeet_ht_MeetID = $StaffMeet | Group-ObjectHashtable -Property 'MeetID'
        $StaffMeet_ht_SectionID = $StaffMeet | Group-ObjectHashtable -Property 'SectionID'

        # MeetSummary
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "MeetSummary"
            SearchFields = ('MeetID,Period,Days,IsPrimary' -split ',')
		}
		$MeetSummary = get_data_objects @splat
		$MeetSummary_ht = $MeetSummary | Group-ObjectHashtable -Property 'MeetID'

		#Sections
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "Section"
            SearchFields = ('SectionID,Code,CourseCodeSectionCode,CourseCodeSectionCodeCourseDescription,CourseDescriptionCodeSectionCode,CourseID,EffectiveTeacherFirstLastName,EntityCodeTeacherNumber,EntityID,IsActive' -split ',')
		}
		$Section = get_data_objects @splat
		$Section_ht = $Section | Group-ObjectHashtable -Property 'SectionID'
		$Section_empty = @{}
			$Section[0].PSObject.Properties.ForEach({$Section_empty[$_.name -Replace '\W','_'] = ''})
		
		#Courses
		$splat = @{
			ModuleName = "Scheduling"
			ObjectName = "Course"
            SearchFields = ('CourseID,CodeDescription,CourseCode,CourseGroupDescriptions,DepartmentID,Description,EntityID' -split ',')
		}
		$Course = get_data_objects @splat
		$Course_ht = $Course | Group-ObjectHashtable -Property 'CourseID'
		$Course_empty = @{}
			$Course[0].PSObject.Properties.ForEach({$Course_empty[$_.name -Replace '\W','_'] = ''})

		#### SCHOOL DATA ####
        #School
		$splat = @{
			ModuleName = "Enrollment"
			ObjectName = "School"
            SearchFields = ('SchoolID,BuildingID,Name,StaffIDPrincipal,Type' -split ',')
		}
		$School = get_data_objects @splat
		$School_ht = $School | Group-Object SchoolID -AsHashTable -AsString
		$School_empty = @{}
			$School[0].PSObject.Properties.ForEach({$School_empty[$_.name -Replace '\W','_'] = ''})

        #EntitySchool
		$splat = @{
			ModuleName = "Enrollment"
			ObjectName = "EntitySchool"
			SearchFields = ('EntitySchoolID,EntityID,IsDefaultEntityForSchool,IsDefaultSchoolForEntity,IsOnlySchoolInEntity,SchoolID' -split ',')
		}
		$EntitySchool = get_data_objects @splat
		$EntitySchool_ht_EntityID = $EntitySchool | Group-Object EntityID -AsHashTable -AsString
		$EntitySchool_ht_SchoolID = $EntitySchool | Group-Object SchoolID -AsHashTable -AsString
		$EntitySchool_empty = @{}
			$EntitySchool[0].PSObject.Properties.ForEach({$EntitySchool_empty[$_.name -Replace '\W','_'] = ''})
		
		#### USERDATA ####
		$splat = @{
			ModuleName = "Security"
			ObjectName = "User"
			SearchFields = ('NameID,Username' -split ',')
			LongSearchCondition = @{
				"ConditionType"= "Equal"
				"FieldName"="IsActive"
				"Value"=1
			}
		}
		$User = get_data_objects @splat
		$User_ht = $User | Group-ObjectHashtable -Property 'NameID'
}
catch
{
    Write-Error -Verbose $_
    throw $_   
}
#endregion Get Data

#region Process Return Model
	foreach($p in $Students)
	{
		$person = [ordered]@{
			ExternalId = $p.NameID
			DisplayName = "{0} ({1})" -f $Demographics_ht["$($p.NameID)"].FullNameFL, $p.StudentNumber 
		}
		#Student Fields
		foreach($prop in $p.PSObject.properties)
		{
			$person[$prop.Name] = "{0}" -f $prop.Value
		}
		
		#Demographic Data
		$person["demographic"] = $Demographics_ht["$($p.NameID)"][0]
		
		#Email Data - Only returns the first Rank 1 Email.
		$person["Email"] = $Email_empty
		if($null -ne $Email_ht["$($p.NameID)"])
		{
			$person["Email"] = ($Email_ht["$($p.NameID)"] | Sort-Object 'EmailTypeID')[0]
		}
		
		#Skyward Username
		$person["Username"] = ""
		if($null -ne $User_ht["$($p.NameID)"])
		{
			$person["Username"] = $User_ht["$($p.NameID)"][0].Username
		}	
		
		### Process Contracts
		# Base Student School Enrollment
		$person["Contracts"] = [System.Collections.Generic.List[psobject]]::new()
		foreach($enrollment in $Enrollments_ht["$($p.StudentID)"])
		{
			$_StudentType	= $(if($null -ne $StudentTypes_ht["$($enrollment.StudentTypeID)"]){$StudentTypes_ht["$($enrollment.StudentTypeID)"][0]}else{$StudentTypes_empty})
			$_School			= $(if($null -ne $School_ht["$($enrollment.SchoolID)"]){$School_ht["$($enrollment.SchoolID)"][0]}else{$School_empty})

			$contract = [ordered]@{
				externalID 			= "{0}" -f $enrollment.EntryWithdrawalID
				Sequence 			= 1
				Start 				= $enrollment.StartDate
				End 				= $enrollment.EndDate
				DepartmentName 		= $_School.Name
				DepartmentID 		= "{0}" -f $_School.SchoolID
				TypeCode			= "{0}" -f $_StudentType.Code
				TypeDescription		= $_StudentType.Description
				Status 				= "{0}" -f $p.IsCurrentActive
				Team_ExternalID 	= ''
				Team_Code			= ''
				Team_Name			= ''
				Manager_DisplayName = ''
			}
            # Bump up priority for Default Entity
            if($enrollment.IsDefaultEntity)
            {
                $contract.Sequence = 0
            }
            
			$person["Contracts"].Add($contract)
		}
		
		# Class Enrollments
		foreach($ss in $StudentSection_ht["$($p.StudentID)"])
		{
			$_Section	= $Section_ht["$($ss.SectionID)"][0]
			$_Course		= $Course_ht["$($_Section.CourseID)"][0]
			$_School		= $(if($null -ne $EntitySchool_ht_EntityID["$($_Section.EntityID)"]){$School_ht["$((($EntitySchool_ht_EntityID["$($_Section.EntityID)"] | Sort-Object "IsDefaultSchoolForEntity" -Descending)[0].SchoolID))"][0]}else{$School_empty})
			
			$contract = [ordered]@{
				externalID 			= "{0}" -f $ss.StudentSectionID
				Sequence 			= 2
				Start 				= $ss.StartDate
				End 				= $ss.EndDate
				DepartmentName 		= $_School.Name
				DepartmentID 		= "{0}" -f $_School.SchoolID
				TypeCode			= ""
				TypeDescription		= ""
				Status 				= $ss.Status
				Team_ExternalID 	= '{0}' -f $_Course.CourseID
				Team_Code			= '{0}' -f $_Course.CourseCode 
				Team_Name			= '{0}' -f $_Course.Description
				Manager_DisplayName = '{0}' -f $_Section.EffectiveTeacherFirstLastName
			}
			
			$person["Contracts"].Add($contract)
		}
		
	    $person | ConvertTo-JSON -depth 20
        
	}
#endregion Process Return Model
