<!--- =========================================================================================================
	Created:		Steve Gongage (4/08/2013)
	Purpose:		Any time of string matching can be done here.

	Usage:			

========================================================================================================= --->
<cfcomponent extends="">
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	
	<cfset VARIABLES.patterns.base64 	= "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$" />
	
	<cfset VARIABLES.patterns.builtIn	= "array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,ssn,string,struct,telephone,url,uuid,usdate,variablename,zipcode" />

	
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

		<cfif listFindNoCase(VARIABLES.patterns.builtIn, ARGUMENTS.pattern)>
			<!--- Built in pattern --->
			<cfset result = isValid(ARGUMENTS.pattern, ARGUMENTS.value)>
			
		<cfelse>
			<!--- REGEX based pattern --->
			<cfset var selectedPattern = ARGUMENTS.pattern>
			<cfif structKeyExists(VARIABLES.patterns, ARGUMENTS.pattern)>
				<cfset selectedPattern = VARIABLES.patterns[ARGUMENTS.pattern]>
			</cfif>

			<cfif selectedPattern IS NOT "">
				<cfset result = reFindNoCase(selectedPattern, ARGUMENTS.value)>
			</cfif>
		</cfif>
			
		<cfreturn result>
	</cffunction>


</cfcomponent>


