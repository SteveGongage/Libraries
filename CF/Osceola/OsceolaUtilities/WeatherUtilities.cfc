<cfcomponent>
	
	<cfset this.utilities.data = new osceola.OsceolaUtilities.dataUtilities()>
	
	
	
    
	<!--- ============================================================================================= --->
	<!--- function: GetWeatherData --->
	<!--- Knows NOTHING about how to talk to yahoo or fire web services --->
	<cffunction name="getWeatherData">
		<cfargument name="yahooWID" default="12772836">
		<cfargument name="usfdStationID" default="089966">
		
		<!--- Combine Data into one structure --->
		<cfset var stCombinedData = structnew()>
		<cfset stCombinedData.stWeatherData 	= fstGetWeatherDataYahoo(arguments.yahooWID)>
		<cfset stCombinedData.stFireData		= fstGetFireDataUSFD(arguments.usfdStationID)>
		
		<cfreturn stCombinedData>
	</cffunction>
	
	
	
	<!--- ============================================================================================= --->
	<!--- function: GetWeatherDataYahoo --->
	<!--- Knows everything about how to talk to yahoo --->
	<cffunction name="fstGetWeatherDataYahoo" access="private">
		<cfargument name="yahooWID" required="yes">
		
		<cfset var stResponseData = structnew()>
		<cfset stResponseData.success 					= true>
		<cfset stResponseData.reason 					= '' />
		<cfset stResponseData.sCity 					= '' />
		<cfset stResponseData.sState 					= '' />
		<cfset stResponseData.sCountry					= '' />
		<cfset stResponseData.sUnitsDistance			= '' />
		<cfset stResponseData.sUnitsPressure			= '' />
		<cfset stResponseData.sUnitsSpeed				= '' />
		<cfset stResponseData.sUnitsTemp				= '' />
		<cfset stResponseData.nWindChill				= 0 />
		<cfset stResponseData.nWindDirectionDegrees		= 0 />
		<cfset stResponseData.nWindSpeed				= 0 />
		<cfset stResponseData.nAtmosphereHumidity		= 0 />
		<cfset stResponseData.nAtmospherePressure		= 0 />
		<cfset stResponseData.nAtmosphereRising			= 0 />
		<cfset stResponseData.nAtmosphereVisibility		= 0 />
		<cfset stResponseData.tSunRise 					= '' />
		<cfset stResponseData.tSunSet 					= '' />
		<cfset stResponseData.nConditionsCode			= 0 />
		<cfset stResponseData.dConditionsDate			= '' />
		<cfset stResponseData.nConditionsTemp			= 0 />
		<cfset stResponseData.sConditionsDesc			= '' />
		<cfset stResponseData.nConditionsHigh			= 0 />
		<cfset stResponseData.nConditionsLow			= 0 />
		
		<!--- Get Remote Data --->
    	<cfhttp method="get" url="http://weather.yahooapis.com/forecastrss?w=#arguments.yahooWID#" result="stRemoteResponse" />
        <cfif NOT stRemoteResponse.StatusCode CONTAINS "200 OK">
			<cfset stResponseData.success = false>
        	<cfset stResponseData.reason = "CFHTTP to remote site failed." />
		<cfelse>
			<!--- Everything good to go! --->
			
			<!--- Isolate the yweather attributes and populate an array with them --->
			<cfset xmlWeatherData 	= XmlParse(stRemoteResponse.filecontent) />
            <cfset arrWeatherNodes 	= XmlSearch(xmlWeatherData, "//yweather:*/@*") />
            
            <cfset stResponseData.sCity 					= Trim(arrWeatherNodes[1].XmlValue) />
			<cfset stResponseData.sState 					= Trim(arrWeatherNodes[3].XmlValue) />
            <cfset stResponseData.sCountry					= Trim(arrWeatherNodes[2].XmlValue) />
            <cfset stResponseData.sUnitsDistance			= Trim(arrWeatherNodes[4].XmlValue) />
            <cfset stResponseData.sUnitsPressure			= Trim(arrWeatherNodes[5].XmlValue) />
            <cfset stResponseData.sUnitsSpeed				= Trim(arrWeatherNodes[6].XmlValue) />
            <cfset stResponseData.sUnitsTemp				= Trim(arrWeatherNodes[7].XmlValue) />
            <cfset stResponseData.nWindChill				= Trim(arrWeatherNodes[8].XmlValue) />
            <cfset stResponseData.nWindDirectionDegrees		= Trim(arrWeatherNodes[9].XmlValue) />
			<cfset stResponseData.nWindSpeed				= Trim(arrWeatherNodes[10].XmlValue) />
            <cfset stResponseData.nAtmosphereHumidity		= Trim(arrWeatherNodes[11].XmlValue) />
            <cfset stResponseData.nAtmospherePressure		= Trim(arrWeatherNodes[12].XmlValue) />
            <cfset stResponseData.nAtmosphereRising			= Trim(arrWeatherNodes[13].XmlValue) />
            <cfset stResponseData.nAtmosphereVisibility		= Trim(arrWeatherNodes[14].XmlValue) />
			<cfset stResponseData.tSunRise 					= CreateODBCDateTime(CreateDateTime(DateFormat(Now(), "yyyy"), DateFormat(Now(), "m"), DateFormat(Now(), "d"), TimeFormat(arrWeatherNodes[15].XmlValue, "h"), TimeFormat(arrWeatherNodes[15].XmlValue, "mm"), TimeFormat(arrWeatherNodes[15].XmlValue, "ss"))) />
            <cfset stResponseData.tSunSet 					= CreateODBCDateTime(CreateDateTime(DateFormat(Now(), "yyyy"), DateFormat(Now(), "m"), DateFormat(Now(), "d"), TimeFormat(arrWeatherNodes[16].XmlValue, "h"), TimeFormat(arrWeatherNodes[16].XmlValue, "mm"), TimeFormat(arrWeatherNodes[16].XmlValue, "ss"))) />
            <cfset stResponseData.nConditionsCode			= Trim(arrWeatherNodes[17].XmlValue) />
            <cfset stResponseData.dConditionsDate			= Trim(CreateODBCDateTime(arrWeatherNodes[18].XmlValue)) />
            <cfset stResponseData.nConditionsTemp			= Trim(arrWeatherNodes[19].XmlValue) />
            <cfset stResponseData.sConditionsDesc			= Trim(arrWeatherNodes[20].XmlValue) />
            <cfset stResponseData.nConditionsHigh			= Trim(arrWeatherNodes[24].XmlValue) />
            <cfset stResponseData.nConditionsLow			= Trim(arrWeatherNodes[25].XmlValue) />
        </cfif>
		
		
		
		<cfreturn stResponseData>
	</cffunction>
	
	<!--- ============================================================================================= --->
	<!--- function: GetFireDAtaUSFD --->
	<cffunction name="fstGetFireDataUSFD" access="private">
		<cfargument name="stationID" required="yes">
		<cfset var stResponseData = structnew()>
		<cfset stResponseData.success 			= true>
		<cfset stResponseData.reason 			= ''>
		<cfset stResponseData.dKBDIObserved		= '' />
		<cfset stResponseData.nKBDIObserved		= 0 />
		<cfset stResponseData.dKBDIForecast		= '' />
		<cfset stResponseData.nKBDIForecast		= 0 />
		
		<!--- Get Remote Data --->
    	<cfhttp method="get" url="http://www.wfas.net/cgi-bin/find_fdr.cgi?station=#arguments.stationID#" result="stRemoteResponse" />
        <cfif NOT stRemoteResponse.StatusCode CONTAINS "200 OK">
			<cfset stResponseData.success = false>
        	<cfset stResponseData.reason = "CFHTTP to remote site failed." />
		<cfelse>
			<cfset xmlFireData 	= this.utilities.data.HTMLtoXHTML(stRemoteResponse.filecontent) />
        	<!--- Set the KBDI (Keetch-Bryam Drought Index) variables --->
			<cfset stResponseData.dKBDIObserved		= CreateODBCDate(Now()) />
            <cfset stResponseData.nKBDIObserved		= Trim(xmlFireData.html.body.table.tr[16].td[2].b.b.XmlText) />
            <cfset stResponseData.dKBDIForecast		= CreateODBCDate(DateAdd('d', 1, Now())) />
            <cfset stResponseData.nKBDIForecast		= Trim(xmlFireData.html.body.table.tr[16].td[3].b.b.XmlText) />
		</cfif>
		
		<cfreturn stResponseData>
	</cffunction>


	
	
	<!--- ============================================================================================= --->
    <cffunction name="insertWeatherData" access="public" returntype="any">
		<cfargument name="stCombinedWeatherData" required="yes" type="struct">
		
		<cfset var bWasSuccess = true>
		
		<cfif NOT stCombinedWeatherData.stFireData.success OR NOT stCombinedWeatherData.stWeatherData.success>
			<cfset bWasSuccess = false>
		<cfelse>
			<cfquery name="qWeatherInsert" datasource="#request.global.datasource.cmsModules#">
				INSERT INTO Weather_PeriodicData (
					sCity,
					sState,
					sCountry,
					sUnitsDistance,
					sUnitsPressure,
					sUnitsSpeed,
					sUnitsTemp,
					nWindChill,
					nWindDirectionDegrees,
					nWindSpeed,
					nAtmosphereHumidity,
					nAtmospherePressure,
					nAtmosphereRising,
					nAtmosphereVisibility,
					tSunrise,
					tSunset,
					nConditionsCode,
					dConditionsDate,
					nConditionsTemp,
					sConditionsDesc,
					nConditionsHigh,
					nCOnditionsLow,
					nKBDIObserved,
					dKBDIObserved,
					nKBDIForecast,
					dKBDIForecast,
					dEntered,
					dLastMod
					
				) VALUES (
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sCity#" 				cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sState#" 				cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sCountry#" 				cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sUnitsDistance#" 		cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sUnitsPressure#" 		cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sUnitsSpeed#" 			cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sUnitsTemp#" 			cfsqltype="cf_sql_varchar" />,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nWindChill)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nWindChill#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nWindDirectionDegrees)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nWindDirectionDegrees#" cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nWindSpeed)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nWindSpeed#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,

					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nAtmosphereHumidity)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nAtmosphereHumidity#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nAtmospherePressure)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nAtmospherePressure#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nAtmosphereRising)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nAtmosphereRising#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nAtmosphereVisibility)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nAtmosphereVisibility#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.tSunrise#" 				cfsqltype="cf_sql_timestamp" />,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.tSunset#" 				cfsqltype="cf_sql_timestamp" />,

					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nConditionsCode)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nConditionsCode#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,

					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.dConditionsDate#" 		cfsqltype="cf_sql_timestamp" />,

					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nConditionsTemp)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nConditionsTemp#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,

					<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.sConditionsDesc#" 		cfsqltype="cf_sql_varchar" />,

					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nConditionsHigh)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nConditionsHigh#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfif isNumeric(arguments.stCombinedWeatherData.stWeatherData.nConditionsLow)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stWeatherData.nConditionsLow#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,

					<cfif isNumeric(arguments.stCombinedWeatherData.stFireData.nKBDIObserved)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stFireData.nKBDIObserved#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stFireData.dKBDIObserved#" 			cfsqltype="cf_sql_timestamp" />,
					<cfif isNumeric(arguments.stCombinedWeatherData.stFireData.nKBDIForecast)>
						<cfqueryparam value="#arguments.stCombinedWeatherData.stFireData.nKBDIForecast#" 			cfsqltype="cf_sql_integer" />
						<cfelse><cfqueryparam null="yes" cfsqltype="cf_sql_integer" ></cfif>,
					<cfqueryparam value="#arguments.stCombinedWeatherData.stFireData.dKBDIForecast#" 			cfsqltype="cf_sql_timestamp" />,
					<cfqueryparam value="#CreateODBCDateTime(Now())#" cfsqltype="cf_sql_timestamp" />,
					<cfqueryparam value="#CreateODBCDateTime(Now())#" cfsqltype="cf_sql_timestamp" />
					
				)
			</cfquery>
		   
			
		</cfif>
        	
		
        <cfreturn bWasSuccess />
    </cffunction>
</cfcomponent>