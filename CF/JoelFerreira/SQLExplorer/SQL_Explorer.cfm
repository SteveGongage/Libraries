<cfparam name="TableName" default="">
<cfparam name="DSN" default="JobSite123Dev">

<!--- format the TableName; remove bad chars --->
<cfset TableName = REReplaceNoCase(TableName,"[^A-Za-z_0-9\-]","","ALL")>
<!--- format the TableName; remove bad chars --->

<!--- html header --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>SQL Explorer: <cfoutput>#DSN#<cfif len(TableName)>.#TableName#</cfif></cfoutput></title>
</head>
<body>
<!--- html header --->

<!--- retrieve Tables for this Datasource --->
<cfdbinfo datasource="#DSN#" name="TableNames" type="tables">
<!--- retrieve Tables for this Datasource --->

<!--- this will show all the tablenames at the top of the page --->
<cfoutput>
<cfif !len(TableName)>
	<h1>Please select a table :</h1>
</cfif>
<cfloop query="TableNames">
	<cfif Table_Type is "Table">
		&nbsp;&nbsp;&nbsp;<a href="#cgi.script_name#?DSN=#DSN#&TableName=#Table_Name#">#Table_Name#</a>
	</cfif>
</cfloop>
</cfoutput>
<!--- this will show all the tablenames at the top of the page --->

<cfif len(TableName)>
	<h1>Table : <cfoutput>#TableName#</cfoutput></h1>
	
	<cfoutput>
	<table cellpadding="5" cellspacing="0" border="1">
	<tr><td colspan="5"><h3>SQL Tools</h3></td></tr>
	<tr>
	<td><a href="javascript:return false;" onclick="javascript:open('SQL_Generator_Insert.cfm?popUpWindow=1&DSN=#DSN#&TableName=#TableName#', 'insert', 'width=1024,height=400,top=300,left=100,alwaysraised=no,resizable=yes,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');">INSERT Statement</a></td>
	<td><a href="javascript:return false;" onclick="javascript:open('SQL_Generator_Update.cfm?popUpWindow=1&DSN=#DSN#&TableName=#TableName#', 'update', 'width=1024,height=400,top=300,left=100,alwaysraised=no,resizable=yes,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');">UPDATE Statement</a></td>
	<td><a href="javascript:return false;" onclick="javascript:open('SQL_Generator_Select.cfm?popUpWindow=1&DSN=#DSN#&TableName=#TableName#', 'select', 'width=1024,height=400,top=300,left=100,alwaysraised=no,resizable=yes,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');">SELECT Statement</a></td>
	<td><a href="javascript:return false;" onclick="javascript:open('SQL_Generator_CFParam.cfm?popUpWindow=1&DSN=#DSN#&TableName=#TableName#', 'param', 'width=1024,height=400,top=300,left=100,alwaysraised=no,resizable=yes,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');">CFPARAM</a></td>
	</tr>
	</table>
	<br /><br />
	</cfoutput>
	
	<!--- retrieve Columns for this Table --->
	<cfdbinfo datasource="#DSN#" name="FieldNames" type="columns" table="#TableName#">
	<cfset PrettyColumnNames = ReplaceNoCase(ValueList(FieldNames.COLUMN_NAME),  ",", ", ", "all")>
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
	<th>Name</td>
	<th>Size</td>
	<th>IS_FOREIGNKEY</td>
	<th>IS_NULLABLE</td>
	<th>IS_PRIMARYKEY</td>
	<th>PRIMARYKEY</td>
	<th>PRIMARYKEY_TABLE</td>
	<th>TYPE_NAME</td>
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
		<td><cfif REFERENCED_PRIMARYKEY_TABLE is not "n/a"><a href="javascript:return false;" onclick="javascript:open('SQL_ExploreTable.cfm?DSN=#DSN#&TableName=#REFERENCED_PRIMARYKEY_TABLE#', '#REFERENCED_PRIMARYKEY_TABLE#', 'width=800,height=400,top=300,left=100,alwaysraised=no,resizable=yes,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');">#REFERENCED_PRIMARYKEY_TABLE#</a><cfelse>#REFERENCED_PRIMARYKEY_TABLE#</cfif></td>
		<td>#TYPE_NAME#</td>
		</tr>
	</cfoutput>
	</table>
	<!--- loop through and create the dynamic query --->

	<cfquery name="SampleData" datasource="#DSN#" maxrows=10>
	select top 10 #PrettyColumnNames# from #TableName#
	</cfquery>

	<!--- lazy man's cut and paste --->
	<br />
	<cfoutput>
	<table border="1" cellspacing="0" cellpadding="10">
	<tr><th>Lazy Man's Cut and Paste</th></tr>
	<tr><td>#PrettyColumnNames#</td></tr>
	</table>
	</cfoutput>
	<!--- lazy man's cut and paste --->
	
	<!--- data mover --->
	<br />
	<cfoutput>
	<form action="SQL_ExplorerData.cfm?DSN=#DSN#&TableName=#TableName#" method="post" target="_new">
	<table border="1" cellspacing="0" cellpadding="10">
	<tr><th>SQL Default Data Generator</th></tr>
	<tr><td><cfif SampleData.recordCount><cfloop list="#replaceNoCase(PrettyColumnNames, " ", chr(0), 'all')#" index="columnName"><input type="checkbox" name="columnNames" value="#columnName#" checked="checked">#columnName#</cfloop></td></tr>
	<tr><td align="center"><input type="submit" value="Generate Data Script"><cfelse>No Data</cfif></td></tr>
	</table>
	</form>
	</cfoutput>
	<!--- data mover --->
	
	<!--- show sample data --->
	<br><cfdump var="#SampleData#">
	<!--- show sample data --->
</cfif>

<!--- html footer --->
</body>
</html>
<!--- html footer --->
