<cfparam name="TableName" default="">
<cfparam name="DSN" default="JobSite123Dev">

<!--- format the TableName; remove bad chars --->
<cfset TableName = REReplaceNoCase(TableName,"[^A-Za-z_0-9\-]","","ALL")>
<!--- format the TableName; remove bad chars --->

<!--- html header --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>SQL Explorer.TableJoin: <cfoutput>#DSN#<cfif len(TableName)>.#TableName#</cfif></cfoutput></title>
</head>
<body>
<!--- html header --->

<cfif len(TableName)>
	<h1>Table : <cfoutput>#TableName#</cfoutput></h1>

	<!--- retrieve Columns for this Table --->
	<cfdbinfo datasource="#DSN#" name="FieldNames" type="columns" table="#TableName#">
	<!--- retrieve Columns for this Table --->
	
	<!--- retrieve the PrimaryKey from this table --->
	<cfquery name="PrimaryKeyQuery" dbtype="query">
		select Column_Name from FieldNames where is_PrimaryKey = 'YES'
	</cfquery>
	<cfif PrimaryKeyQuery.RecordCount EQ 0>
		<!--- primary key not found; strip first 3 chars from tablename --->
		<cfset PrimaryKey = RemoveChars("#TableName#ID", 1, 3)>
		<!--- primary key not found; strip first 3 chars from tablename --->
	<cfelse>
		<!--- primary key found... use this one --->
		<cfset PrimaryKey = PrimaryKeyQuery.Column_Name>
		<!--- primary key found... use this one --->
	</cfif>
	<!--- retrieve the PrimaryKey from this table --->
	
	<!--- loop through and create the dynamic query --->
	<table border="1" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<th>Default</th>
	<th>Name</th>
	<th>Size</th>
	<th>IS_FK</th>
	<th>NULLABLE</th>
	<th>IS_PK</th>
	<th>PK</th>
	<th>PK_TBL</th>
	<th>Type</th>
	</tr>
	<cfoutput query="FieldNames">
		<tr>
		<td>#COLUMN_DEFAULT_VALUE#&nbsp;</td>
		<td>#COLUMN_NAME#</td>
		<td>#COLUMN_SIZE#</td>
		<td>#IS_FOREIGNKEY#</td>
		<td>#IS_NULLABLE#</td>
		<td>#IS_PRIMARYKEY#</td>
		<td>#REFERENCED_PRIMARYKEY#</td>
		<td>#REFERENCED_PRIMARYKEY_TABLE#</td>
		<td>#TYPE_NAME#</td>
		</tr>
	</cfoutput>
	</table>
	<!--- loop through and create the dynamic query --->

	<!--- show sample data --->
	<cfquery name="SampleData" datasource="#DSN#" maxrows=10>
	select top 10 * from #TableName#
	</cfquery>
	<br><cfdump var="#SampleData#">
	<!--- show sample data --->
	
</cfif>

<!--- html footer --->
</body>
</html>
<!--- html footer --->