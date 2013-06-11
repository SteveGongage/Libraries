<!--- =========================================================================================================
	Created:		Steve Gongage (5/20/2013)
	Purpose:		Create a singleton class easily by extending this component.

	Usage:			Create another component to extend this component. 
					In the INIT method, use the following line at the end to make sure to return the singleton.

						<cffunction name="init">
							<cfreturn super.init('mySingletonName', 'request')>
						</cffunction>


========================================================================================================= --->
<cfcomponent displayname="Singleton">


	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" hint="Init method for the Singleton component">
		<cfargument name="name" 	required="true" type="string" hint="Name of this singleton">
		<cfargument name="scope"	required="false" type="string" default="request" hint="['request', 'application', 'session']">

		<cfif NOT arrayFindNoCase(['request', 'application', 'session'], arguments.scope)>
			<cfthrow message="Invalid Singleton Scope: '#arguments.scope#'">
		</cfif>

		<cfset var storagePath = '#arguments.scope#.__#arguments.name#'>

		<!--- Check request scope to see if this object has been created before.  If so don't recreate it, just return the existing one --->
		<cfif NOT isDefined(storagePath)>
			<!--- Yup... using left hand side expressions... sue me. ---> 
			<cfset #storagePath# = THIS>
		</cfif>
		
		<cfreturn #storagePath#>
	</cffunction>



</cfcomponent>
