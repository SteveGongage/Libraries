<!--- =========================================================================================================
	Created:		Steve Gongage (mm/dd/yyyy)
	Purpose:		

	Usage:			<cfset myThing = new cf.Gongage.something()>

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->
	
	
	
	<!------------------------------------------------------------->
	<!--- Set the following up to match your site --->
	<cfset variables.imagePath			= "/cfc/debuggingTools/images/">
	
	
	<!------------------------------------------------------------->

	<cfset THIS.runUUID					= createUUID()>

	<cfset variables.isOutputEnabled	= true>

	<cfset variables.startTickCount		= getTickCount()>
	<cfset variables.startedAt			= now()>
	<cfset variables.endedAt			= now()>

	<cfset variables.output				= ''>
	<cfset variables.eventLogArray		= arraynew(1)>
	<cfset variables.lastRecordOutput	= 1>

	<cfset variables.count	= {
		warnings	= 0,
		errors		= 0,
		fatals		= 0	
	}>



<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="mode" default="incognito" type="string" required="no" hint="[incognito],screen">
		
		<cfset variables.isOutputEnabled = (arguments.mode IS "screen")>
		
		<!--- Debug log is a singleton (request scope) --->
		<!--- Check request scope to see if this object has been created before.  If so don't recreate it, just return the existing one --->
		<cfif NOT isDefined('request.__debugLog')>
			<cfset request.__debugLog = THIS>
		</cfif>
		
		<cfreturn request.__debugLog>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Add Log - adds a log to the system
		@message.description 	"A text message for the log"
		@type.description		"type of log [debug, info, waypoint, warning, error, fatal]"
		@source.description		""
		@date.description		""

	------------------------------------------------------------------------------------->
	<cffunction name="addLog">
		<cfargument name="message" 	default="">
		<cfargument name="type" 	default="info">
		<cfargument name="data"		default="" type="any" required="false">
		<cfargument name="source"	default="">
		<cfargument name="date" 	default="#now()#">
		
		
		<cfset var logRecord = {
			message		= arguments.message
			, type		= arguments.type
			, isFatal	= ((arguments.type IS 'fatal') ? 1 : 0)
			, ticksIn	= getTickCount() - variables.startTickCount
			, secondsIn	= 0
			, data		= duplicate(arguments.data)
			, timeStamp	= {}
			, sequence	= (arraylen(variables.eventLogArray) + 1)
			, source	= arguments.source
			, date		= arguments.date
		}>
		
		
		<cfset logRecord.secondsIn = round(logRecord.ticksIn / 1000)>

		<cfset logRecord.timeStamp = {
			minutes 		= int(logRecord.secondsIn / 60)
			, seconds 		= logRecord.secondsIn MOD 60
			, miliseconds 	= logRecord.ticksIn MOD 1000
		}>

		<cfset arrayAppend(variables.eventLogArray, logRecord)>
		
		<!---
		<cfset newLine = outputRecord(logRecord)>
		<cfset variables.output &= newLine>
		<cfset saveLog(newLine)>
		--->
		
		
	</cffunction>



