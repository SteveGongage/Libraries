<cfparam name="TableName" default="">
<cfparam name="DSN" default="CareerNetwork">

<!--- retrieve Tables for this Datasource --->
<cfdbinfo datasource="#DSN#" name="TableNames" type="tables">
<!--- retrieve Tables for this Datasource --->

<!--- this will show all the tablenames at the top of the page --->
<cfif !isDefined("url.popUpWindow")>
<cfoutput>
<cfloop query="TableNames">
	<cfif Table_Type is "Table">
		<a href="#cgi.script_name#?DSN=#DSN#&TableName=#Table_Name#">#Table_Name#</a>&nbsp;&nbsp;
	</cfif>
</cfloop><br><br>
</cfoutput>
</cfif>
<!--- this will show all the tablenames at the top of the page --->

<cfif len(TableName)>
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
<cfoutput>
<cfsavecontent variable="GeneratedSQL">
#chr(asc('<'))#cfquery name="NewUserQuery" datasource="#DSN#">
	SET NOCOUNT ON
		INSERT INTO #TableName# (
<cfloop query="FieldNames">#Column_Name#<cfif CurrentRow NEQ Recordcount>,#chr(13)##chr(10)#</cfif></cfloop>
		)
	
		VALUES (
<cfloop query="FieldNames"><cfif (is_Nullable contains "no" and len(Column_Default_Value)) and (Type_Name contains "int" or Type_Name contains "bit")>#chr(asc('<'))#cfif len(form.#Column_Name#)>#chr(asc('<'))#cfqueryparam value="##form.#Column_Name###" cfsqltype="#IIF(Type_Name contains 'int' or Type_Name contains 'bit', DE('CF_SQL_NUMERIC'), DE('CF_SQL_VARCHAR'))#" maxlength="#COLUMN_SIZE#">#chr(asc('<'))#cfelse>#REReplaceNoCase(Column_Default_Value, "[[:punct:]]", "", "all")##chr(asc('<'))#/cfif><cfelseif trim(is_Nullable)>#chr(asc('<'))#cfif len(form.#Column_Name#)>#chr(asc('<'))#cfqueryparam value="##form.#Column_Name###" cfsqltype="#IIF(Type_Name contains 'int' or Type_Name contains 'bit', DE('CF_SQL_NUMERIC'), DE('CF_SQL_VARCHAR'))#" maxlength="#COLUMN_SIZE#">#chr(asc('<'))#cfelse>NULL#chr(asc('<'))#/cfif><cfelse>#chr(asc('<'))#cfqueryparam value="##form.#Column_Name###" cfsqltype="#IIF(Type_Name contains 'int', DE('CF_SQL_NUMERIC'), DE('CF_SQL_VARCHAR'))#" maxlength="#COLUMN_SIZE#"></cfif><cfif CurrentRow NEQ Recordcount>,#chr(13)##chr(10)#</cfif></cfloop>
		)
	
	SET NOCOUNT OFF 
		SELECT @@identity AS #PrimaryKey#
#chr(13)##chr(10)#
#chr(asc('<'))#/cfquery>
</cfsavecontent>
</cfoutput>
<!--- loop through and create the dynamic query --->

	<!--- show the output --->
	<cfoutput>
	<form>
	PrimaryKey : <cfif PrimaryKeyQuery.RecordCount eq 0>None found, Assume it is : </cfif>#PrimaryKey#<br>
	<textarea cols="120" rows="#Val(ListLen(GeneratedSQL, '#chr(13)##chr(10)#')+2)#">
	#HTMLEditFormat(GeneratedSQL)#
	</textarea>
	</form>
	</cfoutput>
	<!--- show the output --->
</cfif>
