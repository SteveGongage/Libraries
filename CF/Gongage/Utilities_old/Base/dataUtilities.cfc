<!--- =============================================================================================

Template: 	DataUtilities
Purpose:	A UDF library for various Data Conversion and Manipulation functions
Created:	7/17/2008 by Steven Gongage

	
=============================================================================================  --->


<cfcomponent extends="cf.Gongage.Utilities.UtilityBase">
	
	



	<!---============================================================================================== --->
	<cffunction name="OCMSDecrypt">
		<cfargument name="input" type="string" required="yes">
		<cfreturn decrypt(arguments.input, request.global.encryption.key, request.global.encryption.algorithm, request.global.encryption.encoding)>
	</cffunction>	
	
	<!---============================================================================================== --->
	<cffunction name="OCMSEncrypt">
		<cfargument name="input" type="string" required="yes">
		<cfreturn encrypt(arguments.input, request.global.encryption.key, request.global.encryption.algorithm, request.global.encryption.encoding)>
	</cffunction>	
	

	
	<!---============================================================================================== --->
	<cffunction name="parseInt">
		<cfargument name="input" type="string">
		<cfset var i = 0>
		<cfset var output = "">
		<cfloop from="1" to="#len(input)#" index="i">
			<cfset curr = mid(input, i, 1)>
			<cfif isNumeric(curr)>
				<cfset output &= curr>
			</cfif>
			
		</cfloop>
		
		<cfreturn output>
	</cffunction>
	
	
	
	<!---============================================================================================== --->
	<cffunction name="listDiff" output="yes">
		<cfargument name="leftList" 	type="string" required="yes" />
		<cfargument name="rightList" 	type="string" required="yes" />
		<cfargument name="delimiter"	type="string" default=","	/>
		<cfargument name="compareType" 	type="string" default="different"> <!--- different or same --->

		<cfset var returnList = "">

		<cfloop list="leftList,rightList" index="currListName">
			<cfset currList = arguments[currListName]>
			<cfset otherList = arguments.rightList>
			<cfif currListName IS "rightList">
				<cfset otherList = arguments.leftList>
			</cfif>

			<cfloop list="#currList#" index="currItem" delimiters="#arguments.delimiter#">
				<cfset found =  listFindNoCase(otherList, currItem, arguments.delimiter)>
				<cfif 	(found AND arguments.compareType IS "same")
						OR (NOT found AND arguments.compareType IS "different")>

					
					<cfset returnList = listAppend(returnList, currItem, arguments.delimiter)>

				</cfif>
			</cfloop>

		</cfloop>
			
		<cfreturn returnList>
	</cffunction>	
	
	<!---============================================================================================== --->
	<!--- http://www.mollerus.net/tom/blog/2008/03/creating_randomlyordered_lists.html --->
	<cffunction name="getRandomOrder" output="yes">
		<cfargument name="object" type="any" required="yes" />
		<cfset var list = '' />
		<cfset var randomPos = 1 />
		<cfset var result = ArrayNew(1) />
		
		<!--- Create a sorted list depending on the type of object passed in --->
		<cfif IsStruct(ARGUMENTS.object)>
			<cfset list = StructKeyList(ARGUMENTS.object)>
		<cfelseif IsQuery(ARGUMENTS.object)>
			<cfloop index="index" from="1" to="#ARGUMENTS.object.recordCount#">
				<cfset list = ListAppend(list, index) />
			</cfloop>
		<cfelseif IsArray(ARGUMENTS.object)>
			<cfloop index="index" from="1" to="#ArrayLen(ARGUMENTS.object)#">
				<cfset list = ListAppend(list, index) />
			</cfloop>
		<cfelse>
			<cfset list = ARGUMENTS.object />
		</cfif>
		
		<!--- Convert the list to an array for speed --->
		<cfset list = ListToArray(list) />
		
		
		<!--- As many times as there are items in the current list --->
		<cfloop index="i" from="1" to="#ArrayLen(list)#">
			<!--- Add one list item at random to the results --->
			<cfset randomPos = RandRange(1, ArrayLen(list)) />
			<cfset ArrayAppend(result, list[randomPos]) />
			<!--- Remove that list item --->
			<cfset ArrayDeleteAt(list, randomPos) />
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	
	
	
	<!---============================================================================================== --->
	<cffunction name="queryToCSV" access="public" returntype="string">
		<cfargument name="dataIn" 		required="yes" type="query">
		<cfargument name="delimiter"	required="no" default=",">
		<cfargument name="rowDelimiter"	required="no" default="#chr(10)#">
		
		<cfset var output = "">
		<cfset var newRow = "">
		<cfset var currValue = "">
		
		<cfloop list="#arguments.dataIn.columnlist#" index="currColumn">
			<cfset output = listAppend(output, '"#currColumn#"', arguments.delimiter)>
		</cfloop>
		<cfset output &= rowDelimiter>

		<cfloop query="arguments.dataIn">
			<cfset newRow = "">
			<cfloop list="#arguments.dataIn.columnlist#" index="currColumn">
				<cfset currValue = arguments.dataIn[currColumn][currentRow]>
				<cfset currValue = replace(currValue, '"', "'", "all")>
				<cfset currValue = replace(currValue, arguments.delimiter, "", "all")>
				
				<cfif isDate(currValue)>
					<cfset currValue = dateformat(currValue, 'mm/dd/yyyy')>
				</cfif>
								
				<cfset newRow = listappend(newRow, '"#currValue#"', arguments.delimiter)>				
			</cfloop>
			
			<cfset output &= newRow & arguments.rowDelimiter>
		</cfloop>
		
		
		<cfreturn output>		
	</cffunction>
	
	
	<!---============================================================================================== --->
	<cffunction name="encodeTemporaryValue" access="public" returntype="string" output="no">
		<cfargument name="value" 		required="yes"	type="string">
		<cfargument name="expiresOn"	required="no" 	default="#dateAdd('h', 1, now())#" type="date">
		
		<cfset var returnData 	= ''>
		<cfset var expirationString = dateformat(arguments.expiresOn, 'yyyymmdd') & timeformat(arguments.expireson, 'HHmm')>
		
		<cfset returnData = 	hash(arguments.value)>
		<cfset returnData &= 	hash(expirationString)>
		<cfset returnData &= 	expirationString>
		<cfset returnData &= 	arguments.value>
		
		<cfreturn returnData>
	</cffunction>

	<!---============================================================================================== --->
	<cffunction name="decodeTemporaryValue" access="public" returntype="string" output="no">
		<cfargument name="dataIn"		required="yes" type="string">
		
		<cfset var returnValue 	= "">
		<cfset var data 		= structnew()>
		<cfset data.input			= arguments.dataIn>
		<cfset data.isValidHash		= false>
		<cfset data.isValidDate		= false>
		<cfset data.isConfirmed		= false>
		<cfset data.expiresOn		= now()>
		<cfset data.hashedValue		= "">
		<cfset data.hashedDate		= "">
		<cfset data.plainDate		= "">
		<cfset data.plainValue		= "">
		
		<cfif len(dataIn) GE 77>
			<cfset data.hashedValue		= mid(dataIn, 1, 32)>
			<cfset data.hashedDate		= mid(dataIn, 33, 32)>
			<cfset data.plainDate		= mid(dataIn, 65, 12)>
			<cfset data.plainValue		= mid(dataIn, 77, len(dataIn) - 76)>
			
			<cfif 		hash(data.plainValue) 	IS data.hashedValue 
					AND hash(data.plainDate) 	IS data.hashedDate>
				<cfset data.isValidHash	= true>
			</cfif>
	
			<cfif isNumeric(data.plainDate)>
				<cftry>
					<cfset data.expiresOn = createDateTime(mid(data.plainDate, 1, 4), mid(data.plainDate, 5, 2), mid(data.plainDate, 7, 2), mid(data.plainDate, 9, 2), mid(data.plainDate, 11, 2), 59)>
					<cfif dateCompare(data.expiresOn, now()) GE 0>
						<cfset data.isValidDate = true>
					</cfif>
					<cfcatch type="any">
						<cfset data.isValidDate = false>
					</cfcatch>
				</cftry>
			</cfif>
			
			<cfset data.isConfirmed = data.isValidHash AND data.isValidDate>
			
			<cfif data.isConfirmed>
				<cfset returnValue = data.plainValue>	
			</cfif>
		</cfif>
		
		<cfset request.decodeResults = data>	<!--- output the decode results just in case they are needed --->
		<cfreturn returnValue>	
	</cffunction>	
	
	
	<!--------------------------------------
		A Temp UserID is a 32 char hash of today's date in mm-dd-yyyy format and an n length integer representing the ID of the user.  
			- 32 char hash of the user's idUser value
			- 32 char hash of today's date
			- n length integer for the user's idUser value
	--------------------------------------->
	<cffunction name="encodeTemporaryID" access="public" returntype="string">
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var tempUserID = ''>
		<cfset var dateUsed		= '#day(now())#'& hour(now())>
		
		<cfset tempUserID &= hash(arguments.id)>
		<cfset tempUserID &= hash(dateUsed)>
		<cfset tempUserID &= arguments.id>
		
		<cfreturn tempUserID>
	</cffunction>
	<cffunction name="decodeTemporaryID" access="public" returntype="string">
		<cfargument name="encodedID" required="yes" type="string">
		<cfset var id = 0>
		<cfset var dateUsedNow 		= '#day(now())#'& hour(now())>
		<cfset var dateUsedOld		= '#day(now())#'& hour(now()) - 1>
		
		<cfset var decoding = structnew()>
		<cfif len(encodedID) GT 64>
			<cfset decoding.id				= right(encodedID, len(encodedID) - 64)>
			<cfset decoding.idHash 			= left(encodedID, 32)>
			<cfset decoding.idHash_valid 	= hash(decoding.id)>
			<cfset decoding.dateHash		= mid(encodedID, 33, 32)>
			<cfset decoding.dateHash_valid 	= hash(dateUsedNow)>
			<cfset decoding.dateHash_older	= hash(dateUsedOld)>
			<cfset decoding.validated		= false>
			<cfif decoding.idHash IS decoding.idHash_valid>
				<cfif 		decoding.dateHash IS decoding.dateHash_valid>
					<!--- If the date hash is exactly correct --->
					<cfset decoding.validated = true>
					<cfset id = decoding.id>
				<cfelseif	decoding.dateHash IS decoding.dateHash_older>
					<!--- If the date hash was correct last hour (just in case encoding and decoding happen on the transition between 2 hours) --->
					<cfset decoding.validated = true>
					<cfset id = decoding.id>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn id>
	</cffunction>
	

	<!--- ============================================================================================= --->
	<cffunction name="charMap">
		<cfargument name="stringIn" type="string">
		
		<cfset var i = 0>
		<cfset var map = arraynew(1)>
	
		<cfloop from="1" to="#len(stringIn)#" index="i">
			<cfset mapItem = structnew()>
			<cfset mapItem['original'] 	= mid(stringIn, i, 1)>
			<cfset mapItem['ascii']		= asc(mapItem['original'])>
			<cfset mapItem['position']	= i>
			<cfif mapItem['ascii'] LE 32>
				<cfset mapItem['type']	= 'unprintable'>
			<cfelseif mapItem['ascii'] LE 47>
				<cfset mapItem['type']	= 'special'>
			<cfelseif mapItem['ascii'] LE 57>
				<cfset mapItem['type']	= 'number'>
			<cfelseif mapItem['ascii'] LE 64>
				<cfset mapItem['type']	= 'special'>
			<cfelseif mapItem['ascii'] LE 90>
				<cfset mapItem['type']	= 'alphaUpper'>
			<cfelseif mapItem['ascii'] LE 96>
				<cfset mapItem['type']	= 'special'>
			<cfelseif mapItem['ascii'] LE 122>
				<cfset mapItem['type']	= 'alphaLower'>
			<cfelseif mapItem['ascii'] LE 127>
				<cfset mapItem['type']	= 'special'>
			<cfelseif mapItem['ascii'] LE 255>
				<cfset mapItem['type']	= 'extended'>
			<cfelseif mapItem['ascii'] LE 8482>
				<cfset mapItem['type']	= 'ISOextended'>
			</cfif>
			
			<cfset mapItem['isExtended']= mapItem['ascii'] GT 127>
			<cfset arrayAppend(map, mapItem)>
		</cfloop>
		
		
		<cfoutput>
		<style>
			.CharMapTable {
				border-collapse: collapse; font-size: 11px;
			}
				.CharMapTable TD { border: 1px solid gray; padding: 2px; width: 24px; text-align: center; color: black;}
					.CharMapTable TD.unprintable{ background-color: ##DDD }
					.CharMapTable TD.special	{ background-color: ##FF9 }
					.CharMapTable TD.number	 	{ background-color: ##AFB }
					.CharMapTable TD.alphaUpper	{ background-color: ##BDF }
					.CharMapTable TD.alphaLower	{ background-color: ##DEF }
					.CharMapTable TD.extended	{ background-color: ##FCC }
					.CharMapTable TD.ISOextended{ background-color: ##FAA }
					
				.CharMapTable PRE { 
					border: 1px solid silver; width: 16px; height: 16px; font-size: 1.2em; font-weight: bold; text-align: center; margin: 0px auto; padding: 0px;
				}
		</style>
		
		<table style="" class="CharMapTable">
		<tr>
			<cfloop array="#map#" index="mapItem">
				<td class="#mapItem['type']#">
					<pre>#mapItem['original']#</pre>
					<br />
					#mapItem['ascii']#
					<br />
				</td>
			</cfloop>
		</tr>
		</table>
		</cfoutput>
	</cffunction>
	



</cfcomponent>