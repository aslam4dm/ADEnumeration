([ADSISearcher]"(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))").FindAll() | ForEach-Object { $_.Properties["cn"][0] }
