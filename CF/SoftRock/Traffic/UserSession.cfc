<!--- =========================================================================================================
	Created:		Steve Gongage (04/29/2013)
	Purpose:		

	Usage:			<cfset tracking = new com.SoftRock.Traffic.Session()>

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->
	<cfset THIS.userID				= 0>
	<cfset THIS.siteLandingID		= 0>
	<cfset THIS.visitCount 			= 0>


	<cfset VARIABLES.pages 			= {}>			<!--- Container for page traffic objects --->
	<cfset VARIABLES.filteredPages 	= {}>			<!--- Container for filtered out page traffic objects --->
	<cfset VARIABLES.pagePath		= []>			<!--- Array collecting every page visit in the path for this session --->

<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="traffic" required="false" type="array" default="#arrayNew(1)#"> 

		<cfif arraylen(arguments.traffic) GT 0>
			<cfset loadTraffic(traffic)>		
		</cfif>
		
		<!--- Save the Start/Landing Page --->
		<cfset getPage(0, '---The Cloud---')>
		<cfdump var="INIT METHOD!!!">
		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Load Traffic - Loads all traffic in the array into native objects
		@pageHits.description 		"A array of traffic data"
	------------------------------------------------------------------------------------->
	<cffunction name="loadTraffic" access="public" group="load" hint="Loads all traffic in a array into native objects">
		<cfargument name="pageHits" required="true" type="array">


		<cfset var prevVisit = getPage(0)>
		<cfset var currVisit = ''>
		<cfloop array="#ARGUMENTS.pageHits#" index="currVisit">
			<cfset saveVisit(currVisit.pageID, currVisit.pageDescription, prevVisit.pageID, prevVisit.pageDescription)>
			<cfset prevVisit = currVisit>
		</cfloop>

	</cffunction>



	<!-----------------------------------------------------------------------------------
		Save Hit
	------------------------------------------------------------------------------------->
	<cffunction name="saveVisit" access="public" hint="Takes in a hit and saves it to the page traffic object">
		<cfargument name="targetPageID"				required="true" type="numeric">
		<cfargument name="targetPageDescription" 	required="true" type="string">
		<cfargument name="sourcePageID"				required="true" type="numeric">
		<cfargument name="sourcePageDescription"	required="true" type="string">

		<!--- Increment the visit count for this session --->
		<cfset THIS.visitCount ++>

		<cfdump var="#arguments#">
		<cfdump var="#VARIABLES.pages#" label="START #targetPageID#">

		<!--- Load the Current Page --->
		<!---
		<cfset var targetPage 	= getPage(ARGUMENTS.targetPageID, ARGUMENTS.targetPageDescription)>
		--->
		<cfif structKeyExists(VARIABLES.pages, ARGUMENTS.targetPageID)>
			<cfset var targetPage = VARIABLES.pages[ARGUMENTS.targetPageID]>
		<cfelse>
			<cfset var targetPage = new Page(ARGUMENTS.targetPageID, ARGUMENTS.targetPageDescription)>
			<cfset VARIABLES.pages[ARGUMENTS.targetPageID] = targetPage>
		</cfif>

	
		<!--- Load the Source Page --->
		<!---
		<cfset var sourcePage 	= getPage(ARGUMENTS.sourcePageID, ARGUMENTS.sourcePageDescription)>
		--->
		<cfif structKeyExists(VARIABLES.pages, ARGUMENTS.sourcePageID)>
			<cfset var sourcePage = VARIABLES.pages[ARGUMENTS.sourcePageID]>
		<cfelse>
			<cfset var sourcePage = new Page(ARGUMENTS.sourcePageID, ARGUMENTS.sourcePageDescription)>
			<cfset VARIABLES.pages[ARGUMENTS.sourcePageID] = sourcePage>
		</cfif>
		

		<cfif targetPage.pageID IS NOT sourcePage.pageID>
			<!--- If this is not a visit to the same page (Reload action) add landing and exit traffic --->
			<cfset targetPage.addAction('landing', ARGUMENTS.sourcePageID)>
			<cfset sourcePage.addAction('exit', ARGUMENTS.targetPageID)>
			<!--- Add this to the page path --->
			<cfset arrayAppend(VARIABLES.pagePath, targetPage)>
		<cfelse>
			<!--- Save a Reload action since this is a repeat of the last page --->
			<cfset targetPage.addAction('Reload', Arguments.sourcePageID)>
		</cfif>
		<cfdump var="#VARIABLES.pages#" label="After #targetPageID#">

	
		<cfreturn targetPage>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Get Page
	------------------------------------------------------------------------------------->
	<cffunction name="getPage" access="public" hint="Returns an existing or new page object">
		<cfargument name="pageID" 		type="numeric" required="true">
		<cfargument name="description" 	type="string" required="false" default="">

		<cfif structKeyExists(VARIABLES.pages, ARGUMENTS.pageID)>
			<cfset var LOCAL.currPage = VARIABLES.pages[ARGUMENTS.pageID]>
		<cfelse>
			<cfset var LOCAL.currPage = new Page(ARGUMENTS.pageID, ARGUMENTS.description)>
			<cfset VARIABLES.pages[ARGUMENTS.pageID] = LOCAL.currPage>
		</cfif>

		<cfreturn LOCAL.currPage>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Get Pages
	------------------------------------------------------------------------------------->
	<cffunction name="getPath" access="public" hint="Returns all page objects">
		<cfreturn VARIABLES.pagePath>
	</cffunction>


</cfcomponent>