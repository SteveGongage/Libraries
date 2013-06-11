<!--- =========================================================================================================
	Created:		Steve Gongage (04/29/2013)
	Purpose:		

	Usage:			Intended to be created only by SoftRock.Traffic.Tracking

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->
	<cfset THIS.pageID 			= 0>
	<cfset THIS.description 	= 'Unknown'>
	<cfset THIS.traffic = {}>
	<cfset THIS.traffic.visit 			= 0>
	<cfset THIS.traffic.reload			= 0>
	<cfset THIS.traffic.landing 		= {}>
	<cfset THIS.traffic.exit 		 	= {}>



<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
			@pageID.Description 		"Page ID"
			@description.Description 	"Description"
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="pageID" 		required="true" type="numeric">
		<cfargument name="description"	required="true" type="string">
		<cfset THIS.pageID 		= ARGUMENTS.pageID>
		<cfset THIS.description = ARGUMENTS.description>

		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Add Action - Records an action on this page from another page
		@otherPageID.description 		"The ID of the other page"
	------------------------------------------------------------------------------------->
	<cffunction name="addAction" access="public">
		<cfargument name="action">
		<cfargument name="otherPageID">

		<cfif structKeyExists(THIS.traffic, ARGUMENTS.action)>
			<cfset trafficStruct = THIS.traffic[ARGUMENTS.action]>
			<cfif isStruct(trafficStruct)>
				<!--- If this counter tracks by page --->
				<cfif NOT structKeyExists(trafficStruct, ARGUMENTS.otherPageID)>
					<cfset trafficStruct[ARGUMENTS.otherPageID] = 0>
				</cfif>
				<cfset trafficStruct[ARGUMENTS.otherPageID] ++>
			<cfelse>
				<!--- If this is a simple counter --->
				<cfset this.traffic[ARGUMENTS.action] ++>
			</cfif>

			<cfif ARGUMENTS.action IS NOT "exit">
				<!--- For all actions except exits, track another visit to this page --->
				<cfset THIS.traffic.visit ++>
			
			</cfif>
		<cfelse>
			<cfthrow message="Page.cfc: Could not find action: '#arguments.action#'">
		</cfif>
	</cffunction>

	<!---
	<!-----------------------------------------------------------------------------------
		Add Landing - Records a landing on this page from another page
		@otherPageID.description 		"The ID of the page they visited before going here"
	------------------------------------------------------------------------------------->
	<cffunction name="addLanding" access="public">
		<cfargument name="otherPageID">

		<cfset THIS.traffic.visits ++>

		<cfif NOT structKeyExists(THIS.traffic.source, ARGUMENTS.otherPageID)>
			<cfset THIS.traffic.source[ARGUMENTS.otherPageID] = 0>
		</cfif>
		<cfset THIS.traffic.source[ARGUMENTS.otherPageID] ++>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Add Exit - Records an exit from this page to another page
		@otherPageID.description 		"The ID of the page they visited before going here"
	------------------------------------------------------------------------------------->
	<cffunction name="addExit" access="public">
		<cfargument name="otherPageID">


		<cfif NOT structKeyExists(THIS.traffic.destination, ARGUMENTS.otherPageID)>
			<cfset THIS.traffic.destination[ARGUMENTS.otherPageID] = 0>
		</cfif>
		<cfset THIS.traffic.destination[ARGUMENTS.otherPageID] ++>
	</cffunction>
	--->

</cfcomponent>