<!--- =========================================================================================================

	Created:		Steve Gongage (4/12/2013)
	Purpose:		Utilities for outputting, formatting, or displaying data 

========================================================================================================= --->

<cfcomponent extends="cf.Gongage.Utilities.UtilityBase">
	<!---============================================================================================== --->
	<cffunction name="phoneNumberFormat" group="strings" hint="Format a set of numbers to look like a phone number.">
		<cfargument name="input" type="string">
		<cfset var digits = parseInt(input)>
		<cfset var output = "">
		
		<cfif len(digits) GT 10>
			<cfset output = "(#left(digits, 3)#) #mid(digits, 4,3)#-#mid(digits, 7, 4)#">
		<cfelseif len(digits) IS 10>
			<cfset output = "(#left(digits, 3)#) #mid(digits, 4,3)#-#mid(digits, 7, 4)#">
		<cfelseif len(digits) GE 7>
			<cfset output = "#mid(digits, 1,3)#-#mid(digits, 4, 4)#">
		<cfelse>
			<cfset output = digits>
		</cfif>
		
		<cfreturn output>
	</cffunction>
	
	<!---============================================================================================== --->
	<cffunction name="capitalizeFirst" group="strings" hint="Capitalizes the first letter of each word (space delimited) in a string and lower cases the rest.  Excludes some things like Roman Numerals.">
		<cfargument name="input" type="string">
		<cfset var output = "">
		<cfset input = trim(input)>
		<cfloop list="#input#" index="word" delimiters=" ">
			<cfset newWord = trim(word)>
			
			<cfif listFindNoCase('I,II,III,IV,V,VI,VII,VIII,IX,X', newWord)>
				<cfset newWord = uCase(newWord)>
			<cfelseif len(newWord) GT 1>
				<cfset newWord = uCase(left(trim(word), 1))>
				<cfset newWord &= lCase(right(trim(word), len(trim(word)) - 1))>
			</cfif>
			<cfset output = listAppend(output, newWord, " ")>			
		</cfloop>
		
		<cfreturn output>
	</cffunction>

	<!---============================================================================================== --->
	<cffunction name="readableJSON" output="no" group="debugging" hint="Outputs a JSON string in a format that is human readable.">
		<cfargument name="input" required="yes">
		
		<cfset var output = ARGUMENTS.input>
		<cfif NOT isJSON(output)>
			<cfset output = serializeJSON(input)>
		</cfif>
		
		<cfset output = replace(output, ',"', ',#chr(10)#"', "all")>			<!--- Drop Commas to next line --->
		<cfset output = replace(output, "{", "#chr(10)#{", "all")>				<!--- Open bracket to new line --->
		<cfset output = replace(output, "}", "#chr(10)#}#chr(10)#", "all")>		<!--- Closed bracket to new line --->
		<cfset output = replace(output, "},", "#chr(10)#},#chr(10)#", "all")>	<!--- Closed bracket + comma to new line --->
		<cfset output = replace(output, '#chr(10)#,"', ',#chr(10)#"', "all")>	<!--- Comma + open quote to new line --->
		<cfset output = replace(output, '{"', '{#chr(10)#"', "all")>			<!--- Open bracket + open quote to new line --->
		
		<cfif NOT isJSON(output)>
			<cfset output = "Is not valid JSON#chr(10)#" & output>
		</cfif>
		
		<cfreturn trim(output)>
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="shortenNumber" output="no" group="strings" hint="Takes in a number and returns it shortened.">
		<cfargument name="numberIn" required="yes" type="numeric">
		
		<cfset var numberOut = numberIn>
		
		<cfif numberOut GE 1000000>
			<cfset numberOut = '#numberformat(numberOut / 1000000, '999,999.0')#<span style="font-size: 11px;">mil</span>'>
		<cfelseif numberOut GE 1000>
			<cfset numberOut = '#numberformat(numberOut / 1000, '999,999.0')#<span style="font-size: 10px;">thousand</span>'>
		<cfelse>
			<cfset numberOut = numberformat(numberOut, '999,999')>
		</cfif>

		
		<cfreturn numberOut>		
	</cffunction>
	
	
	<!--- ========================================================== --->
	<cffunction name="progressBar" group="output" hint="Build an HTML bar for a given string.  Depends on external CSS.">
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
	<cffunction name="shortenTo" group="strings"  output="no" hint="Cuts a string down to a certain length and adds ellipses (or your choice of strings) at the end.">
		<cfargument name="stringIn" required="yes" type="string">
		<cfargument name="maxLength" required="yes" type="numeric">
		<cfargument name="appendString" required="false" type="string" default="...">
		
		<cfset var stringOut = arguments.stringIn>
		
		<cfif len(stringOut) GT arguments.maxLength >
			<cfset stringOut = trim(left(stringOut, arguments.maxLength - 3)) & arguments.appendString>
		</cfif>
		
		<cfreturn stringOut>		
	</cffunction>
	

	<!--- ========================================================== --->
	<cffunction name="durationFormat" group="time" hint="takes in seconds and returns a string in HH:MM:SS format.">
		<cfargument name="seconds" default="0" required="yes" type="numeric">
		
		<cfreturn "#numberformat(int(arguments.seconds / 3600), '00')#:#numberformat(int(arguments.seconds / 60), '00')#:#numberformat(arguments.seconds MOD 60, '00')#">		
	</cffunction>


	<!--- ========================================================== --->
	<cffunction name="timeDiffAsDuration" group="time" hint="Formats the time difference between two datetimes.">
		<cfargument name="date1" required="yes" type="date">
		<cfargument name="date2" required="no" default="#now()#" type="date">

		<cfreturn durationFormat(dateDiff('s', ARGUMENTS.date1, ARGUMENTS.date2))>

	</cffunction>	

	<!--- ========================================================== --->
	<cffunction name="timeDiffAsString" group="time" hint="Formats the time difference between two datetimes as the most convenient time unit.">
		<cfargument name="date1" required="yes" type="date">
		<cfargument name="date2" required="no" default="" type="any">
		<cfargument name="unit" required="no" default="">
		
		<cfset var diffString 	= "seconds ago">
		<cfset var unitAbbr 	= arguments.unit>
		<cfset var unitName 	= "seconds">
		<cfset var isNow		= false>
		<cfif NOT isDate(ARGUMENTS.date2)>
			<cfset ARGUMENTS.date2 	= now()>
			<cfset isNow			= true>
		</cfif>

		<cfif NOT listFindNoCase('yyyy,m,d,h,n,s', LOCAL.unitAbbr)>
			<cfset LOCAL.unitAbbr = "">
		</cfif>

		<cfif LOCAL.unitAbbr IS "">
			<cfif 		abs(dateDiff('yyyy', date1, date2)) GT 1>
				<cfset LOCAL.unitAbbr = "yyyy">				
			<cfelseif 	abs(dateDiff('m', date1, date2)) GT 1>
				<cfset LOCAL.unitAbbr = "m">
			<cfelseif 	abs(dateDiff('d', date1, date2)) GT 1>
				<cfset LOCAL.unitAbbr = "d">
			<cfelseif 	abs(dateDiff('h', date1, date2)) GT 1>
				<cfset LOCAL.unitAbbr = "h">
			<cfelseif 	abs(dateDiff('n', date1, date2)) GT 1>
				<cfset LOCAL.unitAbbr = "n">
			<cfelseif 	abs(dateDiff('s', date1, date2)) GE 0>
				<cfset LOCAL.unitAbbr = "s">
			</cfif>

		</cfif>

		<cfswitch expression="#LOCAL.unitAbbr#">
			<cfcase value="yyyy">
				<cfset LOCAL.unitName = "year">
			</cfcase>
			<cfcase value="m">
				<cfset LOCAL.unitName = "month">
			</cfcase>
			<cfcase value="d">
				<cfset LOCAL.unitName = "day">
			</cfcase>
			<cfcase value="h">
				<cfset LOCAL.unitName = "hour">
			</cfcase>
			<cfcase value="n">
				<cfset LOCAL.unitName = "minute">
			</cfcase>
			<cfcase value="s">
				<cfset LOCAL.unitName = "second">
			</cfcase>
		</cfswitch>


		<cfset var diffNumber = dateDiff(LOCAL.unitAbbr, ARGUMENTS.date1, ARGUMENTS.date2)>

		<cfif LOCAL.diffNumber IS NOT 1>
			<cfset LOCAL.unitName &= "s">
		</cfif>


		<cfset LOCAL.diffString = "#numberformat(LOCAL.diffNumber, '999,999,999')# #LOCAL.unitName#">

		
		<cfif LOCAL.isNow>
			<cfif ARGUMENTS.date1 LT ARGUMENTS.date2>
				<cfset LOCAL.diffString = "#LOCAL.diffString# from now">
			<cfelse>
				<cfset LOCAL.diffString = "#LOCAL.diffString# ago">
			</cfif>
		</cfif>
			
		<cfreturn LOCAL.diffString>
	</cffunction>
	
		
		
	<!--- ========================================================== --->
	<cffunction name="randomColor" group="output" hint="Creates a random hex color string">
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
	<cffunction name="removeHTML" output="false" group="output" hint="Strips out all HTML tags from a string.">
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


