<!--- =========================================================================================================
	Created:		Steve Gongage (5/08/2013)
	Purpose:		
	Notes:			REQUEST SCOPE SINGLETON - For any given request, 
	Usage:			use the parent CFC "debugTools.cfc" using the following:
						<cfset request.debugTools = new cfc.DebuggingTools.developerTools()>
						
					then access using:
						request.debugTools.log.addLog('blarg!')

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

	<cfset variables.sources 			= arraynew(1)>

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
	<cffunction name="addLog" access="public">
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
		
		<!--- Save this source for later --->
		<cfif arguments.source IS "">
			<cfset arguments.source = "Unspecified">
		</cfif>

		<cfif NOT arrayFindNoCase(variables.sources, arguments.source)>
			<cfset arrayAppend(variables.sources, arguments.source)>
		</cfif>
		
		<cfset logRecord.secondsIn = round(logRecord.ticksIn / 1000)>

		<cfset logRecord.timeStamp = {
			minutes 		= int(logRecord.secondsIn / 60)
			, seconds 		= logRecord.secondsIn MOD 60
			, miliseconds 	= logRecord.ticksIn MOD 1000
		}>

		<cfset arrayAppend(variables.eventLogArray, logRecord)>
		
	</cffunction>




<!--- ============================================================================== --->
	<cffunction name="output" access="public" hint="Return the formatted log for output">
		<cfargument name="startAtRow" default="#variables.lastRecordOutput#" required="no" type="numeric">
		
		<cfparam name="request.debugTools.debugLog.hasOutputControls" default="false">

		<cfset var newOutput = ''>
		<cfsavecontent variable="newOutput">
		<cfoutput>

			<!-- =========================================================================== -->
			<!-- Debug logging: Begin -->

			<!--- We only want to output these controls the first time this is called per request... --->
			<cfif request.debugTools.debugLog.hasOutputControls>
				<!--- Continue outputting logs without controls since this was done once before --->
				<!--- Wrapper for Logs with controls at the top --->
				<div class="debugOutput">
					<div class="debugOutputTitle">Debug Output Continued...</div>
					<table class="debugLogOutputTable" cellpadding="3">
						<cfloop from="#arguments.startAtRow#" to="#arraylen(variables.eventLogArray)#" index="i">
							#outputRecord(variables.eventLogArray[i])#
						</cfloop>
					</table>
				</div>
			<cfelse>
				<!--- We only want to output these controls the first time this is called per request... --->
				<cfset request.debugTools.debugLog.hasOutputControls = true>

				<!--- Javascript controls --->
				<script>
					function debugDataToggle(elementID) {
						var dump = document.getElementById('debugDataDiv_'+ elementID);
						var link = document.getElementById('debugLink_'+ elementID);

						link.className = link.className.replace(/\bactive\b/,'');

						if (dump.style.display == 'none') {
							dump.style.display 		= 'block';
							link.innerHTML 			= '[-]';
							link.className 			+=  ' active';
						} else {
							dump.style.display 		= 'none';	
							link.innerHTML 			= '[+]';
						}
					}

					function highlightSource(sourceName) {
						var allLogRows = document.getElementsByClassName('logRow');
						var currClassName = '';
						
						var clearButton = document.getElementById('debugSourceClearButton');
						clearButton.className = clearButton.className.replace(/\bmute\b/,'');
						if (sourceName == '') {
							clearButton.className += ' mute';
						}

						for each(row in allLogRows) {
							currClassName = row.className;

							if (typeof(currClassName) != 'undefined') {
								row.className = row.className.replace(/\bmute\b/,'');

								if (sourceName != '') {
									row.className += ' mute';

									if (sourceName != '' && currClassName.indexOf(sourceName) >= 0) {
										row.className = row.className.replace(/\bmute\b/,'');
									}

								}
							}
						}
					}
				</script>
				
				<!--- Styles to apply --->
				<style>
					.debugOutput { border: 1px solid silver; margin: 2em 0em; padding: 0em; font-family: verdana; font-size: 10px;}
						.debugOutput .debugOutputTitle { border-bottom: 1px solid silver;  padding: 2px; text-align: center; color: ##FFF; background-color: ##4572A7; font-size: 1.2em; font-weight: bold;}

						.debugOutput .debugOutputSourceButtons { border-bottom: 1px solid silver; margin-bottom: 1em; padding: 5px; text-align: center;}
						.debugOutput A.debugSourceButton { text-decoration: none; background-color: ##FFA; padding: 2px 5px; margin: 5px; border: 1px solid silver; border-radius: 5px;   }
							.debugOutput A.debugSourceButton:HOVER { text-decoration:  none; background-color: ##FF8;}
							.debugOutput A.debugSourceButton:ACTIVE { text-decoration:  none; background-color: ##FF8;}

							.debugOutput A.debugSourceButton.clearButton 			{ background-color: gold;}
								.debugOutput A.debugSourceButton.clearButton.mute 	{ color: ##BBB; background-color: ##D8D8D8; }


					TABLE.debugLogOutputTable  { width: 100%; border-bottom: 1px dotted silver; margin: 0px; font-size: 10px; font-family: Courier New, monospace; border-collapse: collapse;}
						TABLE.debugLogOutputTable TD { text-align: left; }


					TABLE.debugLogOutputTable TR TD { vertical-align: top; border-top: 1px solid white; border-bottom: 1px solid white;}

					TABLE.debugLogOutputTable TR { border-right: 5px solid white;}
					/*
					TABLE.debugLogOutputTable TR.logRow.mute TD 	{ color: ##BBB; background-color: ##CCC; }
					TABLE.debugLogOutputTable TR.waypoint.mute TD 	{ color: ##888; background-color: ##DDD; }
					*/
					TABLE.debugLogOutputTable TR.logRow.mute IMG 	{ visibility: hidden; } 	
					TABLE.debugLogOutputTable TR.logRow.mute TD 	{ color: transparent; background-color: ##BBB; text-shadow: 0 0 5px rgba(0,0,0,0.5); }
					TABLE.debugLogOutputTable TR.waypoint.mute TD 	{ color: ##999; background-color: ##DDD; text-shadow: 0 0 5px rgba(0,0,0,0.7); }
					

					TABLE.debugLogOutputTable TR.info 		{color: ##038; 		background-color: ##FFF; }
					TABLE.debugLogOutputTable TR.highlight	{color: ##8F00EF;	background-color: ##FEF; border-color: ##8F00EF; }
					TABLE.debugLogOutputTable TR.error 		{color: ##600; 		background-color: ##FDD; border-color: ##A00; }
					TABLE.debugLogOutputTable TR.fatal 		{color: ##600; 		background-color: ##FAA; border-color: ##A00; }
					TABLE.debugLogOutputTable TR.warning	{color: ##900; 		background-color: ##FFC; border-color: ##FF0; }
					TABLE.debugLogOutputTable TR.debug 		{color: ##8F00EF; 	background-color: ##FFF; }
					TABLE.debugLogOutputTable TR.waypoint	{color: ##FFF; 		background-color: ##4572A7; border-color: ##4572A7; }

		
					/* Prevent Dump Tables styles from being overridden */
					TABLE.debugLogOutputTable TD TABLE { width: auto; }		
						TABLE.debugLogOutputTable TD TABLE TD 			{ color: ##333; background-color: white;}
						TABLE.debugLogOutputTable TR.mute TD TABLE TD 	{ color: ##333 !important; background-color: white !important;}
					TABLE.debugLogOutputTable A.debugToggleLink { text-decoration: none; font-weight: bold; color: ##06A; background-color: ##AFA; border: 1px dotted silver; border-radius: 5px;}
						TABLE.debugLogOutputTable A.debugToggleLink:hover { border: 1px solid gray;}
						TABLE.debugLogOutputTable A.debugToggleLink.active { border: 1px solid gray; background-color: ##0C0;}

						TABLE.debugLogOutputTable TR.mute A.debugToggleLink { background-color: ##BDB; color: ##AAA;}

				</style>
				
				<!--- Wrapper for Logs with controls at the top --->
				<div class="debugOutput">
					<div class="debugOutputTitle">Debug Output</div>

					<div class="debugOutputSourceButtons">
						<cfif arraylen(variables.sources) GT 0>
							<a href="javascript: void(0);" onClick="highlightSource('')" class="debugSourceButton clearButton mute" id="debugSourceClearButton" >Clear</a>
							
							<cfset arraySort(variables.sources, 'textNoCase')>
							<cfloop array="#variables.sources#" index="currItem">
								<cfset currItemClean = replace(currItem, ' ', '', 'all')>
								<a href="javascript: void(0);" onClick="highlightSource('#lcase(currItemClean)#');" class="debugSourceButton">#currItem#</a>
							</cfloop>
						</cfif>
					</div>

					<table class="debugLogOutputTable" cellpadding="3">
						<cfloop from="#arguments.startAtRow#" to="#arraylen(variables.eventLogArray)#" index="i">
							#outputRecord(variables.eventLogArray[i])#
						</cfloop>
					</table>
				</div>
			</cfif>

			<!-- Debug logging: End -->
			<!-- =========================================================================== -->			
	
		</cfoutput>
		</cfsavecontent>

		<cfset variables.lastRecordOutput = arraylen(variables.eventLogArray) + 1>

		<cfreturn newOutput>
	</cffunction>
	
	
	
	
<!--- ============================================================================== --->
	<cffunction name="outputRecord" access="private">
		<cfargument name="event" 	required="yes">
		<cfargument name="format"	default="table">

		<cfset var currOutput = structnew()>
		<cfset currOutput.eventImage 	= 'type_#arguments.event.type#_16x16.png'>
		<cfset currOutput.hasData = NOT isSimpleValue(arguments.event.data) OR arguments.event.data IS NOT "">
		<cfset currOutput.sourceClass = "source_unspecified">
		<cfif arguments.event.source IS NOT "">
			<cfset currOutput.sourceClass = "source_"& replace(arguments.event.source, ' ', '', 'all')>		
		</cfif>

		<cfsavecontent variable="currOutput.output">
		<cfoutput>
			<tr class="logRow #arguments.event.type# #lcase(currOutput.sourceClass)#">
				<td style="width: 80px; ">
					<strong>#numberformat(arguments.event.timeStamp.minutes, '000')#:#numberformat(arguments.event.timeStamp.seconds, '00')#</strong><em style="font-size: 8.4px; vertical-align: bottom;">.#numberformat(arguments.event.timeStamp.miliseconds, '0000')#</em>
				</td> 
				<td style="width: 80px; text-align:right; padding-right: 10px;">
					#arguments.event.type#
					<img src="#variables.imagePath#/#currOutput.eventImage#" style="vertical-align: middle; width: 16px; height: 16px;">
				</td>
				<!---
				<td style="width: 70px; text-align:left; padding-right: 10px; ">
					#arguments.event.source#
				</td>
				--->
				<td style="width: 15px; text-align:left; padding-right: 4px;">
					<cfif currOutput.hasData>
						<a href="javascript: debugDataToggle('#arguments.event.sequence#'); void(0);" id="debugLink_#arguments.event.sequence#" class="debugToggleLink">[+]</a>
					</cfif>
				</td>
				<td>
					<cfif arguments.event.source IS NOT "" AND arguments.event.source IS NOT "unspecified">
						<strong style="font-style: italic;">[#arguments.event.source#]</strong>					
					</cfif>
					
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





	
</cfcomponent>
