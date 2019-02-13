## Author Tim Novice 2019
## Script to import Invoice data from M1 SQL DB and convert to XML

## Replace with the name of your SQLServer
$SQLserver = "SQLsvr01"

## Replace with the name of your Database
$SQLDBName = "My_DB"

## Best not to use sa - create a db account for reporting. Use that here
$uid = "MyDomain/sa"

## Replace with the passwrod for the db account used above 
$pwd = "xyz"

## Adjust below, adding path for output file relevant to your setup
$XMLOutputFile = "C:\Reports\Report.xml"

## Dummy SQL query - add your quesry below within quotes as per example
$SqlQuery = "SELECT [abc].[def], 
    FROM [My_DB].[dbo].[abc] [def]
    ORDER BY [abc].[def];"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLserver; Database = $SQLDBName; User ID = $uid; Password = $pwd; Integrated Security=True;"
$SqlCmd = new-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdaptor = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdaptor.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdaptor.Fill($DataSet)
$SqlConnection.close()

## Creates base XML file with organized SQL query data results
($DataSet.GetXML()).Replace('NewDataSet','OuterTagName').Replace('Table','InnerTagName') | SET-CONTENT -PATH $XMLOutputFile
$content = GET-CONTENT  $XMLOutputFile

## Pipes XML content into a Foreach loop for regex to insert sequential item tag ID for reading XML
$content | ForEach-Object {
        [Regex]::Replace($_, '<InnerTagName', {
        return '<InnerTagName id="' + ($global:counter += 1) + '"'
    })
} | SET-CONTENT $XMLOutputFile
