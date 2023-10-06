<# 
 This script builds the LDAP provider path that takes the following format: LDAP://HostName[:Port][/DistinguishedName] and then uses this provider path to perform DirectorySearcher

Section [1] covers the construction of the LDAP Provider Path
-> we will extract information from the output of the following command:
[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

Section [2] covers the DirectorySearcher .NET class that will be used to gather information about SAMAccounts in the Domain via LDAP queries to the DC

Section [3] is a simple loop that goes through the output and grabs the relevant information
#>

# [1] Build the LDAP Provider Path
# Command used to retrieve the current domain's context
$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

# Store the Primary DOmain Controller (PDC) value from the output of the "domain context" command
$PDC = ($domainObj.PdcRoleOwner).Name

# Building the LDAP provider path
$LdapPath = "LDAP://" + $PDC + "/"

# Store Name value from the output of the "domain context" command 
# replace the '.' with DC= e.g. if the DN=za.tryhackme.com
# the Distinguished Name will be: DC=za,DC=tryhackme,DC=com
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"

# Add the DN to the LdapPath and store it in a variable called $SearchString
# This will provides us with the full LDAP provier path, so we can perform LDAP queries against the DC
$SearchString = $LdapPath + $DistinguishedName

# Print the SearchString to the screen
# LDAP://THMDC.za.tryhackme.com/DC=za,DC=tryhackme,DC=com
#$SearchString

<# Note: you can't complete step [1] with Get-ADDomain cmdlet. GetCurrentDomain() return object is required.
$gd = Get-AdDomain
$RID = $gd.RIDMaster
$DN = "DC="+$gd.Forest.Replace(".", "DC=")
$LDAPSearchString = "LDAP://$RID/$DN"
#>

# [2] Perform LDAP queries against the Domain Controller using the DirectorySearcher Class 
# we can instantiate the `DirectorySearcher` class with the LDAP Provider Path `$SearchString`
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)

# User Information
# *Change As Needed*
$UserAcc = "$domainObj.Name\sarah.hilton"
# za.tryhackme.loc.Name\sarah.hilton
$UserPass = "Newcastle1988"

# Use DirectoryEntry with the DirectorySearcher object and the user's domain account and password
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($SearchString, $UserAcc, $UserPass)

# Setting the Search Root to the Domain Object with the authenticated user 
$Searcher.SearchRoot = $objDomain

# -Filter ------------------------------------------------------------------------------------------
<# set up a filter for the samAccountType attribute. 
This is an attribute that all user, computer, and group objects have. In this case we can supply 0x30000000 (decimal 805306368) #>

# Set the Search Filter.
# Note: the search filter will be overrided by the last filter if you set multiple filters, - this can cause issues
# https://learn.microsoft.com/en-us/windows/win32/adschema/a-samaccounttype convert the hex value to ascii
# 805306368 = Users
# 805306369 = Machines
# $Searcher.filter="samAccountType=805306368"

# Can also search by specifying the "ObjectClass"
#$Searcher.filter="(objectclass=computer)"
#$Searcher.filter="(objectclass=user)"

# Find by OS using wildcard
#$Searcher.filter="(operatingsystem=Windows*)"
#$Searcher.filter="(operatingsystem=Linux*)"

# Filter by Groups - to find nested groups, look at the member property of a Group, and see if another GroupName exists in that field, then search the member property of that group and so on.
#$Searcher.filter="(objectClass=Group)"
#$Searcher.filter="(name=Account Operators)"
#$Searcher.filter="(name=Server Ad*)"
$Searcher.filter="(name=Tier 1*)"
#$Searcher.filter="(name=Protected Users)"
#$Searcher.filter="(name=THMSERVER2)"

# ----------------------------------------------------------------------------------------------------

# Initiate the search
$ObjectSearch = $Searcher.FindAll()


<# [3] Loop that is used to grab relevant information (Clean up)

note the output contains lines like the following:
Path                                    Properties
LDAP://.../CN=Name,CN=Users etc.        {logoncount, codepage, }

From the output we're mostly interested in the properties. We use a double loop to go through each object, then each property and print it to the screen, so that each property is on its own line
#>

# Print out the properties belonging to the retrieved objects [0] ALL [1] If User Filter was applied [2] If Domain Computer was applied
foreach($property in $ObjectSearch.properties)
{
	#[0] ANY and ALL
	<#
	$property
    #>
    
	#[1] DOMAIN USER ACCOUNTS

	#[1.1] ALL DOMAIN USER ACCOUNTS 
	# Obtain information on all  objects
	# Use $property to obtain all object information
	<#
	write-host "Name:" $property.givenname
	write-host "sAMAccountname:" $property.samaccountname
	write-host "UPN:" $property.userprincipalname
	write-host "Department:" $property.department
	write-host "Title:" $property.title
	write-host "Member of:" $property.memberof
	write-host "Last Logon:" $property.lastlogon
	#>
	
	#[1.2] MEMBERS OF ADMIN GROUPS ONLY - WORKING!
	# Search for members who are in any group that has the name "admin"/"Admin" in it	
	# Note: you can replace "admin" and "Admin" with any group name you wish to filter
	<#foreach ($grp in $property.memberof.split("CN="))
	{
	
		if ($grp.contains("admin") -or $grp.contains("Admin"))
		{
			write-host "Name:" $property.givenname
			write-host "sAMAccountname:" $property.samaccountname
			write-host "UPN:" $property.userprincipalname
			write-host "Department:" $property.department
			write-host "Title:" $property.title
			write-host "Member of:" $property.memberof
			write-host "Last Logon:" $property.lastlogon
			write-host "-----------------------------------"
		}
	}#>

	#[2] DOMAIN COMPUTERS 
	# If the Search Filter is set as Computer/Machines
	# Print out Windows and or Linux machines - can specify versioning here to find older machine versions?
	
	# Very very strange... when checking if $property.operatingsystem.contains("Windows") all return vaules are False even though the property's string contains Windows. I'm sure it's a string because it allows you to replace and split etc. Also, whhen replacing "Windows" with another term  and querying that term then the flag becomes True??? wth???
	
	# May have something to do with UTF (who knows)... but when converting the "Windows" string to Lower and then invoking the Contains method, it seems to match up correctly
	
	# example
	<#$bla = $property.operatingsystem.replace("Windows", "Bindows")
	if ($bla.contains("Bindows"))
	{
	    write-host "bakwas" $property.operatingsystem
	}#>
	
	# actual
	<#if ($property.operatingsystem.ToLower().Contains("windows"))
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
	}#>


	#[3] GROUPS
	# objectClass=Group
	#$property.name

	# name=[GroupName] 
	
	<#
	if ($property.member)
    {
        $property.name
        $property.member
    }
    else
    {
        $property
    }
    #>
    
	#$property.member.ToLower().split("CN=")[1]

	# Separator 
	#write-host "---"
	
}
