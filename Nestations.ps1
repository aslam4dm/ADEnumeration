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
        [System.DirectoryServices.SearchResult]$searchResults,
        [string]$indent = "",
        [int]$nestation = 0,
        [int]$level = 0
    )
    
    # Initialize an empty array to store results
    $results = @()
    #$ng = 0

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
									$line = ("_" * $level)
									if ($nestation -eq 0)
									{ 
			                            write-host "|$line" -nonewline
			                            write-host "[TLG] " -foreground yellow -nonewline 
			                            write-host $property.name -foreground cyan
			                            $nestation+=1
			                        }
			                        $line = ("__" * $level)
			                        write-host "|$line[ng $nestation]" $result
			                        # new group separator  
			                        #$ng=1
			                        # Recursion - rerun the function with the FindAll object of the new Group 
			                        
			                        Get-NestedGroupsFromSearchResults -searchResults $obj -level ($level+1) -nestation ($nestation+1) 
		                        }
		                    }
	                    }
	                }
	            }
			}
		}
		<#
		if ($ng -eq 1)
		{
			#write-host "|"
		}#>
	}
}

$ObjectSearch = $Searcher.FindAll()
foreach($result in $ObjectSearch)
{
   # $result is System.DirectoryServices.SearchResult
	Get-NestedGroupsFromSearchResults -searchResults $result -level 1 -nestation 0
}
