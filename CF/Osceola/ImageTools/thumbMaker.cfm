<cfparam name="attributes.cropTo" 			default="[]" 		type="array">
<cfparam name="attributes.fitTo" 			default="[]"	 	type="array">
<cfparam name="attributes.thumbNamePrefix"	default="" 			type="string">
<cfparam name="attributes.file"				default=""			type="string">
<cfparam name="attributes.webPath"			default=""			type="string">
<cfparam name="attributes.thumbFolder"		default="_thumbs" 	type="string">
<cfparam name="attributes.ignoreCache"		default="true"		type="boolean">

<cfparam name="url.debug"					default="false">


<cfset files 			= structnew()>
<cfset files.original	= structnew()>
<cfset files.thumb		= structnew()>

<cfset orders			= structnew()>
<cfset orders.cropTo 	= structnew()>
<cfset orders.scaleTo	= structnew()>





<cftimer label="ThumbMaker: Full Run" type="outline">

<!--- =========================================================================== --->
<!--- Setup Files --->
	<cftimer label="ThumbMaker: Setup File Info" type="outline">
		<!--- Original File --->
		<cfset files.original.fsPathFull	= replace(attributes.file, "/", "\", "all")>
		<cfset files.original.fileName		= listLast(files.original.fsPathFull, "\")>
		<cfset files.original.fsPath		= listDeleteAt(files.original.fsPathFull, listLen(files.original.fsPathFull, "\"), "\")>
		
		<cfif NOT fileExists(expandPath(files.original.fsPathFull))>
			<cfthrow 
				message	="Thumbmaker: Cannot file file #files.original.fileName#" 
				detail	="file not found at specified path: #expandPath(files.original.fsPathFull)#">
		</cfif>
		<cfset files.original.fileName_pre	= listFirst(files.original.fileName, '.')>
		<cfset files.original.fileName_ext	= listLast(files.original.fileName, '.')>
		<cfset files.original.image			= "">

	
		<!--- Thumbnail File --->
		<cfset files.thumb.error		= false>
		<cfset files.thumb.fsPath		= "#files.original.fsPath#\#attributes.thumbFolder#">
		<cfset files.thumb.WebPath		= "#attributes.webPath#/#attributes.thumbFolder#">
		
		<cfset files.thumb.fileName_pre	= files.original.fileName_pre>
		<cfif attributes.thumbNamePrefix IS NOT "">
			<cfset files.thumb.fileName_pre	= attributes.thumbNamePrefix>
		</cfif>
		<cfset files.thumb.FileName		= "#files.thumb.fileName_pre#~~thumb~~.#files.original.fileName_ext#">
		
		<!--- File Suffix --->
		<cfset file.thumb.fileName_suffix = "">
		<cfif arraylen(attributes.cropTo) IS 4>
			<cfset newSuffix = "_ct#arrayToList(attributes.cropTo, '-')#">
			<cfif newSuffix IS NOT "_ct0-0-0-0">
				<cfset file.thumb.fileName_suffix &= newSuffix>
			</cfif>
		</cfif>
		<cfif arraylen(attributes.fitTo) IS 2>
			<cfset newSuffix = "_ft#arrayToList(attributes.fitTo, '-')#">
			<cfif newSuffix IS NOT "_ft0-0">
				<cfset file.thumb.fileName_suffix &= newSuffix>
			</cfif>
		</cfif>

		<!--- Update Filename with Suffix String --->
		<cfset files.thumb.fileName		= replaceNOCASE(files.thumb.fileName, '~~thumb~~', file.thumb.fileName_suffix)>
		<cfset files.thumb.writeTo		= "#files.thumb.fsPath#\#files.thumb.fileName#">
		<cfset files.thumb.exists		= fileExists(expandPath(files.thumb.writeTo))>
		<cfset files.thumb.image		= "">
	</cftimer>


<!--- Check Cache for Existing File, otherwise execute the orders --->
<cfif NOT files.thumb.exists OR url.debug IS "true">
	
	<!--- =========================================================================== --->
	<!--- Read Original Image Into Memory --->
		<cftimer label="ThumbMaker: Read Image Files" type="outline">
			<cftry>
				<cfset files.original.image 	= imageRead(expandPath(files.original.fsPathFull))>
				<cfset files.thumb.image		= imageRead(expandPath(files.original.fsPathFull))>
				<cfcatch type="any">
					<cfset files.thumb.error = true>

					<cfif cfcatch.message CONTAINS "CMM">
						<cf_LogEvent tags	= "error"
							category		= "Thumbnail Maker"
							summary			= "General CMM Error"
							message			= "Error reading the image file #expandPath(files.original.fsPathFull)#.  <br> The error was: <strong>#cfcatch.message#</strong> - #cfcatch.detail#"
							data			= "">
					<cfelse>
						<cfthrow 
							message="Thumbnail Maker: Error Reading Image" 
							detail="Error reading the image file #expandPath(files.original.fsPathFull)#.  <br> The error was: <strong>#cfcatch.message#</strong> - #cfcatch.detail#">
					</cfif>
				</cfcatch>
			</cftry>
		</cftimer>
	
	<cfif NOT files.thumb.error>
		<!--- =========================================================================== --->
		<!--- Setup Orders --->
			<cfset orders.fileSuffix			= "">
		
			<cfset orders.cropTo.valid 			= false>
			<cfif arrayLen(attributes.cropTo) IS 4>
				<cfset orders.cropTo.valid 		= true>
				<cfset orders.cropTo.top		= attributes.cropTo[1]>
				<cfset orders.cropTo.left		= attributes.cropTo[2]>
				<cfset orders.cropTo.bottom		= attributes.cropTo[3]>
				<cfset orders.cropTo.right		= attributes.cropTo[4]>
			</cfif>
			
			<cfset orders.fitTo.valid = false>
			<cfif arrayLen(attributes.fitTo) IS 2>
				<cfset orders.fitTo.Width		= attributes.fitTo[1]>
				<cfset orders.fitTo.Height		= attributes.fitTo[2]>
				<cfset orders.fitTo.valid 		= orders.fitTo.Width GT 0 OR orders.fitTo.Height GT 0>
			</cfif>
			
			<cfset orders.orientation		= ''>
			
		
		<!--- =========================================================================== --->
		<!--- Crop the Image --->
		
			<cfif orders.cropTo.valid>	
				<!--- Crop Dimension Validation --->
				<cfif orders.cropTo.bottom LE orders.cropTo.top 		OR orders.cropTo.bottom GT files.original.image.height>
					<cfset orders.cropTo.bottom = files.original.image.height>
				</cfif>
				<cfif orders.cropTo.right LE orders.cropTo.left 		OR orders.cropTo.right GT files.original.image.width>
					<cfset orders.cropTo.right = files.original.image.width>
				</cfif>
				<cfif orders.cropTo.top GE files.original.image.height 	OR orders.cropTo.top LT 0>
					<cfset orders.cropTo.top = 0>
				</cfif>
				<cfif orders.cropTo.left GE files.original.image.width 	OR orders.cropTo.left LT 0>
					<cfset orders.cropTo.left = 0>
				</cfif>
			
			
			
				<!--- Calculations --->
				<cfset orders.cropTo.height		= orders.cropTo.bottom 	- orders.cropTo.top>
				<cfset orders.cropTo.width		= orders.cropTo.right 	- orders.cropTo.left>
				
				<cfif orders.cropTo.height GT orders.cropTo.width>
					<cfset orders.orientation = "portrait">
				<cfelse>
					<cfset orders.orientation = "landscape">
				</cfif>
				
				<cfset orders.fileSuffix &= "_ct#orders.cropTo.Top#-#orders.cropTo.Left#-#orders.cropTo.Bottom#-#orders.cropTo.Right#">
	
				<!--- Crop the image --->
				<cfset imagecrop(files.thumb.image, orders.cropTo.left, orders.cropTo.top, orders.cropTo.width, orders.cropTo.height)>
			</cfif>
			
			
		<!--- =========================================================================== --->
		<!--- "Fit To" Scale the image --->
			<cfif orders.fitTo.valid>
				
				<!--- If the "Fit To" ratio is off, forget the largest measurement to recalculate --->
				<cfset orders.fitTo.RatioFixed 	= files.thumb.image.width / files.thumb.image.height>
				<cfif orders.fitTo.height IS 0>
					<cfset orders.fitTo.Ratio	= 0>
				<cfelse>
					<cfset orders.fitTo.Ratio 		= orders.fitTo.Width / orders.fitTo.Height>
				</cfif>
				
				<cfif orders.fitTo.Ratio 		GT orders.fitTo.ratioFixed>
					<cfset orders.fitTo.Width 	= 0>
				<cfelseif orders.fitTo.Ratio 	LT orders.fitTo.ratioFixed>
					<cfset orders.fitTo.Height 	= 0>
				</cfif>
				
				<!--- If one side is not defined, calculate it from the constrained ratio --->
				<cfif orders.fitTo.Width	GT 0 	AND orders.fitTo.Height IS 0>
					<cfset orders.fitTo.Height 		= round(orders.fitTo.Width * (1 / orders.fitTo.ratioFixed)) >
				<cfelseif orders.fitTo.Height GT 0 	AND orders.fitTo.Width IS 0>
					<cfset orders.fitTo.Width  		= round(orders.fitTo.Height * orders.fitTo.ratioFixed)>
				</cfif>
				
				<cfset orders.fitTo.Ratio = orders.fitTo.Width / orders.fitTo.Height>
				
				<cfset orders.fileSuffix &= "_ft#orders.fitTo.Width#-#orders.fitTo.Height#">
	
				<!--- Resize the image --->
				<cfset imageresize(files.thumb.image, orders.fitTo.Width, orders.fitTo.Height)>
			</cfif>
		
		
		
		<!--- =========================================================================== --->
		<!--- Execute Orders and Write the File --->
			<cftimer label="ThumbMaker: Execute Orders" type="outline">
				<!--- Write the File --->
				<cfif NOT directoryExists(expandPath(files.thumb.fsPath))>
					<cfset directoryCreate(expandPath(files.thumb.fsPath))>
				</cfif>
				<cfset imagewrite(files.thumb.image, expandPath(files.thumb.writeTo))>
			</cftimer>
	</cfif>
</cfif>	
	
		
		
<!--- =========================================================================== --->
<!--- Redirect browser to the new file --->
<cfif files.thumb.error>
	<cfoutput>
		File Error
		<br />
		#files.thumb.webPath#/#files.thumb.fileName#
	</cfoutput>
<cfelse>
	<cfif url.debug IS "true">
		<cftimer label="ThumbMaker: Debug Output" type="outline">
			<cfif isImage(files.thumb.image)>
				<cfimage action="writetobrowser" source="#files.thumb.image#">
			<cfelse>
				<cfoutput>
					<br />
					Cached image file used
				</cfoutput>
			</cfif>
			
			<cfoutput>
				<br />
				<a href="#files.thumb.webPath#/#files.thumb.fileName#">#files.thumb.webPath#/#files.thumb.fileName#</a>
			</cfoutput>
			
			<cfdump var="#orders#">
			
		</cftimer>
	<cfelse>
		
		<!--- NOTE:		Not using cflocation since this causes a little lag between the request for the 
						image and the display of the image in personal use 
			IMPORTANT:  Using CFContent MIGHT present a memory or process issue.  Might need to go back 
						to using CFLocation.  It worked well in development, but might need to tune for 
						production use.
			Notes:
				http://www.bennadel.com/blog/1228-Eric-Stevens-On-CFContent-And-Memory-Usage-In-ColdFusion-8.htm
				http://www.bennadel.com/blog/1226-Creating-Semi-Secure-File-Downloads-Without-Using-CFContent.htm


			<cflocation url="#files.thumb.webPath#/#files.thumb.fileName#" addtoken="no" statuscode="301">
		--->
		
		<cfheader name="Content-Disposition" value="filename=#files.thumb.fileName#">
		<cfheader name="Pragma" value="">
		<cfheader name="Cache-control" value="">
		<cfcontent file="#expandPath(files.thumb.writeTo)#">
		
	</cfif>
</cfif>
</cftimer>
