---
date: 2023-08-01T21:00:00+08:00
title: Mysql
navWeight: 90 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Scripting
  - Powershell
  - MySQL
  - db
---

## Example
```Powershell
# Import values with details connexion
. .\values.ps1

$scriptFilePath ="$MyPath\Install\MysqlBase\Script.sql"

# Load the required DLL file (depend on your connector)
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.23\Assemblies\v4.5.2\MySql.Data.dll")

# Load in var the SQL script file
$scriptContent = Get-Content -Path $scriptFilePath -Raw

# Execute the modified SQL script
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{
    ConnectionString = "server=$MysqlIP;uid=$MysqlUser;Port=3306;user id=$MysqlUser;pwd=$MysqlPassword;database=$MysqlDatabase;pooling=false;CharSet=utf8;SslMode=none"
    }
    $sql = New-Object MySql.Data.MySqlClient.MySqlCommand
    $sql.Connection = $Connection
    $sql.CommandText = $scriptContent
    write-host $sql.CommandText
    $Connection.Open()
    $sql.ExecuteNonQuery()
    $Connection.Close()
```