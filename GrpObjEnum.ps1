# this command is dependent on the powerview module because of the command get-objectacl - search all objects that are members of admin groups; perform get-objectacl on the object to see what object permissions exist there (excluding the standard windows permissions) 
([adsisearcher]("objectcategory=*")).findall() | foreach-object {foreach ($g in $_.properties.memberof){if ($g.split(",")[0].split("=")[1] -match "Admin"){get-objectacl -samaccountname $_.properties.samaccountname | ? {$_.ActiveDirectoryRights -eq "GenericAll" -or $_.ActiveDirectoryRights -eq "ExtendedRight" -and $_.IdentityReference -ne "NT AUTHORITY\SELF" -and $_.IdentityReference -ne "NT AUTHORITY\SYSTEM"} | select ObjectSID,IdentityReference,ActiveDirectoryRights}}}


# search all objects that are members of any administrative group; print out the object's common name, followed by the admin groups they're part of
([adsisearcher]"objectcategory=*").findall() | foreach-object {foreach($g in $_.properties.memberof){if ($g.split(",")[0].split("=")[1] -match "admin"){write-host $_.properties.cn;$g;write-host `n}}}
