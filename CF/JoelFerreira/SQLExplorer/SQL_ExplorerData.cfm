<cfparam name="TableName" default="">
<cfparam name="DSN" default="JobSite123Dev">

<!--- format the TableName; remove bad chars --->
<cfset TableName = REReplaceNoCase(TableName,"[^A-Za-z_0-9\-]","","ALL")>
<!--- format the TableName; remove bad chars --->

<!--- retrieve Tables for this Datasource --->
<cfdbinfo datasource="#DSN#" name="TableNames" type="tables">
<!--- retrieve Tables for this Datasource --->

<cfif len(TableName)>
	<h1>Table : <cfoutput>#TableName#</cfoutput></h1>

	<!--- retrieve Columns for this Table --->
	<cfdbinfo datasource="#DSN#" name="FieldNames" type="columns" table="#TableName#">
	<!--- retrieve Columns for this Table --->

	<cfquery name="sampleData" datasource="#DSN#">
		select * from #TableName#
	</cfquery>

	<cfset sortOrder = valueList(FieldNames.COLUMN_NAME)>
	<cfset sortType = valueList(FieldNames.TYPE_NAME)>
	
	<cfsetting enablecfoutputonly="true">
	<cfsavecontent variable="mySQL">
	<cfoutput>SET IDENTITY_INSERT #tableName# ON#chr(13)##chr(10)#</cfoutput>
	<cfoutput>INSERT INTO #variables.TableName# (#form.columnNames#)#chr(13)##chr(10)#</cfoutput>
	<cfloop query="sampleData">
		<cfoutput>SELECT </cfoutput>
		<cfloop list="#form.columnNames#" index="fieldName">

			<cfset thisFieldPosition = listFindNoCase(form.columnNames, variables.fieldName)>
			<cfset thisFieldType = listGetAt(variables.sortType, thisFieldPosition)>
			<cfset thisFieldValue = variables.sampleData[variables.fieldName]>

			<cfif reFindNoCase('int|bit|numeric', thisFieldType)>
				<!--- handle numbers --->
				<cfif len(thisFieldValue)>
					<cfoutput>#thisFieldValue#</cfoutput>
				<cfelse>
					<cfoutput>NULL</cfoutput>
				</cfif>
			<cfelse>
				<!--- handle text and all others --->
				<cfoutput>'#replaceNoCase(thisFieldValue,  "'", "''", "all")#'</cfoutput>
			</cfif>
	
			<!--- the comma between data --->
			<cfif listFind(form.columnNames, variables.fieldName) neq listlen(form.columnNames)><cfoutput>, </cfoutput></cfif>
		</cfloop>
	
		<!--- the union all between rows --->
		<cfif sampleData.currentRow NEQ sampleData.recordCount>
			<cfoutput> UNION ALL#chr(13)##chr(10)#</cfoutput>
		</cfif>
	
	</cfloop>
<cfoutput>
SET IDENTITY_INSERT #tableName# OFF
</cfoutput>
</cfsavecontent>
</cfsetting>

<cfoutput><textarea cols="120" rows="15" name="code" type="textarea">#mySQL#</textarea></cfoutput>

</cfif>
