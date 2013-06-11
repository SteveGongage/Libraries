<!--- =========================================================================================================
	Created:		Steve Gongage (4/9/2013)
	Purpose:		Fusebox base

	Usage:			<cfset request.module.fbox = new cf.Gongage.fusebox.fusebox()>

			Store data/settings for a module
			module.set('varName', 'value');
			
			Get all data/settings for THIS module
			module.getData()

========================================================================================================= --->
<cfcomponent extends="cf.Gongage.DataObject">
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	<!--- ================================================================================================ --->
	<cfset THIS.input 		= {}>	<!--- THIS will contain any URL or FORM scoped inputs --->
	<cfset THIS.fusebox		= {}>	<!--- To be replaced by the Fuse System during the INIT() --->
	
	<!--- ================================================================================================ --->
	<!--- Functions --->
	<!--- ================================================================================================ --->
	
	
	<!-----------------------------------------------------------------------------------
		Init method for THIS component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="fusePathVariableName" type="string" default="f">

 		
 		<!--- Create a unified INPUT struct from URL and FORM scopes --->
 		<cfset THIS.input = setupInput()>

 		<!--- Setup the Fuse System --->
 		<cfset THIS.fusebox = new FuseSystem(THIS.input, ARGUMENTS.fusePathVariableName)>



		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Get a structure of values given a list of scopes of increasing precident
		@listOfScopes.description		"List of scopes ordered by increasing precident (later scopes will overwrite earlier ones)"
	------------------------------------------------------------------------------------->
	<cffunction name="setupInput" access="private">
		<cfargument name="listOfScopes" type="string" default="URL,FORM">
		<cfset var input = structNew() />
		<cfset var elem = ''>
		
		<cfloop list="#ARGUMENTS.listOfScopes#" index="elem">
			<cfif isDefined('#elem#')>
				<cfset structAppend(input, evaluate('#elem#'), true) />
			</cfif>
		</cfloop>

		<cfreturn input>
	</cffunction>



</cfcomponent>