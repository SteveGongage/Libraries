

<cfparam name="url.file" 		default="">
<cfparam name="url.w"			default="0">
<cfparam name="url.h"			default="0">
<cfparam name="url.type"		default="croppedLandscape">
<cfparam name="url.size"		default="">
<cfparam name="url.refresh"		default="false" type="boolean">
<cfparam name="url.debug" 		default="false" type="boolean">
<cfparam name="url.help"		default="false" type="boolean">
<cfparam name="url.fitTo"		default="">



<cfif NOT (fileExists(expandPath(url.file)) AND isImageFile(expandPath(url.file)))>
	<!--- IF the file does not exist or it is not an image file --->
	<cfoutput>
		Original file not found or not a valid image<br />
	</cfoutput>
<cfelse>
	<cfif url.size IS NOT "" AND url.fitTo IS "">
		<cfset url.fitTo = url.size>
	</cfif>
	
	<cfinclude template="prepareCommands.cfm">

	<cfset main.fsPathFull	= url.file>
	<cfset main.webPath		= listDeleteAt(url.file, listLen(url.file, "/"), "/")>
	<cfset main.file		= listLast(url.file, "/")>

	<cf_thumbMaker
		file			= "#main.fsPathFull#"
		webPath			= "#main.webPath#"
		cropTo			= "#prepare.cropTo#"
		fitTo			= "#prepare.fitTo#">
</cfif>

