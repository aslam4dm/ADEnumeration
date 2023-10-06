<# Enumerate User Accounts in AD #>
$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$LdapPath = "LDAP://" + $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString = $LdapPath + $DistinguishedName
$SearchString
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
$UserAcc = "$domainObj.Name\sarah.hilton"
$UserPass = "Newcastle1988"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($SearchString, $UserAcc, $UserPass)
$Searcher.SearchRoot = $objDomain
# 805306368 = Users
$Searcher.filter="(objectclass=user)"
$ObjectSearch = $Searcher.FindAll()
foreach($property in $ObjectSearch.properties)
{
	#[1.1] ALL DOMAIN USER ACCOUNTS 
	#$property
	#[1.2] MEMBERS OF SPECIFIED GROUPS E.G. Admin*
	foreach ($grp in $property.memberof.split("CN="))
	{
		if ($grp.contains("admin") -or $grp.contains("Admin"))
		{
			$property
			write-host "---"
		}
	}
	# write-host "---"
}
