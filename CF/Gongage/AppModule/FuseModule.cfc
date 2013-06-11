<!--- =========================================================================================================
	Created:		Steve Gongage (04/12/2013)
	Purpose:		

	Usage:			

========================================================================================================= --->
<cfcomponent>
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	<!--- ================================================================================================ --->
	<cfset VARIABLES.currentFuse 	= {}>
	<cfset VARIABLES.fuseSystem		= {}>

	
	<!--- ================================================================================================ --->
	<!--- Functions --->
	<!--- ================================================================================================ --->


	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="currentFuse" 	type="struct" required="true">
		<cfargument name="fuseSystem"	type="FuseSystem" required="true">

		<cfset VARIABLES.currentFuse 	= ARGUMENTS.currentFuse>
		<cfset VARIABLES.fuseSystem 	= ARGUMENTS.fuseSystem>

		<cfreturn THIS>
	</cffunction>


	
	<!-----------------------------------------------------------------------------------
		get a link given a fusepath 
		@fusePath.description 		"The fuse path you will want to link to"
	------------------------------------------------------------------------------------->
	<cffunction name="linkTo" access="public">
		<cfargument name="fusePath" type="string">
		<cfset var link = "?">
		<cfset var newFusePath = ARGUMENTS.fusePath>


		<cfreturn link>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Include the template and run inside this context
	------------------------------------------------------------------------------------->
	<cffunction name="go" access="public">
		<cfif VARIABLES.currentFuse.include IS NOT "">
			<cftry>	
				<cfinclude template="#VARIABLES.currentFuse.include#">
				<cfcatch type="template">
					<cfset VARIABLES.fuseSystem.handleError("Include template '#VARIABLES.currentFuse.include#' could not be found for fuse path '#VARIABLES.currentFuse.pathString#'.")>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>



</cfcomponent>