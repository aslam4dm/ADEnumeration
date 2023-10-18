[ADSI]"LDAP://DC=yourdomain,DC=com" | 
    Select-Object -ExpandProperty "DontRequirePreAuth" | 
    Where-Object {$_ -eq $true} | 
    ForEach-Object {
        $entry = [ADSI]$_.Path
        $entry.Properties["cn"].Value
    }


/*
[ADSI]"LDAP://DC=yourdomain,DC=com" | 
    Select-Object -ExpandProperty "DontRequirePreAuth" | 
    Where-Object {$_ -eq $true} | 
    ForEach-Object {
        $entry = [ADSI]$_.Path
        $entry.Properties["cn"].Value
    }
    
This script queries Active Directory using LDAP and retrieves user accounts with "Do not require Kerberos preauthentication" enabled. Here's a step-by-step explanation of the script:

[ADSI]"LDAP://DC=yourdomain,DC=com":

This part establishes a connection to the Active Directory using an LDAP query. You should replace "DC=yourdomain,DC=com" with the actual LDAP path to your domain.
Select-Object -ExpandProperty "DontRequirePreAuth":

It selects the property "DontRequirePreAuth" from the LDAP query result. This property represents whether pre-authentication is required for user accounts.
Where-Object {$_ -eq $true}:

This filters the results to include only user accounts where "DontRequirePreAuth" is set to true. In other words, it identifies users who do not require Kerberos preauthentication.
ForEach-Object:

This loop processes each user account that meets the filtering condition.
$entry = [ADSI]$_.Path:

This line creates an ADSI (Active Directory Service Interfaces) object for the user account specified in $_ (the current user being processed). It uses the Path property to access the user's LDAP path.
$entry.Properties["cn"].Value:

This retrieves the Common Name (cn) of the user account. The Common Name is one of the attributes of a user in Active Directory.
*/
