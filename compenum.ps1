$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$LdapPath = "LDAP://" + $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString = $LdapPath + $DistinguishedName
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
$UserAcc = "$domainObj.Name\sarah.hilton"
$UserPass = "Newcastle1988"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($SearchString, $UserAcc, $UserPass)
$Searcher.SearchRoot = $objDomain
# Find by OS using wildcard
$Searcher.filter="(operatingsystem=Windows*)"
#$Searcher.filter="(operatingsystem=Linux*)"
$ObjectSearch = $Searcher.FindAll()
foreach($property in $ObjectSearch.properties)
{
	if ($property.operatingsystem.ToLower().Contains("windows"))
	{
	    write-host "OS:`t`t`t" $property.operatingsystem
	    write-host "samaccounntname:`t"  $property.samaccountname
	    write-host "dns hostname:`t`t" $property.dnshostname
	    write-host "name:`t`t`t" $property.name
	    write-host "SPN:`t`t`t" $property.serviceprincipalname
	    write-host "Last Logon:`t`t" $property.lastlogontimestamp
	    write-host "Pwd last set:`t`t" $property.pwdlastset
	    write-host "Object categorty:`t" $property.objectcategory
	    write-host "User access control:`t" $property.useraccountcontrol
	    write-host "ads path:`t`t" $property.adspath
	    write-host "distinguished name:`t"$property.distinguishedname
	}
	write-host "---"	
}
