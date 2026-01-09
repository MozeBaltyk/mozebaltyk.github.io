---
date: 2023-08-01T21:00:00+08:00
title: Parsing
navWeight: 90 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Scripting
  - Powershell
---

## POO

```Powershell
# Convert your json in object and put it in variable
$a = Get-Content 'D:\temp\mytest.json' -raw | ConvertFrom-Json
$a.update | % {if($_.name -eq 'test1'){$_.version=3.0}}

$a | ConvertTo-Json -depth 32| set-content 'D:\temp\mytestBis.json'
```

## Example updating a XML

```Powershell
#The file we want to change
$xmlFilePath = "$MyPath\EXAMPLE\some.config"

   # Read the XML file content
   $xml = [xml](Get-Content $xmlFilePath)

   $node = $xml.connectionStrings.add | where {$_.name -eq 'MetaData' -And $_.providerName -eq 'MySql.Data.MySqlClient'}
   $node.connectionString = $AuditDB_Value

   $node1 = $xml.connectionStrings.add | where {$_.name -eq 'Account'}
   $node1.connectionString = $Account_Value

   # Save the updated XML back to the file
   $xml.Save($xmlFilePath)

   Write-Host "$xmlFilePath Updated"
```

## Nested loop between a JSON and CSV

```Powershell
# Read the JSON file and convert to a PowerShell object
$jsonContent = Get-Content -Raw -Path ".\example.json" | ConvertFrom-Json

# Read CSV and set a Header to determine the column
$csvState = Import-CSV -Path .\referentials\states.csv -Header "ID", "VALUE"  -Delimiter "`t"
# Convert in object
$csvState | ForEach-Object { $TableState[$_.ID] = $_.VALUE  }

# Loop through the Entities array and look for the state
foreach ($item in $jsonContent.Entities) {
    $stateValue = $item.State

    # Compare the ID and stateValue then get the Value
    $status = ($csvState | Where-Object { $_.'ID' -eq $stateValue }).VALUE

    Write-Host "Status: $status"
}
```


## Sources

https://devblogs.microsoft.com/powershell-community/update-xml-files-using-powershell/
