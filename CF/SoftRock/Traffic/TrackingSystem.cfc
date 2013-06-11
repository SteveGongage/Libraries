<!--- =========================================================================================================
	Created:		Steve Gongage (04/29/2013)
	Purpose:		

	Usage:			<cfset tracking = new com.SoftRock.Traffic.TrackingSystem()>

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->
	<cfset VARIABLES.sessionThresholdMinutes = 10>	<!--- Period of inactivity before a new session begins --->
	
	<cfset VARIABLES.userSessions = []>


	<cfset VARIABLES.newEngagementPageIDs = []>




<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="trackingData" type="query" required="true">

		<cfset loadTrackingData(ARGUMENTS.trackingData)>

		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		New User
	------------------------------------------------------------------------------------->
	<cffunction name="loadTrackingData" access="public">
		<cfargument name="trackingData" type="query" required="true">

		<cfquery name="distinctUsers" dbtype="query">
			SELECT DISTINCT userID FROM trackingData ORDER BY userID
		</cfquery>

		<cfset var userList = valueList(distinctUsers.userID)>


		<!--- Loop over each user in the data provided --->
		<cfloop list="#userList#" index="currUserID">


			<!--- Get page landings for just this user --->
			<cfquery name="userLandings" dbtype="query">
				SELECT dateCreated, pageID, pageDescription, pageTrackingID, userID, siteLandingID
					FROM trackingData
					WHERE userID = #currUserID# AND actionName = 'Landing'
					ORDER BY dateCreated
			</cfquery>

			<!--- We now loop over each page landing, logging landings and breaking them into separate sessions as necessary --->
			<cfset var newSession 			= new UserSession()>
			<cfset newSession.userID 		= userLandings.userID>
			<cfset newSession.siteLandingID = userLandings.siteLandingID>


			<cfset var lastLanding = { pageID = 0, pageDescription='---The Cloud---', dateCreated = createDate(2000, 1, 1)}>

			<cfset var minutesSinceLastLanding	= 0>
			<cfloop query="userLandings">
				<!--- Test for New Session --->
				<cfset minutesSinceLastLanding = dateDiff('n', lastLanding.dateCreated, userLandings.dateCreated)>
				<cfset isNewSession = (minutesSinceLastLanding GT VARIABLES.sessionThresholdMinutes)>		


				<!--- If this is a new session --->
				<cfif isNewSession>
					<cfif newSession.visitCount GT 0>
						<cfset arrayAppend(VARIABLES.userSessions, newSession)>					
					</cfif>
					<cfset lastLanding = { pageID = 0, pageDescription='---The Cloud---', dateCreated = createDate(2000, 1, 1)}>
					<cfset newSession 				= new UserSession()>
					<cfset newSession.userID 		= userLandings.userID>
					<cfset newSession.siteLandingID = userLandings.siteLandingID>
				</cfif>


				<!--- Record the page visit --->
				<cfset newSession.saveVisit(userLandings.pageID, userLandings.pageDescription, lastLanding.pageID, lastLanding.pageDescription)>

				<!--- Store the last landing for use on the next loop --->
				<cfset lastLanding.pageID 			= userLandings.pageID>
				<cfset lastLanding.pageDescription 	= userLandings.pageDescription>
				<cfset lastLanding.dateCreated 		= userLandings.dateCreated>

			</cfloop>


			<cfif newSession.visitCount GT 0>
				<!--- Save the last session worked on --->
				<cfset arrayAppend(VARIABLES.userSessions, newSession)>					
			</cfif>



		</cfloop>

		
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Get User Sessions
	------------------------------------------------------------------------------------->
	<cffunction name="getUserSessions" access="public">
		<cfreturn VARIABLES.userSessions>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		New User
	------------------------------------------------------------------------------------->
	<cffunction name="userNew" access="public">
		<cfreturn {
			userID 			= 0,
			siteLandingID	= 0,
			sessions 		= []
		}>
	</cffunction>


</cfcomponent>