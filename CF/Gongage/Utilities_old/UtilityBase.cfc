<!---

	Created:		Steve Gongage (4/8/2013)
	Purpose:		Base Utility Component.  
	Usage:			Utilities are components that simply store functions

	<cffunction name="init" access="public">
		<cfset super.init()>	<!--- Calls the base utility's init to setup basic libaries --->
	</cffunction>

--->


<cfcomponent>
	<!--- ========================================================================================================================== --->
	<!--- Properties --->

	<cfset variables.util = ''>		<!--- Should be set during INIT to the master utility library so that each library utility can access the others --->

	
	<!--- ========================================================================================================================== --->
	<!--- Functions --->


	<!--- ================================================================
		Init method for the base Utilities Library 
	---->
	<cffunction name="init" access="public">
		<cfargument name="masterUtilityLibrary" required="true" type="cf.Gongage.Utilities.LibraryBase">

		<cfset variables.util = arguments.masterUtilityLibrary>

		<cfreturn this>
	</cffunction>


	<!--- ================================================================
		Handler for Missing Methods
	---->
	<cffunction name="OnMissingMethod" access="private">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="args" type="struct" required="yes">

		<cfset handleError('serious', 'cf.Gongage', 'Library', 'Missing Utility Function: "#arguments.name#"', 'Could not find the method "#arguments.name#".  Here are the arguments: #structKeyList(arguments.args)#')>
	</cffunction>
	
	
	<!--- ================================================================
		Handler for errors.
	---->
	<cffunction name="handleError" access="private">
		<cfargument name="errorType" 	type="string" required="yes">
		<cfargument name="System" 		type="string" required="yes">
		<cfargument name="SubSystem"	type="string" required="yes">
		<cfargument name="Message"		type="string" required="no" default="">
		<cfargument name="Detail"		type="string" required="no" default="">
		
		<!---
			[SGON:TODO - this utility library is not functioning outside xhost environment]
			
			<cfset var sysLog = createObject('component', 'nexusweb2.logging.systemLogUtilities')>
			<cfset sysLog.addLog(arguments.errorType, arguments.system, arguments.subSystem, arguments.message)>
		--->
		
		<!---[SGON:TODO - Remove the following once you fix the TODO above --->
		<cfthrow message="Utilities Error: #arguments.message#" detail="#arguments.detail#">
		
	</cffunction>
	

	<!--- ================================================================ 
		Dumps a value and can abort if required
	--->
	<cffunction name="dump" access="private">
		<cfargument name="dumpVar" 	required="yes">
		<cfargument name="andAbort"	default="false" required="yes" type="boolean">

		<cfdump var="#arguments.dumpVar#">
		<cfif arguments.andAbort>
			<cfabort>
		</cfif>

	</cffunction>
	
	<!--- ================================================================ 
		Gets help for this component
	--->
	<cffunction name="help" access="public">
		<cfreturn variables.util.dump.component(this)>
	</cffunction>



</cfcomponent>
