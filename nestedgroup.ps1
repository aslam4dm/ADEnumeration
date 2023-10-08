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
		# if groupname is specified get its members with .member
		if($property.member)
		{
			if ($property.member -like "CN=*")
			{
			    #$property.member.GetType().fullname
				#$property.member is System.DirectoryServices.ResultPropertyValueCollection
				foreach ($item in $property.member) 
				{
				    #$item.gettype().fullname
				    #$item is System.String
				    #e.g. item string: CN=t1_toby.beck5,OU=T1,OU=Admins,DC=za,DC=tryhackme,DC=com
	                if ($item -match $pattern)
	                {
	                    $result = $matches[1]
	                    #e.g. regex match t1_toby.beck5
	                    
	                    $Searcher.filter="(name=$result)"
	                    $search = $Searcher.FindAll()
	                    
	                    foreach($obj in $search)
	                    {
	                        #$obj.properties.objectcategory is System.DirectoryServices.SearchResult
	                        foreach($val in $obj.properties.objectcategory)
	                        {
	                            #$val is System.String
	                            ##e.g. val string: "CN=Person,CN=Schema,CN=Configuration,DC=za,DC=tryhackme,DC=com"
	                            if ($val.Contains("Group"))
		                        {
			                        write-host "Nested Group Detected: " $property.name "->" $result
			                        # Recursion - rerun the function with the FindAll object of the new Group 
			                        
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
   # $result is System.DirectoryServices.SearchResult
	Get-NestedGroupsFromSearchResults -searchResults $result
}
