<!--- =========================================================================================================
	Created:		Steve Gongage (4/08/2013)
	Purpose:		Data type utilities

	Usage:			

========================================================================================================= --->
<cfcomponent>
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	
	<cfset VARIABLES.matching = {
		patterns = {
			base64 	= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$"
		}
		, builtIn	= "array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,ssn,string,struct,telephone,url,uuid,usdate,variablename,zipcode"
	}
	 />
	

	
	<!--- ================================================================================================ --->
	<!--- Functions --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfreturn this>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Check if a value matches a pattern
		@pattern.description 	"Regex pattern or name of the pattern to use"
		@value.description		"A string value to attempt the regex pattern matching"
	------------------------------------------------------------------------------------->
	<cffunction name="is" access="public">
		<cfargument name="pattern" 	required="true" type="string">
		<cfargument name="value"	required="true" type="string">

		<cfset var result = false>


		<cfif listFindNoCase(VARIABLES.matching.builtIn, ARGUMENTS.pattern)>
			<!--- Built in pattern --->
			<cfset result = isValid(ARGUMENTS.pattern, ARGUMENTS.value)>
		<cfelse>
			<!--- REGEX based pattern --->
			<cfset var selectedPattern = ARGUMENTS.pattern>
			<cfif structKeyExists(VARIABLES.matching.patterns, ARGUMENTS.pattern)>
				<cfset selectedPattern = VARIABLES.matching.patterns[ARGUMENTS.pattern]>
			</cfif>

			<cfif selectedPattern IS NOT "">
				<cfset result = reFindNoCase(selectedPattern, ARGUMENTS.value)>
			</cfif>
		</cfif>
			
		<cfreturn result>
	</cffunction>


	
	<!--- ========================================================== --->
	<cffunction name="compareStructs">
		<cfargument name="struct1" 		required="yes">
		<cfargument name="struct2"		required="yes">
		<cfargument name="excludeKeys"	required="no" default="">
		
		<cfset isEqual = true>
		
		<!--- Compare Old Data to New Data --->
		<cftry>
			<cfloop list="#structKeyList(arguments.struct1)#" index="currKeyName">
				<cfif 	NOT listFindNoCase(arguments.excludeKeys, currKeyName) >
					<cfif toString(trim(arguments.struct1[currKeyName])) IS NOT toString(trim(arguments.struct2[currKeyName]))>
						<!--- If these two values do not match --->
						<cfset isEqual = false>
					</cfif>
				</cfif>
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#arguments.struct1#">
				<cfdump var="#arguments.struct2#">
				
				<cfabort>
			</cfcatch>
		</cftry>
		
		<cfreturn isEqual>	
	</cffunction>
	


	<!---============================================================================================== --->
	<cffunction name="arrayToQuery" access="public" returntype="query">
		<cfargument name="dataIn" 		required="yes" type="array">
		<cfset var outputQ = querynew('column01')>
		<cfset var newColumnName = "">
		<cfset var newColumnList = "">
		
		<cfloop array="#arguments.dataIn#" index="currItem">
			<cfif isStruct(currItem)>
				<cfset queryAddRow(outputQ)>
				<cfloop collection="#currItem#" item="currColumn">
					<cfset newColumnName = replace(currcolumn, " ", "_", "all")>
					<cfif NOT listFindNoCase(outputQ.columnlist, newColumnName)>
						<!--- If this is a new column, create it --->
						<cfset newColumnList = listAppend(newColumnList, newColumnName)>
						<cfset queryAddColumn(outputQ, newColumnName, 'VarChar', arraynew(1))>
					</cfif>
					<cfset currValue = currItem[currColumn]>
					<cfset querySetCell(outputQ, newColumnName, currValue)>
				</cfloop>
			<cfelseif isSimpleValue(currItem)>
				<cfif NOT listFindNoCase(newColumnList, 'column01')>
					<cfset newColumnList = listAppend(newColumnList, 'column01')>
				</cfif>
				<cfset querySetCell(outputQ, 'column01', currItem)>
			</cfif>
		</cfloop>
		
		
		<cfif listLen(outputQ.columnlist) GT 1>
			<!--- Remove the stupid placeholder column we had to have for some reason --->
			<cfquery name="outputQ" dbtype="query">
				SELECT #newColumnList#
					FROM outputQ
			</cfquery>
		</cfif>
		
		<cfreturn outputQ>
	
	</cffunction>
	

	<!---============================================================================================== --->
	<cffunction name="queryToArray" access="public" returntype="array">
		<cfargument name="queryIn"				required="yes" type="query">
		
		<cfset var resultArray = arraynew(1)>
		
		<cfloop query="queryIn">
			<cfset arrayAppend(resultArray, queryRowToStruct(queryIn, queryIn.currentrow))>		
		</cfloop>
		
		<cfreturn resultArray>
	</cffunction>



	<!---============================================================================================== --->
	<cffunction name="queryRowToStruct" access="public" returntype="struct">
		<cfargument name="query" 					required="yes" 	type="query" >
		<cfargument name="rowNumber" 	default="1" required="no"	type="numeric" >
		<cfset var result = structnew()>
		
		<cfif query.recordcount IS 0>
			<cfloop list="#query.columnlist#" index="elem" >
				<cfset result[elem] = "">
			</cfloop>
		<cfelse>
			<cfif query.recordcount GE rowNumber>
				<cfloop list="#query.columnlist#" index="elem" >
					<cfset result[elem] = query[elem][rowNumber]>
				</cfloop>
			<cfelse>
				<cfthrow message="Error in DataUtilities.queryRowToStruct():  The rowNumber #rowNumber# is greater than the number of rows in the query #query.recordcount#">
			</cfif>
		</cfif>
		
		
		<cfreturn result>
	</cffunction>
	
	
	

</cfcomponent>


