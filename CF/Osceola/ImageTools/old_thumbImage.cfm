<!---
************************************************************************************************************************
************************************************************************************************************************
	Thumbnail Image Proxy
	
	Created By: Steven Gongage (2/17/2010) - sgon@osceola.org
	
	Documentation and Examples: thumb.cfm?help=true

************************************************************************************************************************
************************************************************************************************************************
--->


<cfparam name="url.file" 		default="">
<cfparam name="url.w"			default="0">
<cfparam name="url.h"			default="0">
<cfparam name="url.type"		default="croppedLandscape">
<cfparam name="url.size"		default="">
<cfparam name="url.refresh"		default="false" type="boolean">
<cfparam name="url.debug" 		default="false" type="boolean">
<cfparam name="url.help"		default="false" type="boolean">


<cfset settings = structnew()>
<cfset settings.file 			= url.file>
<cfset settings.widthMax		= url.w>
<cfset settings.heightMax		= url.h>
<cfset settings.size 			= url.size>
<cfset settings.imageOriginal	= imageNew()>
<cfset settings.linkToThumb		= "">
<cfset settings.type			= url.type>
<cfset settings.debugMode 			= url.debug>
<cfset settings.forceRefresh		= url.refresh OR settings.debugMode>
<cfset settings.documentationMode  	= url.help>
<cfset settings.redirectToImage 	= NOT (settings.debugMode OR settings.forceRefresh OR settings.documentationMode)>

<cfif NOT settings.documentationMode>

	<cfif NOT (fileExists(expandPath(url.file)) AND isImageFile(expandPath(url.file)))>
		<!--- IF the file does not exist or it is not an image file --->
		<cfoutput>
			Original file not found or not a valid image<br />
			
		
		</cfoutput>
		
		
	<cfelse>
		<!--- =================================================================================== --->
		<!--- STANDARDIZE THE INPUTS ============================================================ --->
			<cfif listFindNoCase("croppedLandscape,cl,4:3", settings.type)>
				<cfset settings.type = "croppedLandscape">
			<cfelseif listFindNoCase("croppedPortrait,cp,3:4", settings.type)>
				<cfset settings.type = "croppedPortrait">
			<cfelseif listFindNoCase("scaled,s", settings.type)>
				<cfset settings.type = "scaled">
			<cfelseif listFindNoCase("cropped,c", settings.type)>
				<cfset settings.type = "cropped">
			<cfelse>
				<cfset settings.type = "croppedLandscape">
			</cfif>
		
		
		
		<!--- =================================================================================== --->
		<!--- DETERMINE SETTINGS BASED ON INPUT ================================================= --->
			<cfif settings.widthMax GT 0 AND settings.heightMax GT 0>
				<cfif settings.widthMax GT 800>		<cfset settings.widthMax = 800>		</cfif>
				<cfif settings.heightMax GT 800>	<cfset settings.heightMax = 800>	</cfif>
				<cfset settings.size = "#settings.widthMax#:#settings.heightMax#">
			<cfelseif NOT listFindNoCase('small,large', settings.size)>
				<cfset settings.size = "large">
			</cfif>
			
			
	
		<!--- =================================================================================== --->
		<!--- LOAD THE IMAGE FILE =============================================================== --->
		
		
			<cfset settings.imageOriginal = imageNew(expandPath(url.file))>
			

			<cfset settings.linkToThumb = request.utilities.image.getLinkToThumbnail(url.file, settings.type, settings.size, settings.forceRefresh)>
	
			
			
			<cfif settings.redirectToImage>
				<!--- NOTE:		Not using cflocation since this causes a little lag between the request for the 
								image and the display of the image in personal use 
					IMPORTANT:  Using CFContent MIGHT present a memory or process issue.  Might need to go back 
								to using CFLocation.  It worked well in development, but might need to tune for 
								production use.
					Notes:
						http://www.bennadel.com/blog/1228-Eric-Stevens-On-CFContent-And-Memory-Usage-In-ColdFusion-8.htm
						http://www.bennadel.com/blog/1226-Creating-Semi-Secure-File-Downloads-Without-Using-CFContent.htm


					<cflocation url="#settings.linkToThumb#" addtoken="no" >
				--->

				<cfcontent file="#expandPath(settings.linkToThumb)#">


				
	
			<cfelseif settings.debugMode>
				<cfoutput>
					<h1>Debug Mode Enabled</h1>
					
					<p>
						The image generated was:<br />
						
						<div style="background-color: ##EEC; padding: 20px;">
							<img src="#settings.linkToThumb#" style="border: 1px solid ##CCC;">
						</div>
						<br />
						<a href="#settings.linkToThumb#">#settings.linkToThumb#</a>
						<br />
						<a href="#url.file#">Original Image</a>
					</p>
					
					<h3>Thumb File Info</h3>
					<cfdump var="#request._thumbInfo#" label="Thumb Info">
					
					<h3>Proxy File Settings</h3>
					<cfset settings.imageThumb = imageNew(expandPath(settings.linkToThumb))>
					<cfdump var="#settings#">
					
				</cfoutput>
				
			<cfelseif settings.forceRefresh>
				<cfoutput>
					<h1>Image Refreshed</h1>
					<p>
						Image was forced to refresh.  Not automatically redirecting to this thumbnail to 
						prevent accidental use in a live public production environment since thumbnail 
						generation is a very processor intensive action and if you do it a lot, you'll go blind.
					</p>
					
					<p>The new thumbnail can be found here: <a href="#settings.linkToThumb#">#settings.linkToThumb#</a></p>
					
				</cfoutput>
			<cfelse>
				<cfoutput>
					<h1>Huh?!</h1>
					
					<p>Not sure why you got to this... some setting told us not to automatically redirect you to the thumbnail</p>
				</cfoutput>
			</cfif>
	</cfif>