<cfscript>
	/*
	 * @name numberToWord
	 * @output no
	 * @description translate an integer value into its English equivelent.
	 * Current range is 0 to 9999, out of range returns passed number
	 */
	public string function numberToWord(required numeric number){
		var ntw = {
			'0' = 'zero',
			'1' = 'one',
			'2' = 'two',
			'3' = 'three',
			'4' = 'four',
			'5' = 'five',
			'6' = 'six',
			'7' = 'seven',
			'8' = 'eight',
			'9' = 'nine',
			'10' = 'ten',
			'11' = 'eleven',
			'12' = 'twelve',
			'13' = 'thirteen',
			'14' = 'fourteen',
			'15' = 'fifteen',
			'16' = 'sixteen',
			'17' = 'seventeen',
			'18' = 'eightteen',
			'19' = 'nineteen',
			'2X' = 'twenty',
			'3X' = 'thirty',
			'4X' = 'forty',
			'5X' = 'fifty',
			'6X' = 'sixty',
			'7X' = 'seventy',
			'8X' = 'eighty',
			'9X' = 'ninety'
		};
		var aReturn = [];
		arguments.number = ReReplace(arguments.number, '[^0-9]+','','all');
		var aNum = arguments.number.toCharArray();
		if(ArrayLen(local.aNum) eq 1){
			ArrayAppend(local.aReturn, local.ntw[local.aNum[1]]);
		}else if(ArrayLen(local.aNum) eq 2){
			if(left(arguments.number,1) eq '1'){
				ArrayAppend(local.aReturn, local.ntw[arguments.number]);
			}else{
				ArrayAppend(local.aReturn, local.ntw[local.aNum[1]&'X']);
				if(local.aNum[2].ToString() neq '0'){ ArrayAppend(local.aReturn, local.ntw[local.aNum[2]]); }
			}
		}else{
			for(var i=1;local.i lte ArrayLen(local.aNum)-2;local.i++){
				if(local.i eq ArrayLen(local.aNum)-2){
					if(local.aNum[i].ToString() neq '0'){ ArrayAppend(local.aReturn, local.ntw[local.aNum[i]] & ' hundred'); }
				}else if(local.i eq ArrayLen(local.aNum)-3){
					ArrayAppend(local.aReturn, local.ntw[local.aNum[i]] & ' thousand#right(arguments.number,3) neq '000'?',':''#');
				}else{
					return arguments.number;
				}
			}
			if(right(arguments.number,2) neq '00'){
				ArrayAppend(local.aReturn, 'and');
				if(local.aNum[ArrayLen(local.aNum)-1].ToString() eq '1'){
					ArrayAppend(local.aReturn, local.ntw[right(arguments.number,2)]);
				}else{
					if(local.aNum[ArrayLen(local.aNum)-1].ToString() neq '0'){ ArrayAppend(local.aReturn, local.ntw[local.aNum[ArrayLen(local.aNum)-1] & 'X']); }
					if(local.aNum[ArrayLen(local.aNum)].ToString() neq '0'){ ArrayAppend(local.aReturn, local.ntw[local.aNum[ArrayLen(local.aNum)]]); }
				}
			}
		}
		return ArrayToList(local.aReturn, ' ');
	}



	
	/*
	 * @name randomString
	 * @output no
	 * @description create a string of random characters.
	 */
	public string function randomString(
			lcaseAlpha	= "abcdefghijklmnopqrstuvwxyz",
			setUcase	= true,
			numeric		= "0123456789",
			special		= "~!@##$%^&*",
			minlength	= 6,
			maxlength	= 20
		){
		var strUCAlpha = arguments.setUCase ? UCase(arguments.lcaseAlpha) : "";
		var strValid = arguments.lcaseAlpha & local.strUCAlpha & arguments.numeric & arguments.special;
		var aResult = [];
		var i = 1;
		var min = arguments.minlength gt 3 and arguments.minlength lte 100 ? arguments.minlength : 6;
		var max = arguments.maxlength gt 3 and arguments.maxlength lte 100 ? arguments.maxlength : 20;
		var istop = RandRange(local.min, local.max);
		if(arguments.lcaseAlpha neq ''){
			local.aResult[local.i] = Mid(arguments.lcaseAlpha, RandRange(1, Len(arguments.lcaseAlpha)), 1);
			local.i++;
		}
		if(local.strUCAlpha neq ''){
			local.aResult[local.i] = Mid(local.strUCAlpha, RandRange(1, Len(local.strUCAlpha)), 1);
			local.i++;
		}
		if(arguments.numeric neq ''){
			local.aResult[local.i] = Mid(arguments.numeric, RandRange(1, Len(arguments.numeric)), 1);
			local.i++;
		}
		if(arguments.special neq ''){
			local.aResult[local.i] = Mid(arguments.special, RandRange(1, Len(arguments.special)), 1);
			local.i++;
		}
		while(local.i lte local.max){
			local.aResult[local.i] = Mid(local.strValid, RandRange(1, Len(local.strValid)), 1);
			local.i++;
		}
		//SHUFFLE CHARACTERS IN ARRAY
		createObject('java','java.util.Collections').Shuffle(local.aResult);
		return ArrayToList(local.aResult, "");
	}



</cfscript>	
	
</cfcomponent>