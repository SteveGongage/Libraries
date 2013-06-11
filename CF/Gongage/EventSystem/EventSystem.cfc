<!--- =========================================================================================================
	Created:		Steve Gongage (mm/dd/yyyy)
	Purpose:		This code was never completed.  It's not working yet, but I started the functions below while working on something else and didn't want to lose them.

	Usage:			<cfset myThing = new cf.Gongage.something()>

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->




<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		HandleChangeEvent
			When a change happens to a line of data, trigger any registered event
	------------------------------------------------------------------------------------->
	<cffunction name="triggerChangeEvent" access="private">
		<cfargument name="changedKey"  required="yes" type="string">
		
		<cfset var LOCAL.key	= arguments.changedKey>
		<cfset var LOCAL.value 	= get(LOCAL.key)>
		
		
		<cfset THIS.changeEvents = {
			'EDUQualified' 		= 'request.trackingSystem.siteLanding.set(key, value)'
			, 'resumeSubmitted'	= 'request.trackingSystem.siteLanding.set(key, value)'
			, 'userID'			= 'request.trackingSystem.siteLanding.handleUserLogin(value)'
		}>
		
		
		<cfif structKeyExists(this.changeEvents, LOCAL.key)>
			<cfset request.devTools.addLog('Skipping Event Triggering for #local.key# - Commented out for testing...', 'warning', session.userInfo, 'UserInfo')>
			<!---
			<cfset evaluate(this.changeEvents[LOCAL.key])>
			<cfset request.devTools.addLog('Change Event triggered: #local.key# - #this.changeEvents[LOCAL.key]#', 'info', session.userInfo, 'UserInfo')>
			--->
		</cfif>
	</cffunction>
	
	<!-----------------------------------------------------------------------------------
		RegisterChangeEvent
			Register code that will be triggered whenever an event takes place...
	------------------------------------------------------------------------------------->
	<cffunction name="registerChangeEvent" access="private">
		
	
	</cffunction>
	

</cfcomponent>

