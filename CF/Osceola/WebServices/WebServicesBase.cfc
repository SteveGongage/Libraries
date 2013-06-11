<cfcomponent>

	<cfset this.utilities = structnew()>
	<cfset this.utilities.data = new osceola.OsceolaUtilities.dataUtilities() >
	
 	<!--- ===================================================================================================================================== --->
 	<!--- ===================================================================================================================================== --->
	<cffunction name="newResultObject" access="public" returntype="struct"
		hint="Creates a response object.  Response objects provide a standard way of returning information through this web service.  The output returned will include: success (boolean indicating that the lookup was successful or not), data (the desired resulting data returned from the web service), message (any special messages explaining that success status), input (an echo of the input sent to the web service, useful for debugging purposes). ">
		<cfargument name="isSuccess" 	default="false" 		type="boolean" 	hint="Was the operation of this webservice a success or is there an special error message being returned.">
		<cfargument name="returnData" 	default="#structnew()#" type="any"		hint="The data returned by web services.  Can be either boolean, string, numeric, structure, or array.  Never returns a CF query object since they are not cross platform.">
		<cfargument name="message" 		default="" 				type="string"	hint="If not successful, this should contain the error message explaining the error.  Otherwise, might be blank or just include information relative to the operation of the web service method.">
		<cfargument name="wsInput" 		default="#structnew()#" type="struct"	hint="A clone of the input arguments sent to the web service.  This really is only useful for debugging purposes and should otherwise be ignored.">
		
		<cfset var new = structnew()>
		<cfset new['success'] 		= arguments.isSuccess>
		<cfset new['data']			= arguments.returnData>
		<cfset new['message']		= arguments.message>
		<cfset new['input']			= arguments.wsInput>
		<cfreturn new>
	</cffunction>

	
	<!---
	<!--- ===================================================================== --->
	<cffunction name="queryToStruct" access="public" returntype="struct">
		<cfargument name="queryIn" required="yes" type="query">
		<cfargument name="keyColumn" required="yes" type="string">
		<cfset var returnStruct = structnew()>
		
		<cfloop query="queryIn">
			<cfset newKeyName = queryIn[keyColumn][currentRow]>
			
			<cfif listLen(queryIn.columnList) GT 2>
				<cfset returnStruct[newKeyName] = structnew()>
				<cfloop list="#queryIn.columnList#" index="colName">
					<cfset returnStruct[newKeyName][colName] = queryIn[colName][currentRow]>
				</cfloop>
			<cfelse>
				<cfset otherColumn = listDeleteAt(queryIn.columnList, listFindNoCase(queryIn.columnList, keyColumn))>
				<cfset returnStruct[newKeyName] = queryIn[otherColumn][currentRow]>
			</cfif>
		</cfloop>
		
		<cfreturn returnStruct>
	</cffunction>
	
	<!--- ===================================================================== --->
	<cffunction name="queryToArray"	 access="public" returntype="array">
		<cfargument name="queryIn" required="yes" type="query">
		<cfset var returnData = arraynew(1)>
		
		<cfloop query="arguments.queryIn">
			<cfset tempData = queryRowToStruct(arguments.queryIn, arguments.queryIn.currentRow)>
			<cfset arrayAppend(returnData, tempData)>
		</cfloop>
		<cfreturn returnData>
	</cffunction>


	<!--- ===================================================================== --->
	<cffunction name="queryRowToStruct" access="public" returntype="struct">
		<cfargument name="queryIn" required="yes" type="query">
		<cfargument name="rowNumber" required="yes" type="numeric">
		
		<cfset var returnStruct = structnew()>
		
		<cfloop list="#queryIn.columnList#" index="colName">
			<cfif rowNumber LE queryIn.recordcount AND rowNumber GT 0>
				<cfset returnStruct[colName] = queryIn[colName][rowNumber]>
			<cfelse>
				<cfset returnStruct[colName] = "">
			</cfif>
		</cfloop>
		
		<cfreturn returnStruct>
		
	</cffunction>

	--->
	

</cfcomponent>