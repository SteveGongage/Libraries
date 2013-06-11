<cfcomponent>


	
	<!--- ========================================================== --->
	<!--- Get Geo Data: Retrieves geo location data from a page and prepares it for mapping --->
	<cffunction name="getOverlayWebPathByName" access="public">
		<cfargument name="overlayName" 		required="yes" type="string">
		<cfset var KMLOverlayWebPath = "">
		<cfset var serverName = cgi.server_name>
		
		<!--- In test environments, point the the main server for KML files --->
		<cfif isDefined('request.data')>
			<cfif request.data.get('domainName').get('isDeveloperDomain')>
				<cfset serverName = 'www.osceola.org'>
			</cfif>
		</cfif>
		
		<cfif arguments.overlayName CONTAINS "HTTP://">
			<cfset KMLOverlayWebPath = overlayName>
		
		<cfelseif arguments.overlayName IS NOT "" >
		
			<cfset var KMLOverlayFile = replace(arguments.overlayName, ' ', '', 'all')>
			<cfset var KMLOverlayPath = "/files/common/KMLOverlays/#KMLOverlayFile#.kml">

			<cfif fileExists(expandPath(KMLOverlayPath))>
				<cfset KMLOverlayWebPath = "http://#serverName##KMLOverlayPath#">
			</cfif>
		</cfif>
		
		
		<cfreturn KMLOverlayWebPath>
	</cffunction>
	
	
	<!--- ========================================================== --->
	<!--- Adds a single or array of overlays to a google map name.  Center point is needed for the redraw javascript --->
	<cffunction name="getGoogleAPIKeyForDomain" access="public">
		<cfargument name="currentDomain" required="no" default="" type="string">
		
		<cfif arguments.currentDomain IS "">
			<cfset arguments.currentDomain = cgi.http_host>			
		</cfif>
		
		<cfquery name="getDomainInfo" datasource="#request.global.datasource.cms#">
			SELECT key_googleMapsAPI FROM Domain WHERE domainName = <cfqueryparam value="#trim(arguments.currentDomain)#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn getDomainInfo.key_googleMapsAPI>	
	</cffunction>
 	

	<!--- ========================================================== --->
	<!--- Adds a single or array of overlays to a google map name.  Center point is needed for the redraw javascript --->
	<!---
		Example: 
		<cfset overlayName		= 'CountyBorders'>
		<cfset googleMapName 	= 'MyGoogleMapID'>
		<cfset centerPoint 		= {mapAddress = '1 courthouse sq, suite 2200, kissimmee, fl, 34741', accuracy = 'street'}>
		<cfset request.utilities.map.addOverlaysToMap(overlayName, arguments.googleMapName, centerPoint)>
	--->
	
	<cffunction name="addOverlaysToMap" access="public">
		<cfargument name="overlays" 		required="yes" type="any">
		<cfargument name="googleMapName" 	required="yes" type="string">
		<cfargument name="centerPoint" 		required="no" default="#structNew()#" type="struct"> <!--- Must be a GEODATA struct --->
		
		<cfif isSimpleValue(arguments.overlays)>
			<cfset tempArray = arraynew(1)>
			<cfset tempArray[1] = arguments.overlays>
			<cfset arguments.overlays = tempArray>
		</cfif>
		
		<!--- Create the Default Coordinates for the Center Point in case they aren't provided --->
		<cfparam name="arguments.centerPoint.latitude" 		default="">
		<cfparam name="arguments.centerPoint.longitude" 	default="">
		<cfparam name="arguments.centerPoint.mapAddress" 	default="">
		<cfparam name="arguments.centerPoint.accuracy"		default="unknown">
		
		<cfif arguments.centerPoint.accuracy IS "unknown">
			<cfif isNumeric(arguments.centerPoint.latitude) AND isNumeric(arguments.centerPoint.longitude)>
				<cfset arguments.centerPoint.accuracy = "coordinate">
			<cfelseif arguments.centerPoint.mapAddress IS NOT "">
				<cfset arguments.centerPoint.accuracy = "street">
			<cfelse>
				<cfset arguments.centerPoint.accuracy = "None">
			</cfif>
		</cfif>
		
		
		<!--- Loop over the overlays provided and get their web paths --->
		<cfset var overlayWebPaths = arraynew(1)>
		<cfloop array="#arguments.overlays#" index="currOverlayName">
			<cfset currWebPath = getOverlayWebPathByName(currOverlayName)>
			<cfif currWebPath IS NOT "">
				<cfset arrayAppend(overlayWebPaths, currWebPath)>
			</cfif>
		</cfloop>
		
		
		
		
		<!--- Create the JS to load these KML documents --->
		<cfif arrayLen(overlayWebPaths) GT 0>
			<cfsavecontent variable="output">
				<cfoutput>
				<!-- =================================================================================== -->
				<!-- =================================================================================== -->
				<!-- BEGIN CFHTMLHEAD: addMapOverlaysForPage() - Included from \NexusWeb2\Display\DisplayComponentParts\Rendering_Methods.cfm-->
		
				<script language="javascript">
					function addKMLOverlays_#arguments.googleMapName#() {
						//console.log('adding a KML overlay');
						var map = ColdFusion.Map.getMapObject('#arguments.googleMapName#');

						// Center MUST be set here, otherwise we get errors when trying to add KML Overlays
						<cfif arguments.centerPoint.accuracy IS "none">
							ColdFusion.Map.setCenter('#arguments.googleMapName#', {latitude: 28.291889, longitude: -81.407793});
							//map.setCenter(new google.maps.LatLng(28.291889, -81.407793), 9);
						<cfelseif arguments.centerPoint.accuracy IS "coordinate">
							ColdFusion.Map.setCenter('#arguments.googleMapName#', {latitude: #arguments.centerPoint.latitude#, longitude: #arguments.centerPoint.longitude#});
							//map.setCenter(new google.maps.LatLng(#arguments.centerPoint.mapAddress#));
						<cfelse>
							ColdFusion.Map.setCenter('#arguments.googleMapName#', {address: '#arguments.centerPoint.mapAddress#'});
							//map.setCenter(new google.maps.LatLng(28.291889, -81.407793), 9);
						</cfif>

						var KMLPath = '';
						<cfloop array="#overlayWebPaths#" index="currOverlayPath">
							KMLPath = new GGeoXml('#currOverlayPath#'); 
							map.addOverlay(KMLPath);
						</cfloop>
					}


				</script>
				<!-- END CFHTMLHEAD: addMapOverlaysForPage() -->
				<!-- =================================================================================== -->
				<!-- =================================================================================== -->
				</cfoutput>
								
			</cfsavecontent>
			<cfhtmlhead text="#output#" />
			<cfset ajaxOnLoad("addKMLOverlays_#arguments.googleMapName#")>
		</cfif>
	</cffunction>

	<!--- ========================================================== --->
	<!--- Get Geo Data: Retrieves geo location data from a page and prepares it for mapping --->
	<cffunction name="getGeoDataFromPage" access="public" returntype="struct" hint="">
		<cfargument name="pageData" required="yes" type="any">

		<cfset var returnData = structnew()>
		<cfset returnData['isMappable'] 			= false>
		<cfset returnData['mapAddress']				= "">
		<cfset returnData['directionsAddress']		= "">
		<cfset returnData['address']				= "">
		<cfset returnData['HTMLdisplay']			= "">
		<cfset returnData['displayTitle']			= arguments.pageData.get('addressTitle')>
		<cfset returnData['displayAddress']			= "">
		<cfset returnData['displayAddressLine1']	= "">
		<cfset returnData['displayAddressLine2']	= "">
		<cfset returnData['accuracy']				= "none">
		<cfset returnData['latitude']				= 0>
		<cfset returnData['longitude']				= 0>
		
		
						  
		<!--- Get the best address string we can and determine accuracy --->
		<!--- The order of these conditionals is based on accuracy.  Some prepending and appending swapping is going on, but that's cool, yo! --->
		<cfif pageData.get('addressState') IS NOT "">
			<cfset returnData.mapAddress 			= listPrepend(returnData.mapAddress, pageData.get('addressState'))>
			<cfset returnData.displayAddressLine2 	= listPrepend(returnData.displayAddressLine2, pageData.get('addressState'))>
			<cfset returnData.isMappable			= true>
			<cfset returnData.accuracy				= "state">
		</cfif>
		<cfif pageData.get('addressCity') IS NOT "">
			<cfset returnData.mapAddress 			= listPrepend(returnData.mapAddress, pageData.get('addressCity'))>
			<cfset returnData.displayAddressLine2 	= listPrepend(returnData.displayAddressLine2, pageData.get('addressCity'))>
			<cfset returnData.isMappable			= true>
			<cfset returnData.accuracy				= "city">
		</cfif>
		<cfif pageData.get('addressZipCode') IS NOT "">
			<cfset returnData.mapAddress 			= listAppend(returnData.mapAddress, pageData.get('addressZipCode'))>
			<cfset returnData.displayAddressLine2 	= listAppend(returnData.displayAddressLine2, pageData.get('addressZipCode'))>
			<cfset returnData.isMappable			= true>
			<cfset returnData.accuracy				= "zipcode">
		</cfif>
		
		<cfif pageData.get('addressStreet1') IS NOT "">
			<cfset returnData.displayAddressLine1 	= listAppend(returnData.displayAddressLine1, pageData.get('addressStreet1'))>
			<cfset returnData.isMappable			= true>
			<cfset returnData.accuracy				= "street">
			<cfif pageData.get('addressStreet2') IS NOT "">
				<cfset returnData.address 			= listPrepend(returnData.address, pageData.get('addressStreet2'))>
				<cfset returnData.displayAddressLine1 = listAppend(returnData.displayAddressLine1, pageData.get('addressStreet2'))>
			</cfif>

			<cfset returnData.mapAddress 	= listPrepend(returnData.mapAddress, pageData.get('addressStreet1'))>
		</cfif>
		
		
		<!--- Lat/Lon - Most specific and easiest to map --->
		<cfif isNumeric(pageData.get('geoLatitude')) AND isNumeric(pageData.get('geoLatitude'))
			AND (pageData.get('geoLatitude') IS NOT 0 AND pageData.get('geoLongitude') IS NOT 0)>
			
			<cfset returnData.isMappable 	= true>
			<cfset returnData.latitude		= pageData.get('geoLatitude')>
			<cfset returnData.longitude		= pageData.get('geoLongitude')>

			<cfif returnData.latitude LE -90>
				<cfset returnData.latitude += 360>
			</cfif>
			<cfif returnData.longitude LE -90>
				<cfset returnData.longitude += 360>
			</cfif>

			<cfset returnData.mapAddress 	= "#pageData.get('geoLatitude')#,#pageData.get('geoLongitude')#">
			<cfset returnData.accuracy		= "coordinate">
		</cfif>
		
		<cfif pageData.get('geoIsMappable') IS false>
			<!--- If the data says that this is not mappable, believe it and override anything else --->
			<cfset returnData.isMappable = false>
		</cfif>
		
		<!--- Remove the comma after state in the Display Address --->
		<cfif findNoCase("#pageData.get('addressState')#,", returnData.displayAddressLine2)>
			<cfset returnData.displayAddressLine2 = replaceNOCASE(returnData.displayAddressLine2, "#pageData.get('addressState')#,", "#pageData.get('addressState')# ")>
		</cfif>
		
		<!--- Compose the Address --->
		<cfset returnData.address 				= returnData.displayAddressLine1>
		<cfif returnData.displayAddressLine2 IS NOT "">
			<cfset returnData.address			&= ",#returnData.displayAddressLine2#">
		</cfif>
		
		<cfset returnData.displayAddressLine1 	= replace(returnData.displayAddressLine1, ",", ", ", "all")>
		<cfset returnData.displayAddressLine2 	= replace(returnData.displayAddressLine2, ",", ", ", "all")>

		<cfset returnData.displayAddress		= returnData.displayAddressLine1>
		<cfif returnData.displayAddressLine2 IS NOT "">
			<cfset returnData.displayAddress	&= ", #returnData.displayAddressLine2#">
		</cfif>
		
		<cfif returnData.displayTitle IS NOT "">
			<cfset returnData.HTMLDisplay = listAppend(returnData.HTMLDisplay, returnData.displayTitle, chr(10))>
		</cfif>
		<cfif returnData.displayAddressLine1 IS NOT "">
			<cfset returnData.HTMLDisplay = listAppend(returnData.HTMLDisplay, returnData.displayAddressLine1, chr(10))>
		</cfif>
		<cfif returnData.displayAddressLine2 IS NOT "">
			<cfset returnData.HTMLDisplay = listAppend(returnData.HTMLDisplay, returnData.displayAddressLine2, chr(10))>
		</cfif>
		<cfset returnData.HTMLDisplay = replace(returnData.HTMLDisplay, chr(10), "<br />", "all")>
		
		<!--- Directions Address --->
		<cfif pageData.get('addressStreet1') IS NOT "">
			<cfset returnData.directionsAddress = returnData.address>
		<cfelseif returnData.accuracy IS "coordinate">
			<cfset returnData.directionsAddress = "#returnData.latitude#,#returnData.longitude#">
		<cfelse>
			<cfset returnData.directionsAddress = returnData.address>
		</cfif>
		
		<cfreturn returnData>	
	</cffunction>

	<!--- ========================================================== --->
	<!--- Get Square  --->
	<cffunction name="getSquareAroundPoint" access="public" returntype="struct" hint="Gets a square a distance from a point.  Used for doing a very simple distance formula">
		<cfargument name="latitude" required="yes" type="numeric">
		<cfargument name="longitude" required="yes" type="numeric">
		<cfargument name="radius" required="yes" type="numeric">
		
		<cfset var square = {}>
		<cfset var latConst = 69.1>
		<cfset var lonConst = 53>
		<cfset square['latMin'] = (latitude - (radius/latConst))>
		<cfset square['latMax'] = (latitude + (radius/latConst))>
		<cfset square['lonMin'] = (longitude - (radius/lonConst))>
		<cfset square['lonMax'] = (longitude + (radius/lonConst))>
		
		<cfset square['nw'] 	= {latitude		= square.latMax, 	longitude = square.lonMin}>
		<cfset square['ne'] 	= {latitude		= square.latMax, 	longitude = square.lonMax}>
		<cfset square['sw'] 	= {latitude		= square.latMin, 	longitude = square.lonMin}>
		<cfset square['se'] 	= {latitude		= square.latMin, 	longitude = square.lonMax}>
		<cfset square['mid']	= {latitude		= arguments.latitude, longitude = arguments.longitude}>
		<cfset square['radius']	= arguments.radius>
		
		<cfreturn square>
	</cffunction>


	<!--- ========================================================== --->
	<!--- Get Marker Icon --->
	<cffunction name="getMarkerIcon" access="public" returntype="string" hint="">
		<cfargument name="text" 			default=""			required="no" type="string">
		<cfargument name="backgroundColor"  default="124E73"	required="no" type="string">
		<cfargument name="textColor" 		default="FFFFFF"	required="no" type="string">
		
		
		<!--- 	Instructions for use of google charting components:
				http://groups.google.com/group/google-chart-api/web/chart-types-for-map-pins
		--->

		<!---
		<cfset var iconURL = "http://chart.apis.google.com/chart?chst=d_map_spin">
		<cfset iconURL &= "&chld=0.6|0|#backgroundColor#|10|b|#text#">
		--->
		
		<cfset var iconURL = "http://chart.apis.google.com/chart?chst=d_map_pin_letter">
		<cfset iconURL &= "&chld=#text#|#backgroundColor#|#textColor#">

		<cfreturn iconURL>
	</cffunction>
		

</cfcomponent>