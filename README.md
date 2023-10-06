Performs AD Object Enumeration using the .Net Class
```
System.DirectoryServices.DirectorySearcher
```
and
```
System.DirectoryServices.DirectoryEntry
```

These Classes are used to query LDAP within the Domain. Note: These are the building block classes used by PowerView for most its enumeration capabilities

[Note] This script was put together to learn about the .NET DirectorySearcher Class that is used by Powerview
[1]
ADE.ps1 contains hardcoded usernam & password, these will need to be changed
[2]
Uncomment the sections that correlate and that you would like to run. Note: these can easily be specifiable with command arguments.
[3]
Come back some day and automate the Nested Group area. At the moment, to determine nested groups, you would have to hardcode the group name in the Searcher Filter section, and then uncomment the Group section of the main loop. Then analyse the members of the group and continue the cycle with the  'member group'

compenum, groupenum and userenum are short scripts taken from ADE, with comments omitted - made for single functionality purposes
