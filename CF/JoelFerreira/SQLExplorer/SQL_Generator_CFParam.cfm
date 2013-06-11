<cfparam name="TableName" default="">
<cfparam name="DSN" default="CareerNetwork">

<!--- format the TableName; remove bad chars --->
<cfset TableName = REReplaceNoCase(TableName,"[^A-Za-z_0-9\-]","","ALL")>
<!--- format the TableName; remove bad chars --->

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
</cfloop>
</cfoutput>
</cfif>
<!--- this will show all the tablenames at the top of the page --->

<cfif len(TableName)>
	<h1>Table : <cfoutput>#TableName#</cfoutput></h1>

	<!--- retrieve Columns for this Table --->
	<cfdbinfo datasource="#DSN#" name="FieldNames" type="columns" table="#TableName#">
	<!--- retrieve Columns for this Table --->

	<!--- set default variables; this will set cfparams for all form values --->
	<cfoutput>
	<form>
	<textarea cols="80" rows="#Val(FieldNames.RecordCount+1)#">
<cfloop query="FieldNames">#chr(asc('<'))#cfparam name="form.#Column_Name#" default="">#chr(13)##chr(10)#</cfloop>
	</textarea>
	</form>
	</cfoutput>
	<!--- set default variables; this will set cfparams for all form values --->	

</cfif>

