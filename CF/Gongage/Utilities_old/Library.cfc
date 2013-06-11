<!--- =========================================================================================================
	Created:		Steve Gongage (4/8/2013)
	Purpose:		This library component can be customized to meet any project's needs.  This is the start file for all utility libraries.
					Make all changes to the INIT function below.  
					All specific libraries and utility libraries not part of this package should be included here and not in the LIBRARYBASE

	Usage:			<cfset request.util = new cf.Gongage.Utilities.Library()>

========================================================================================================= --->
<cfcomponent extends="LibraryBase">
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	
	<!--- A struct containing paths to their components.  Whatever you name the key for that path is what the library will be called.   --->
	<cfset VARIABLES.libraries = {
		
	}>


	
	<!--- ================================================================================================ --->
	<!--- Functions --->

	<!--- ================================================================ --->
	<!---
		Init method for the Utilities Library 
	---->
	<cffunction name="init" access="public">
		<cfset super.init()>						<!--- Calls the base utility's init to setup basic libaries --->
		<cfset loadFromStruct(VARIABLES.libraries)>	<!--- Load the libary of utilities --->
	</cffunction>


</cfcomponent>