<!--- =========================================================================================================
	Created:		Steve Gongage (5/15/2013)
	Notes:			REQUEST SCOPE SINGLETON
	Purpose:		Encapsulates methods and information related to developer usage of the application.  
					If not enabled, no public method should actually perform any operation and no sub component 
					should be instantiated.  This will prevent unnecessary overhead in production environments but
					allow us to keep certain code in place so we don't have to redo it whenever going back to development.

	Usage:			<cfset request.devTools = new cfc.DebuggingTools.developerTools()>

========================================================================================================= --->

<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->
	
	
	<cfset this.isEnabled 			= false>
	<cfset this.isDeveloperRequired	= true>
	
	<cfset this.settings = {
		commands	= []
		, devName	= ''
	}>
	
	<cfset this.inputs = {
		devName = ''
		, reset		= false
		, debug			= false
		, commandsOn 	= []
		, commandsOff 	= []
		, commands		= []
	}>
	
	
	<!---
		Command Line Arguments:
			
			_dev 		= developerName	: persistent
			_devOn 		= [commands] 	: persistent
			_devOff		= [commands]	: persistent
			_devCom		= [commands]	: instant
			_devReset					: instant
			_devdebug					: instant
	
	---->
	
	<!---
		CFWheels Environments: design, development, production, testing, maintenance
	--->