<!--- ============================================================================== --->
	<cffunction name="outputRecord">
		<cfargument name="event" 	required="yes">
		<cfargument name="format"	default="table">

		<cfset var currOutput = structnew()>

		<cfif 		arguments.event.type CONTAINS "info">
			<cfset currOutput.style = "color: ##038; ">
			<cfset currOutput.eventImage = 'type_info_16x16.png'>

		<cfelseif 	arguments.event.type CONTAINS "error">
			<cfset variables.count.Errors	+= 1>
			<cfset currOutput.style = "color: maroon; background-color: ##FDD; ">
			<cfset currOutput.eventImage = 'type_error_16x16.png'>

		<cfelseif	arguments.event.type CONTAINS "fatal">
			<cfset variables.count.fatals	+= 1>
			<cfset currOutput.style = "color: white; background-color: maroon; ">
			<cfset currOutput.eventImage = 'type_error_16x16.png'>
		
		<cfelseif 	arguments.event.type CONTAINS "warning">
			<cfset variables.count.warnings	+= 1>
			<cfset currOutput.style = "color: ##900; ">
			<cfset currOutput.eventImage = 'type_warning_16x16.png'>

		<cfelseif 	arguments.event.type CONTAINS "debug">
			<cfset currOutput.style = "color: ##8F00EF; ">
			<cfset currOutput.eventImage = 'type_debug_16x16.png'>

		<cfelseif 	arguments.event.type CONTAINS "waypoint">
			<cfset currOutput.style = "color: white; background-color: ##4572A7; padding: 5px 0px; font-size: 1.1em; ">
			<cfset currOutput.eventImage = 'type_waypoint_16x16.png'>

		</cfif>
		
		
		<cfset currOutput.hasData = NOT isSimpleValue(arguments.event.data) OR arguments.event.data IS NOT "">
		
		
		
		<cfsavecontent variable="currOutput.output">
		<cfoutput>
			<tr class="LogRow #arguments.event.type#" style="vertical-align: top; #currOutput.style#">
				<td style="width: 35px; font-size: 10px;">
					#numberformat(arguments.event.timeStamp.minutes, '000')#:#numberformat(arguments.event.timeStamp.seconds, '00')#.#numberformat(arguments.event.timeStamp.miliseconds, '0000')#
				</td> 
				<td style="width: 70px; font-size: 10px; text-align:right; padding-right: 10px;">
					#arguments.event.type#
					<img src="#variables.imagePath#/#currOutput.eventImage#" style="vertical-align: middle; width: 16px; height: 16px;" alt="#arguments.event.type#">
				</td>
				<td style="width: 70px; font-size: 10px; text-align:left; padding-right: 10px; ">
					#arguments.event.source#
				</td>
				<td style="width: 15px; font-size: 10px; text-align:left; padding-right: 4px;">
					<cfif currOutput.hasData>
						<a href="javascript: debugDataToggle('debugDataDiv_#arguments.event.sequence#'); void(0);" style="text-decoration: none; font-weight: bold;">[+]</a>
					</cfif>
				</td>
				<td>
					#arguments.event.message#
					<cfif currOutput.hasData>
						<div id="debugDataDiv_#arguments.event.sequence#" style="display: none;">
							<cfdump var="#arguments.event.data#">
						</div>
					</cfif>
				</td>
			</tr>
		</cfoutput>
		</cfsavecontent>
		
		<!--- If outputting directly to the screen is enabled, do it now --->
		<cfif variables.isOutputEnabled>
			<cfoutput>#currOutput.output#</cfoutput>
		</cfif>

		
		<cfreturn currOutput.output>
	</cffunction>




<!--- ============================================================================== --->
	<cffunction name="saveLog">
		<cfargument name="newLine" required="yes" type="string">
		<cfargument name="clearLog" required="no" default="false" type="boolean">
		
	</cffunction>		


<!--- ============================================================================== --->
	<cffunction name="output" access="public" hint="Return the formatted log for output">
		<cfargument name="startAtRow" default="#variables.lastRecordOutput#" required="no" type="numeric">
		
		
		<cfset var newOutput = ''>
		<cfsavecontent variable="newOutput">
		<cfoutput>
			<!-- =========================================================================== -->
			<script>
				function debugDataToggle(elementID) {
					var dump = document.getElementById(elementID);
					if (dump.style.display == 'none') {
						dump.style.display = 'block';
					} else {
						dump.style.display = 'none';	
					}
				}
			</script>
			
			<style>
				TABLE.debugLogOutputTable  { width: 100%; font-size: 11px; border-bottom: 1px dotted silver; margin: 3px 0; }
					TABLE.debugLogOutputTable TD TABLE { width: auto; }		/* Prevent Dump Tables from being stretched */
			</style>
			
			<table class="debugLogOutputTable" cellpadding="3">
				<cfloop from="#arguments.startAtRow#" to="#arraylen(variables.eventLogArray)#" index="i">
					#outputRecord(variables.eventLogArray[i])#
				</cfloop>
			</table>
			<!-- =========================================================================== -->
		</cfoutput>
		</cfsavecontent>

		<cfset variables.lastRecordOutput = arraylen(variables.eventLogArray) + 1>

		<cfreturn newOutput>
	</cffunction>
	


	
</cfcomponent>
