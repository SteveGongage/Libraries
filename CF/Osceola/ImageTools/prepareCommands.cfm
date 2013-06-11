<cfparam name="url.cropTo" 			default="">
<cfparam name="url.cropToLeft" 		default="0" type="integer">
<cfparam name="url.cropToTop"		default="0" type="integer">
<cfparam name="url.cropToRight"		default="0" type="integer">
<cfparam name="url.cropToBottom"	default="0" type="integer">

<cfparam name="url.fitTo"			default="">
<cfparam name="url.fitToMax"		default="0" type="integer">
<cfparam name="url.fitToHeight"		default="0" type="integer">
<cfparam name="url.fitToWidth"		default="0" type="integer">


<cfparam name="defaults.isSet"		default="false">

<cfset prepare 				= structnew()>
<cfset prepare.cropTo		= []>
<cfset prepare.fitTo		= []>

<!--- Crop To --->
<cfif defaults.isSet>
	<cfset prepare.cropTo = [0, 0, defaults.height, defaults.width]>
</cfif>

<cfif listlen(url.cropTo) IS 4>
	<!--- Crop To: URL List of Crop Dimensions --->
	<cfset cropToSource		= listToArray(url.cropTo)>
<cfelseif url.cropTo IS "preset" AND defaults.isSet>
	<!--- Crop To: Media DB Table List of Crop Dimensions --->
	<cfset cropToSource		= [defaults.cropTop, defaults.cropLeft, defaults.cropBottom, defaults.cropRight]>
<cfelseif isNumeric(url.CropToTop) AND  isNumeric(url.CropToLeft) AND isNumeric(url.CropToBottom) AND isNumeric(url.CropToRight)>
	<!--- Crop To: URL Arguments of Crop Dimensions --->
	<cfset cropToSource		= [url.CropToTop, url.CropToLeft, url.CropToBottom, url.CropToRight]>
</cfif>
<cfloop array="#cropToSource#" index="item">
	<cfif NOT isNumeric(item)>
		<cfset item = 0>
	</cfif>
</cfloop>
<cfset prepare.cropTo = cropToSource>



<!--- Fit To --->
<cfset prepare.fitTo				= []>
<cfif url.fitToMax GT 0>
	<cfset url.fitTo 				= "#url.fitToMax#,#url.fitToMax#">
</cfif>
<cfif listLen(url.fitTo) IS 2>
	<cfset prepare.fitTo			= listToArray(url.fitTo)>
<cfelseif url.fitTo IS NOT "">
	<cfset dimensions 				= request.utilities.image.getDimensionsFromString(url.fitTo)>
	<cfset prepare.fitTo 			= [dimensions.width, dimensions.height]>
<cfelse>
	<cfset prepare.fitTo			= [url.fitToWidth, url.fitToHeight]>
</cfif>