<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="isDevEnabled" 		required="no" type="boolean" default="false">
		<cfargument name="isDeveloperRequired"		required="no" type="boolean" default="true">
		
		<!--- ============================================= --->
		<!--- DeveloperTools is a singleton (request scope) --->
		<cfif NOT isDefined('request.__developerTools')>
			<!--- Check request scope to see if this object has been created before.  If so don't recreate it, just return the existing one --->
			<cfset request.__developerTools = THIS>
		</cfif>
		<!--- ============================================= --->


		
		<!--- ===================================== --->
		<!--- SETUP SETTINGS --->

		<!--- Test for Session --->
		<cfif NOT isDefined('session')>
			<cfthrow message="Developer tools cannot operate without a defined session scope">
		</cfif>
		
		<!--- Initialize the session if it doesn't exist or if it's time to reset --->
		<cfif NOT structKeyExists(session, '__developer') OR structKeyExists(url, '_devReset')>
			<cfset this.input.reset 	= true>
			<cfset session.__developer 	= duplicate(this.settings)>
		</cfif>
		
		
		
		<!--- ========================================================== 
			IS ENABLED?  
				Dev tools must be enabled (usually by the environment) in order to do anything else...
		=========================================================== --->
		<cfset this.isEnabled 			= arguments.isDevEnabled>
		<cfset this.isDeveloperRequired 	= arguments.isDeveloperRequired>


		<cfif isEnabled()>
			<!--- Now see if a developer has been enabled --->
			<cfif structKeyExists(url, '_dev')>
				<!--- If a developer is set in the URL then save that to session --->
				<cfset session.__developer.devName 	= url._dev>
			</cfif>
				
			<cfif session.__developer.devName IS NOT "">
				<!--- Use any session level developer for the rest of this request --->
				<cfset this.settings.devName 		= session.__developer.devName>
			</cfif>
			
			<!--- Check for the Debug Command --->
			<cfif isEnabled() AND structKeyExists(url, '_devdebug')>
				<cfset this.inputs.debug	= true> 
			</cfif> 
			
		</cfif>
		
	
		<!--- ========================================================== 
			IS ON?  
				Do not do anything else unless developer tools are enabled and a developer has 'signed in' 
		=========================================================== --->
		<cfif isOn()>
			<cfif structKeyExists(url, '_devcom')>
				<cfset this.inputs.commands = listToArray(url._devcom)>
			</cfif>
			<cfif structKeyExists(url, '_devOn')>
				<cfset this.inputs.commandsOn = listToArray(url._devOn)>
			</cfif>
			<cfif structKeyExists(url, '_devOff')>
				<cfset this.inputs.commandsOff = listToArray(url._devOff)>
			</cfif>


			<!--- Get the existing persistent commands --->
			<cfif isDefined('session.__developer.commands')>
				<cfset this.settings.commands = session.__developer.commands>
			</cfif>

			
			<!--- Get New 'instant' Commands that don't get saved in session --->
			<cfloop array="#this.inputs.commands#" index="currCommand">
				<cfset arrayAppend(this.settings.commands, currCommand)>
			</cfloop>

			<!--- Remove Persistent Commands (also remove from session) --->
			<cfloop array="#this.inputs.commandsOff#" index="currCommand">
				<cfif arrayFindNoCase(this.settings.commands, currCommand)>
					<cfset arrayDeleteAt(this.settings.commands, arrayFindNoCase(this.settings.commands, currCommand))>
				</cfif>
				<cfif arrayFindNoCase(session.__developer.commands, currCommand)>
					<cfset arrayDeleteAt(session.__developer.commands, arrayFindNoCase(session.__developer.commands, currCommand))>
				</cfif>
			</cfloop>

			<!--- Get Persistent Commands (also add to session) --->
			<cfloop array="#this.inputs.commandsOn#" index="currCommand">
				<cfif NOT arrayFindNoCase(this.settings.commands, currCommand)>
					<cfset arrayAppend(this.settings.commands, currCommand)>
				</cfif>
				<cfif NOT arrayFindNoCase(session.__developer.commands, currCommand)>
					<cfset arrayAppend(session.__developer.commands, currCommand)>
				</cfif>
			</cfloop>
			
			
	
			
			<!--- =====================================================================
				Now create any sub components 	
					These sub components are not created earlier because 
					we want to minimize the footprint of this component in memory 
					if it is not even enabled or turned on by an active dev
			======================================================================= --->
			<cfset this.log = new DebugLog()>
			<cfset this.log.addLog('Initialized Developer Tools - DevName: #this.settings.devName#', 'info', this.settings, 'developerTools')>
			
			
		</cfif>
		
		
		<cfif this.inputs.debug>
			<cfdump var="#this.inputs#" label="inputs">
			<cfdump var="#this.settings#" label="Request">
			<cfdump var="#session.__developer#" label="Session">
			<cfabort>
		</cfif>

		
		<cfreturn request.__developerTools>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		isEnabled
			Are the dev tools enabled?  Without this as TRUE nothing else will work.  
			Switched on and off during the INIT by an argument passed in and should
			be determined by the server environment (DEV, QA, PROD, etc...)
	------------------------------------------------------------------------------------->
	<cffunction name="isEnabled" access="public">
		<cfreturn this.isEnabled>
	</cffunction>
	

	<!-----------------------------------------------------------------------------------
		isOn
			Are the dev tools enabled AND is there a developer present?
			Must be turned on by using the "_dev" command line argument with a name for the dev.
	------------------------------------------------------------------------------------->
	<cffunction name="isOn" access="public">
		<cfreturn isEnabled() AND (NOT this.isDeveloperRequired OR this.settings.devName IS NOT "")>
	</cffunction>
	

	<!-----------------------------------------------------------------------------------
		isDeveloper
			IS the current developer X?  Only works when the dev tools are "ON".
	------------------------------------------------------------------------------------->
	<cffunction name="isDeveloper" access="public">
		<cfargument name="devName" required="yes" type="string">
		<cfreturn isOn() AND arguments.devName IS this.settings.devName>
	</cffunction>
	<cffunction name="isDev" access="public">
		<cfargument name="devName" required="yes" type="string">
		<cfreturn isDeveloper(arguments.devName)>
	</cffunction>
	

	<!-----------------------------------------------------------------------------------
		isCommand
			Is the developer command on?  Only works when the dev tools are "ON".
	------------------------------------------------------------------------------------->
	<cffunction name="isCommand" access="public">
		<cfargument name="commandName" required="yes" type="string">
		<cfreturn isOn() AND arrayFindNoCase(this.settings.commands, arguments.commandName)>
	</cffunction>
	

	<!-----------------------------------------------------------------------------------
		AddLog
			Passthrough method for this.log.addLog.  Only works when the dev tools are "ON".
	------------------------------------------------------------------------------------->
	<cffunction name="addLog" access="public">
		<cfargument name="message" 	default="">
		<cfargument name="type" 	default="info">
		<cfargument name="data"		default="" type="any">
		<cfargument name="source"	default="">
		<cfargument name="date" 	default="#now()#">
		<cfif NOT isOn()>	<cfreturn>	</cfif>	<!--- Do not run this code if dev tools are not enabled --->

		<cfset this.log.addLog(arguments.message, arguments.type, arguments.data, arguments.source, arguments.date)>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		LogOutput
			Passthrough method for this.log.output.  Only works when the dev tools are "ON".
	------------------------------------------------------------------------------------->
	<cffunction name="logOutput" access="public">
		<cfif NOT isOn()>	<cfreturn>	</cfif>	<!--- Do not run this code if dev tools are not enabled --->
		
		<cfreturn this.log.output()>
	</cffunction>


</cfcomponent>