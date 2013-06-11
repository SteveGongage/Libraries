<cfcomponent>


	<cffunction name="init" access="public">
		
		<cfscript>
			var libraries			= structnew();
			libraries['Data']		= 'osceola.OsceolaUtilities.dataUtilities';
			libraries['DataType']	= 'osceola.OsceolaUtilities.dataTypeUtilities';
			libraries['Map'] 		= 'osceola.OsceolaUtilities.MapUtilities';
		</cfscript>

		<cfset loadLibraries(libraries)>
		
		<cfreturn this>
	</cffunction>
	
	
	<!--- ================================================================ --->
	<cffunction name="loadLibraries" access="private">
		<cfargument name="libraryStruct" required="yes" type="struct">

		<cfloop collection="#arguments.libraryStruct#" item="currUtil">
			<cfset loadLibrary(currUtil, arguments.libraryStruct[currUtil])>
		</cfloop>
	</cffunction>
	
	
	<!--- ================================================================ --->
	<cffunction name="loadLibrary">
		<cfargument name="libraryName">
		<cfargument name="componentPath">
		
		<cfset var sysLog = createObject('component', 'nexusweb2.logging.systemLogUtilities')>

		<cfif NOT structKeyExists(request, 'utilities')>
			<cfset request.utilities = this>
		</cfif>
		
		<cftry>
			<cfif NOT structKeyExists(request.utilities, arguments.libraryName)>
				<!---
				<cfset request.utilities[arguments.libraryName] = createObject('component', arguments.componentPath)>
				--->
				<!--- This new way allows libraries to call their INIT method when necessary --->
				<cfset request.utilities[arguments.libraryName] = evaluate('new #arguments.componentPath#()')>
				
			<cfelse>
				<cfset sysLog.addLog('error,serious', 'OCMS', 'Utilities Library', '#arguments.libraryName# Creation Error', 'A library already exists with the name "#arguments.libraryName#"')>
				<cfthrow message="A library already exists with the name #arguments.libraryName#">
			</cfif>
			
			<cfcatch type="any">
				<cfif cfcatch.Message CONTAINS "Could not find the ColdFusion Component or interface">
					<cfset sysLog.addLog('error,serious', 'OCMS', 'Utilities Library', '#arguments.libraryName# Creation Error', 'Error creating the library "#arguments.libraryName#" with component path "#arguments.componentPath#".  Error message is "#cfCatch.message#"', cfcatch)>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		
		
	</cffunction>
	

	<!--- ================================================================ --->
	<cffunction name="OnMissingMethod">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="args" type="struct" required="yes">
		
		<cfthrow message="Could not find the method #arguments.name#">
	</cffunction>

</cfcomponent>