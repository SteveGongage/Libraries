<cfcomponent>
	<!--- ========================================================== --->
	<cffunction name="durationFormat">
		<cfargument name="seconds" default="0" required="yes" type="numeric">
		
		<cfreturn "#numberformat(int(arguments.seconds / 3600), '00')#:#numberformat(int(arguments.seconds / 60), '00')#:#numberformat(arguments.seconds MOD 60, '00')#">		
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="shortenNumber" output="no">
		<cfargument name="numberIn" required="yes" type="numeric">
		
		<cfset var numberOut = numberIn>
		
		<cfif numberOut GE 1000000>
			<cfset numberOut = '#numberformat(numberOut / 1000000, '999,999.0')#<span style="font-size: 11px;">mil</span>'>
			<!---
		<cfelseif numberOut GE 1000>
			<cfset numberOut = '#numberformat(numberOut / 1000, '999,999.0')#<span style="font-size: 10px;">thousand</span>'>
			--->
		<cfelse>
			<cfset numberOut = numberformat(numberOut, '999,999')>
		</cfif>

		
		<cfreturn numberOut>		
	</cffunction>
	
	
	<!--- ========================================================== --->
	<cffunction name="progressBar" output="yes">
		<cfargument name="total" 		required="yes">
		<cfargument name="max"			required="yes">
		<cfargument name="optionsIn"	required="no" default="#structnew()#" type="struct">
		
		<cfset var options = {
			range 			= [25, 75],
			rangeStyles		= ['Low', 'Medium', 'High'],
			showValue		= false,
			width			= 150
		}>
		
		<cfset structappend(options, arguments.optionsIn, true)>


		<cfset var percent 		= 0>
		
		<cfif arguments.max GT 0>
			<cfset percent = arguments.total / arguments.max * 100>
			<cfset percent = round(percent)>
		</cfif>
		
		<cfset var i = 0>
		<cfset var styleClass	= options.rangeStyles[arraylen(options.rangeStyles)]>
		<cfloop from="#arraylen(options.range)#" to="1" step="-1" index="i">
			<cfset currMax = options.range[i]>
			
			<cfif percent LE currMax>
				<cfif i GT arraylen(options.rangeStyles)>
					<cfset i = arraylen(options.rangeStyles)>
				</cfif>
				
				<cfset styleClass = options.rangeStyles[i]>
			</cfif>
		</cfloop>
		

		<cfoutput>
		<cfsavecontent variable="output">
			<div class="OCMSProgressBar #styleClass#" style="text-align: left; width: #options.width#px; display: inline-block; background-color: ##FFF; vertical-align: middle; float: left;">
				<div style="width: #percent#%"></div>
			</div>
		</cfsavecontent>
		</cfoutput>
		
		<cfreturn output>
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="shortenTo" output="no">
		<cfargument name="stringIn" required="yes" type="string">
		<cfargument name="maxLength" required="yes" type="numeric">
		
		<cfset var stringOut = arguments.stringIn>
		
		<cfif len(stringOut) GT arguments.maxLength >
			<cfset stringOut = trim(left(stringOut, arguments.maxLength - 3)) & "...">
		</cfif>
		
		<cfreturn stringOut>		
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="relativeDateDiff">
		<cfargument name="date1" required="yes" type="date">
		<cfargument name="date2" required="no" default="#now()#" type="date">
		
		<cfset var diffString = "seconds ago">
		
		<cfif 		abs(dateDiff('yyyy', date1, date2)) GT 1>
			<cfset diffString = "#abs(dateDiff('yyyy', date1, date2))# years">
			
		<cfelseif 	abs(dateDiff('m', date1, date2)) GT 1>
			<cfset diffString = "#abs(dateDiff('m', date1, date2))# months">
			
		<cfelseif 	abs(dateDiff('d', date1, date2)) GT 1>
			<cfset diffString = "#abs(dateDiff('d', date1, date2))# days">
			
		<cfelseif 	abs(dateDiff('h', date1, date2)) GT 1>
			<cfset diffString = "#abs(dateDiff('h', date1, date2))# hours">
			
		<cfelseif 	abs(dateDiff('n', date1, date2)) GT 1>
			<cfset diffString = "#abs(dateDiff('n', date1, date2))# minutes">
		
		<cfelseif 	abs(dateDiff('n', date1, date2)) GE 0>
			<cfset diffString = "#abs(dateDiff('s', date1, date2))# seconds">

		</cfif>
		
		
		<cfif dateCompare(date1, date2) IS 1>
			<cfset diffString = "#diffString# from now">
		<cfelse>
			<cfset diffString = "#diffString# ago">
		</cfif>
		
		<cfreturn diffString>
	</cffunction>
	
		
		
	<!--- ========================================================== --->
	<cffunction name="randomColor">
		<cfargument name="colorSet" default="DarkBackgrounds">
		<!--- TODO: This function is incomplete... --->
		<cfset colorSet = structnew()>
		
		<cfset colorSet.saturation 	= {min = .5, 	max = 1}>
		<cfset colorSet.hue			= {min = 0,		max = 1}>
		<cfset colorSet.lightness	= {min = .1,	max = .8}>
		
		
		<cfset var color = {red = 255, green = 255, blue = 255}>
		<cfset var colorString = "">
		
		<cfloop list="red,green,blue" index="currComponent">
			<cfset currMin = colorSet.lightness.min * 255>
			<cfset currMax = colorSet.lightness.max * 255>
			<cfset color[currComponent] = randRange(currMin, currMax)>
			<cfset colorString &= formatBaseN(color[currComponent], 16)>
		</cfloop>
		
		
		<cfreturn colorString>	
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="clearCFHTMLHead">
		<!--- http://www.coldfusiondeveloper.nl/post.cfm/clearing-the-cfhtmlhead-buffer-in-railo --->
		<cfset var out = getPageContext().getOut()>
		<cfset var method = "">
		<cfloop condition="(getMetaData(out).getName() is 'coldfusion.runtime.NeoBodyContent')">
			<cfset out = out.getEnclosingWriter()>
		</cfloop>
		
		<cfset method = out.getClass().getDeclaredMethod("initHeaderBuffer",arrayNew(1))>
		<cfset method.setAccessible(true)>
		<cfset method.invoke(out,arrayNew(1))>
	</cffunction>



	
	<!--- ========================================================== --->
	<cffunction name="removeHTML" output="false">
		<cfargument name="source" type="string" required="yes">
		<cfscript>
		
		/**
		* Removes All HTML from a string removing tags, script blocks, style blocks, and replacing special character code.
		*
		* @param source      String to format. (Required)
		* @return Returns a string.
		* @author Scott Bennett (scott@coldfusionguy.com)
		* @version 1, November 14, 2007
		*/
			
			// Remove all spaces becuase browsers ignore them
			var result = ReReplace(trim(source), "[[:space:]]{2,}", " ","ALL");
			
			// Remove the header
			result = ReReplace(result, "<[[:space:]]*head.*?>.*?</head>","", "ALL");
			
			// remove all scripts
			result = ReReplace(result, "<[[:space:]]*script.*?>.*?</script>","", "ALL");
			
			// remove all styles
			result = ReReplace(result, "<[[:space:]]*style.*?>.*?</style>","", "ALL");
			
			// insert tabs in spaces of <td> tags
			result = ReReplace(result, "<[[:space:]]*td.*?>","    ", "ALL");
			
			// insert line breaks in places of <BR> and <LI> tags
			result = ReReplace(result, "<[[:space:]]*br[[:space:]]*>",chr(13), "ALL");
			result = ReReplace(result, "<[[:space:]]*li[[:space:]]*>",chr(13), "ALL");
			
			// insert line paragraphs (double line breaks) in place
			// if <P>, <DIV> and <TR> tags
			result = ReReplace(result, "<[[:space:]]*div.*?>",chr(13), "ALL");
			result = ReReplace(result, "<[[:space:]]*tr.*?>",chr(13), "ALL");
			result = ReReplace(result, "<[[:space:]]*p.*?>",chr(13), "ALL");
			
			// Remove remaining tags like <a>, links, images,
			// comments etc - anything thats enclosed inside < >
			result = ReReplace(result, "<.*?>","", "ALL");
			
			// replace special characters:
			result = ReReplace(result, "&nbsp;"," ", "ALL");
			result = ReReplace(result, "&bull;"," * ", "ALL");
			result = ReReplace(result, "&lsaquo;","<", "ALL");
			result = ReReplace(result, "&rsaquo;",">", "ALL");
			result = ReReplace(result, "&trade;","(tm)", "ALL");
			result = ReReplace(result, "&frasl;","/", "ALL");
			result = ReReplace(result, "&lt;","<", "ALL");
			result = ReReplace(result, "&gt;",">", "ALL");
			result = ReReplace(result, "&copy;","(c)", "ALL");
			result = ReReplace(result, "&reg;","(r)", "ALL");
			
			// Remove all others. More special character conversions
			// can be added above if needed
			result = ReReplace(result, "&(.{2,6});", "", "ALL");
			
			// Thats it.
			return result;
		
		
		</cfscript>
	
	</cffunction>
	
</cfcomponent>