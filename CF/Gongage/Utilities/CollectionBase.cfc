<!--- =========================================================================================================

	Created:		Steve Gongage (4/8/2013)
	Purpose:		Base Utility Library Component.  
	Usage:			Create a component that extends this component, and in the init method provide the following init function:

	<cffunction name="init" access="public">
		
		<cfset super.init()>	<!--- Calls the base utility's init to setup basic libaries --->
		
		<!--- A struct containing paths to their components.  Whatever you name the key for that path is what the library will be called.   --->

		<cfset var libraries = {
			'Libary01'		= 'path.to.component',
			'Library02'		= 'path.to.othercomponent'
		}>
		
		<cfset loadFromStruct(libraries)>	<!--- Load the libary --->
		
	</cffunction>

========================================================================================================= --->


<cfcomponent extends="LibraryBase">
	<!--- ================================================================================================ --->
	<!--- Properties --->
	<cfset VARIABLES.defaultLibraries = {
		'data'				= 'cf.Gongage.utilities.base.dataUtilities'
		, 'string'			= 'cf.Gongage.utilities.base.stringUtilities'
		, 'display'			= 'cf.Gongage.utilities.base.displayUtilities'
		, 'dataType'		= 'cf.Gongage.utilities.base.dataTypeUtilities'
		, 'dump'			= 'cf.Gongage.utilities.base.dumpUtilities'
		, 'date'			= 'cf.Gongage.utilities.date.dateUtilities'
		, 'system'			= 'cf.Gongage.utilities.base.SystemUtilities'
	}>


	
	<!--- ================================================================================================ --->
	<!--- Functions --->


	<!--- ================================================================ --->
	<!---
		Init method for the base Utilities Library 
		
			
	---->
	<cffunction name="init" access="public">
		<cfset loadFromStruct(VARIABLES.defaultLibraries)>
		<cfreturn this>
	</cffunction>
	
	
	<!--- ================================================================ --->
	<!---
		Allows access to the library 
		@libraryName.description 		"Name that this library will be referenced as.  Example: 'math'"
		@componentPath.description		"Dot notation path to the component.  Example: 'com.DesignRadiance.utilities.math'"
	--->
	
	<cffunction name="load" access="public">
		<cfargument name="libraryName">
		<cfargument name="componentPath">


		<cftry>
			<cfif NOT structKeyExists(this, arguments.libraryName)>
				<!--- This new way allows libraries to call their INIT method when necessary --->
				<cfset this[arguments.libraryName] = evaluate('new #arguments.componentPath#(this)')>
				
			<cfelse>
				<cfset handleError('error,serious', 'OCMS', 'Utilities Library', '#arguments.libraryName# Creation Error', 'A library already exists with the name "#arguments.libraryName#"')>
				<cfthrow message="A library already exists with the name #arguments.libraryName#">
			</cfif>
			
			<cfcatch type="any">
				<cfif cfcatch.Message CONTAINS "Could not find the ColdFusion Component or interface">
					<cfset handleError('error,serious', 'OCMS', 'Utilities Library', '#uCase(arguments.libraryName)# Library Creation Error', 'Error creating the library "#arguments.libraryName#" with component path "#arguments.componentPath#".  Error message is "#cfCatch.message#"', cfcatch)>
				<cfelse>
					<cfset handleError('error,serious', 'OCMS', 'Utilities Library', cfcatch.message, cfcatch.detail)>
				</cfif>
			</cfcatch>
		</cftry>
		
		
	</cffunction>
	
	<!---
	<cffunction name="load" access="public">
		<cfargument name="libraryName">
		<cfargument name="componentPath">


		<cfif NOT structKeyExists(request, 'utilities')>
			<cfset request.utilities = this>
		</cfif>
		
		<cftry>
			<cfif NOT structKeyExists(request.utilities, arguments.libraryName)>
				<!--- This new way allows libraries to call their INIT method when necessary --->
				<cfset request.utilities[arguments.libraryName] = evaluate('new #arguments.componentPath#(this)')>
				
			<cfelse>
				<cfset handleError('error,serious', 'OCMS', 'Utilities Library', '#arguments.libraryName# Creation Error', 'A library already exists with the name "#arguments.libraryName#"')>
				<cfthrow message="A library already exists with the name #arguments.libraryName#">
			</cfif>
			
			<cfcatch type="any">
				<cfif cfcatch.Message CONTAINS "Could not find the ColdFusion Component or interface">
					<cfset handleError('error,serious', 'OCMS', 'Utilities Library', '#uCase(arguments.libraryName)# Library Creation Error', 'Error creating the library "#arguments.libraryName#" with component path "#arguments.componentPath#".  Error message is "#cfCatch.message#"', cfcatch)>
				<cfelse>
					<cfset handleError('error,serious', 'OCMS', 'Utilities Library', cfcatch.message, cfcatch.detail)>
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>
	--->
	
	<!--- ================================================================ 

	--->
	<cffunction name="loadFromStruct" access="private">
		<cfargument name="libraryStruct" required="yes" type="struct">

		<cfloop collection="#arguments.libraryStruct#" item="currUtil">
			<cfset load(currUtil, arguments.libraryStruct[currUtil])>
		</cfloop>
	</cffunction>
	
	<!--- ================================================================ 
		
	--->
	<cffunction name="help" access="public">
		<cfargument name="utilityName" required="false" default="" type="string">
		<cfset var output = "">
		

		<cfif NOT structKeyExists(this, arguments.utilityName)>
			<cfsavecontent variable="output">
			<cfoutput>

				<cfif arguments.utilityName IS NOT "">
					<div>Could not find a library with the name '#arguments.utilityName#</div>
				</cfif>
			
				<div>Please use one of the following as an argument for CollectionBase.help()</div>

				<!--- Dump the subcomponents of this library --->
				#this.dump.subcomponents(this)#


			</cfoutput>
			</cfsavecontent>
	
			
		<cfelse>
			<cfset var targetUtil = this[arguments.utilityName]>
			<cfset output = this.dump.component(targetUtil)>
		</cfif>

		<cfreturn output>

	</cffunction>
	
	

	
</cfcomponent>