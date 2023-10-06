$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$LdapPath = "LDAP://" + $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString = $LdapPath + $DistinguishedName
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
# User Information
$UserAcc = "$domainObj.Name\sarah.hilton"
$UserPass = "Newcastle1988"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($SearchString, $UserAcc, $UserPass)
$Searcher.SearchRoot = $objDomain
# Filter by Groups
$Searcher.filter="(objectClass=Group)"
#$Searcher.filter="(name=Example Group*)"
$ObjectSearch = $Searcher.FindAll()
foreach($property in $ObjectSearch.properties)
{
	$property.name
	# if groupname is specified get its members with .member
	if($property.member)
	{
		$property.member
	}
	write-host "---"
}
