<cfparam name="url.idMedia"			default="0">
<cfif NOT isNumeric(url.idMedia)>
	<cfset url.idMedia = 0>
</cfif>



<cfset pathArgs = cgi.PATH_INFO>
<cfif listLen(pathArgs, "/") GE 2>
	<cfloop from="1" to="#listLen(pathArgs, "/")#" step="2" index="i">
		<cfif i IS NOT listLen(pathArgs, "/")>
			<cfset varName 	= listGetAt(pathArgs, i, "/")>
			<cfset varValue = listGetAt(pathArgs, i + 1, "/")>
			
			<cfset url[varName] = varValue>
			
		</cfif>
	</cfloop>
</cfif>





<cftimer label="MediaImage: Full Run" type="outline">
<!--- Lookup File by Media Type --->
	<cfset main 			= structnew()>
	<cfset main.idMedia 	= url.idMedia>
	<cfset main.fileName 	= "">
	<cfset main.fsPath		= "">
	<cfset main.webPath		= "">
	<cfset main.fsPathFull	= "">
	<cfset main.imageFound	= false>
	
	
	<cfif main.idMedia GT 0>
		<cftimer label="LookupMedia"  type="outline">
			<cfquery name="getMedia">
				SELECT * FROM Media WHERE idMedia = <cfqueryparam value="#main.idMedia#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cftimer>
		<cfif getMedia.recordcount GT 0>
			<cfset main.fileName	= getMedia.fileName>

			<cfset main.fsPath		= replace(getMedia.fileFolder, "/", "\", "all")>

			<cfif left(main.fsPath, 6) IS "\files">
				<!--- Removes \Files from the beginning of the path.  Using FileStoragePath was causing other errors.  Not all paths were up to date and some had "\files" at the beginning and some didn't --->
				<cfset main.fsPath = right(main.fsPath, len(main.fsPath) - 6)>
			</cfif>

			<cfset main.fsPath		= "#request.global.fileStorage.rootPath##main.fsPath#">
			<cfset main.fsPath		= replace(main.fsPath, "/", "\", "all")>
			<cfset main.webPath		= getMedia.fileFolder>
			<cfset main.imageFound	= true>
			
			<cfset defaults = structnew()>
			<cfset defaults.cropTop		= getMedia.thumb_cropTop>
			<cfset defaults.cropLeft	= getMedia.thumb_cropLeft>
			<cfset defaults.cropBottom	= getMedia.thumb_cropBottom>
			<cfset defaults.cropRight	= getMedia.thumb_cropRight>
			<cfset defaults.height		= getMedia.height>
			<cfset defaults.width		= getMedia.width>
			<cfset defaults.isSet		= true>
		</cfif>
	</cfif>
	
	<cfif main.imageFound>
		<cfset main.fsPathFull	= "#main.fsPath#\#main.fileName#">
		<cfset main.imageFound 	= fileExists(expandPath(main.fsPathFull))>
	
	</cfif>
	

	<cfif main.imageFound>
		<cfinclude template="prepareCommands.cfm">

		
		<cf_thumbMaker
			file			= "#main.fsPathFull#"
			webPath			= "#main.webPath#"
			thumbNamePrefix	= "m#numberformat(main.idMedia, '00000000')#"
			cropTo			= "#prepare.cropTo#"
			fitTo			= "#prepare.fitTo#">
	<cfelse>
		<cfoutput>
			<cfif main.fsPathFull IS NOT "">
				Cannot find file: #main.fsPathFull#
			<cfelse>
				Cannot find file for ID: #url.idMedia#
			</cfif>
		</cfoutput>
	</cfif>
</cftimer>