<cfelse>

	<!--- =================================================================================== --->
	<!--- GIVE INSTRUCTIONS ================================================================= --->
	
	
	<cfoutput>
		<style>
			dd {margin-bottom: 2em; }
			dt { font-weight: bold }
			h1 { font-size: 1.4em; }
			h2 { font-size: 1.2em; }
			body { font-size: 14px; font-family: Helvetica, Arial, sans-serif; }
			table { font: inherit }
		</style>
		<h1>Thumbnail Image Proxy Interface</h1>
		
		<h2>Examples</h2>
		<p>Examples are using this file for demonstration: <a href="/testing/imageSizeTests/source%20images/headshot%20medium%20size.jpg">/testing/imageSizeTests/source%20images/headshot%20medium%20size.jpg</a></p>
		<dl>
			<dt>Example 1: Large cropped landscape thumbnail</dt>
			<dd>
				<em>http://osceolacms/thumb.cfm?file=/testing/imageSizeTests/source%20images/headshot%20medium%20size.jpg</em>
				<br />
				Returns a SMALL thumbnail that has been reduced in size and cropped to fit 3:4 aspect ratio for the file.
			</dd>
			
			<dt>Example 2: small cropped landscape thumbnail</dt>
			<dd>
				<em>http://osceolacms/thumb.cfm?size=small&file=/testing/imageSizeTests/source%20images/headshot%20medium%20size.jpg</em>
				<br />
				Returns a SMALL thumbnail that has been reduced in size and cropped to fit 3:4 aspect ratio for the file.
			</dd>
			
			<dt>Example 3: scaled image with max dimensions of 200 height by 300 width</dt>
			<dd>
				<em>http://osceolacms/thumb.cfm?h=200&w=300&type=scaled&file=/testing/imageSizeTests/source%20images/headshot%20medium%20size.jpg</em>
				<br />
				Redirects to a thumbnail that has been scaled to fit into the dimensions 200 x 300 and maintains it's original aspect ratio.  It's actual height and width will likely NOT be 200 x 33.
			</dd>
			
		</dd>
		
		<h2>Arguments</h2>
		
		
		
		<table border="1" cellpadding="10">
			<thead>
				<tr>
					<th>Argument</th>
					<th>Options</th>
					<th>Description</th>
				</tr>
			</thead>
			
			<tbody>
				<tr>
					<th>FILE</th>
					<td><em>relative web path to image</em></td>
					<td>
						<p>REQUIRED</p>
						<p>
							This path MUST be relative to the ROOT of this CMS application, must point to a directory UNDER the root of the CMS application, and the directory must be able to have a "_thumbs" directory created for it.
						</p>
					</td>
				</tr>
				<tr>
					<th>SIZE</th>
					<td><strong>large</strong>, small</td>
					<td>
						<p>Optional - defaults to: large</p>
						<p>
							Sets the dimensions of the thumbnail image.  LARGE and SMALL allow for use of standard sizes.  H:W allows for use of numeric height and width for flexibility.
						</p>
						
						<p>
							<cfset dim = request.utilities.image.getDimensionsFromString('large')>
							<strong>LARGE</strong> dimensions: width = #dim.width#, height = #dim.height#
							<br />
							
							<cfset dim = request.utilities.image.getDimensionsFromString('small')>
							<strong>SMALL</strong> dimensions: width = #dim.width#, height = #dim.height#
							<br />
						</p>

					</td>
				</tr>
				<tr>
					<th>H</th>
					<td><em>positive integer</em></td>
					<td>
						<p>Optional - defaults to dimensions specified in SIZE attribute.</p>
						<p>Must be a positive integer under 800</p>
						<p>Used for cases when a specific height is needed.  Will override the SIZE argument.  Will only work if a corresponding W (width) is supplied.</p>
					</td>
				</tr>
				<tr>
					<th>W</th>
					<td><em>positive integer</em></td>
					<td>
						<p>Optional - defaults to dimensions specified in SIZE attribute.</p>
						<p>Must be a positive integer under 800</p>
						<p>Used for cases when a specific width is needed.  Will override the SIZE argument.  Will only work if a corresponding H (height) is supplied.</p>
					</td>
				</tr>
				
				<tr>
					<th>TYPE</th>
					<td>
						<strong>croppedLandscape</strong>, cl, 4:3,<br />
						croppedPortrait, cp, 3:4,<br />
						cropped, c,<br />
						scaled, s
					</td>
					<td>
						<p>Optional - defaults to CroppedLandscape</p>
						<p>Allows for a choice of thumbnail resizing and cropping needs</p>
						<p>
							<strong>croppedLandscape</strong> - Locks the aspect ratio of the thumbnail to 4 x 3 (landscape dimensions) and crops the thumbnail from the top-middle of the original image.
							<br />
							<strong>croppedPortrait</strong> - Locks the aspect ratio of the thumbnail to 3 x 4 (portrait dimensions) and crops the thumbnail from the top-middle of the original image.
							<br />
							<strong>cropped</strong> - Allows for custom dimensions to be supplied and crops the thumbnail from the middle.
							<br />
							<strong>scaled</strong> - Scales the image down so it always fits within it's max dimensions without any cropping.
						</p>
					</td>
				</tr>

				<tr>
					<th>REFRESH</th>
					<td><strong>FALSE</strong>, TRUE</td>
					<td>
						<p>Optional - defaults to FALSE</p>
						<p>Will force a refresh of the thumbnail.  To prevent misuse of this feature, any calls to this will not display an image.</p>
					</td>
				</tr>
				<tr>
					<th>HELP</th>
					<td><strong>FALSE</strong>, TRUE</td>
					<td>
						<p>Optional - defaults to FALSE</p>
						<p>Displays help documentation in HTML format.</p>
					</td>
				</tr>
				<tr>
					<th>DEBUG</th>
					<td><strong>FALSE</strong>, TRUE</td>
					<td>
						<p>Optional - defaults to FALSE</p>
						<p>Used for development.  Instead of redirecting the HTTP request to the correct image file, this will show a page with information about the process of creating this image.</p>
					</td>
				</tr>
			</tbody>
		
		</table>
	
	
	
	</cfoutput>
	
	
	
</cfif>	
