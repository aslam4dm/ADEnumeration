# Regex pattern to identify Members
$pattern="CN=(.*?),"

$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$LdapPath = "LDAP://" + $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString = $LdapPath + $DistinguishedName
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
# User Information
$UserAcc = "$domainObj.Name\damien.horton"
$UserPass = "pABqHYKsG8L7"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($SearchString, $UserAcc, $UserPass)
$Searcher.SearchRoot = $objDomain
# Filter by Groups
$Searcher.filter="(objectClass=Group)"
#$Searcher.filter="(name=Example Group*)"


function Get-NestedGroupsFromSearchResults 
{
    param (
        #[System.DirectoryServices.SearchResultCollection]$searchResults
        [System.DirectoryServices.SearchResult]$searchResults
    )
    
    # Initialize an empty array to store results
    $results = @()

	foreach($property in $searchResults.properties)
	{
		#$property.name
		#write-host "---"
		# if groupname is specified get its members with .member
		if($property.member)
		{
			if ($property.member -like "CN=*")
			{
			    #$property.member.GetType().fullname
				
				foreach ($item in $property.member) 
				{
	                if ($item -match $pattern)
	                {
	                    $result = $matches[1]
	                    #Write-Host "Result: $result"
	                    $Searcher.filter="(name=$result)"
	                    $search = $Searcher.FindAll()
	                    foreach($obj in $search)
	                    {
	                        #$obj.properties.objectcategory.gettype().fullname
	                        foreach($val in $obj.properties.objectcategory)
	                        {
	                            if ($val.Contains("Group"))
	                            #if ($obj.Contains("Group"))
		                        {
			                        write-host "Nested Group Detected: " $property.name "->" $result
			                        # Recursion
			                        Get-NestedGroupsFromSearchResults -searchResults $obj
		                        }
		                    }
	                    }
	                }
	            }
			}
		}
	}
}


$ObjectSearch = $Searcher.FindAll()
foreach($result in $ObjectSearch)
{
	Get-NestedGroupsFromSearchResults -searchResults $result
}

