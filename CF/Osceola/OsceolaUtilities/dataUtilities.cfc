<!--- =============================================================================================

Template: 	DataUtilities
Purpose:	A UDF library for various Data Conversion and Manipulation functions
Created:	7/17/2008 by Steven Gongage

	
=============================================================================================  --->

<cfcomponent>
	
	

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
	<cffunction name="phoneNumberFormat">
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
	<cffunction name="capitalize">
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
	<cffunction name="arrayToQuery" access="public" returntype="query">
		<cfargument name="dataIn" 		required="yes" type="array">
		<cfset var outputQ = querynew('column01')>
		<cfset var newColumnName = "">
		<cfset var newColumnList = "">
		
		<cfloop array="#arguments.dataIn#" index="currItem">
			<cfif isStruct(currItem)>
				<cfset queryAddRow(outputQ)>
				<cfloop collection="#currItem#" item="currColumn">
					<cfset newColumnName = replace(currcolumn, " ", "_", "all")>
					<cfif NOT listFindNoCase(outputQ.columnlist, newColumnName)>
						<!--- If this is a new column, create it --->
						<cfset newColumnList = listAppend(newColumnList, newColumnName)>
						<cfset queryAddColumn(outputQ, newColumnName, 'VarChar', arraynew(1))>
					</cfif>
					<cfset currValue = currItem[currColumn]>
					<cfset querySetCell(outputQ, newColumnName, currValue)>
				</cfloop>
			<cfelseif isSimpleValue(currItem)>
				<cfif NOT listFindNoCase(newColumnList, 'column01')>
					<cfset newColumnList = listAppend(newColumnList, 'column01')>
				</cfif>
				<cfset querySetCell(outputQ, 'column01', currItem)>
			</cfif>
		</cfloop>
		
		
		<cfif listLen(outputQ.columnlist) GT 1>
			<!--- Remove the stupid placeholder column we had to have for some reason --->
			<cfquery name="outputQ" dbtype="query">
				SELECT #newColumnList#
					FROM outputQ
			</cfquery>
		</cfif>
		
		<cfreturn outputQ>
	
	</cffunction>
	
	
	
	
	<!--- ========================================================== --->
	<cffunction name="compareStructs">
		<cfargument name="struct1" 		required="yes">
		<cfargument name="struct2"		required="yes">
		<cfargument name="excludeKeys"	required="no" default="">
		
		<cfset isEqual = true>
		
		<!--- Compare Old Data to New Data --->
		<cftry>
			<cfloop list="#structKeyList(arguments.struct1)#" index="currKeyName">
				<cfif 	NOT listFindNoCase(arguments.excludeKeys, currKeyName) >
					<cfif toString(trim(arguments.struct1[currKeyName])) IS NOT toString(trim(arguments.struct2[currKeyName]))>
						<!--- If these two values do not match --->
						<cfset isEqual = false>
					</cfif>
				</cfif>
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#arguments.struct1#">
				<cfdump var="#arguments.struct2#">
				
				<cfabort>
			</cfcatch>
		</cftry>
		
		<cfreturn isEqual>	
	</cffunction>
	
	
	
	<!--- ========================================================== --->
	<cffunction name="newDataObject">
		<cfargument name="dataIn" 		required="no" default="#structnew()#" type="any">
		<cfargument name="itemNumber" 	required="no" default="0" type="numeric">


		<cfset var newObj = createObject('component', 'DataObject')>
		<cfset var newData = "">

		<cfif isQuery(dataIn)>
			<cfset newData = structnew()>
			<!--- Query --->
			<cfif dataIn.recordcount GT 0>
				<cfif itemNumber IS 0 OR itemNumber GT dataIn.recordcount>
					<cfset itemNumber = dataIn.currentRow>
				</cfif>
				<cfset newData = request.utilities.data.queryRowToStruct(dataIn, itemNumber)>
			<cfelse>
				<cfloop list="#dataIn.columnlist#" index="currColumn">
					<cfset newData[currColumn] = "">
				</cfloop>
			</cfif>
			
		<cfelseif isArray(dataIn)>
			<!--- Array --->
			<cfif arraylen(dataIn) GT 0>
				<cfif itemNumber IS 0 OR itemNumber GT arraylen(dataIn)>
					<cfset itemNumber = 1>
				</cfif>
				<cfset newData = dataIn[itemNumber]>
			</cfif>
			
		<cfelseif isInstanceOf(dataIn, 'BaseComponent') OR isInstanceOf(dataIn, 'DataObject') OR isInstanceOf(dataIn, 'MetaDataObject')>
			<!--- MetaDataObject --->
			<cfset newData = dataIn.getData()>
			
		<cfelseif isStruct(dataIn)>
			<!--- Regular old struct --->
			<cfset newData = dataIn>
			
		<cfelseif isSimpleValue(dataIn)>
			<!--- Simple Value --->
			<cfset newData = dataIn>
		</cfif>

		<cfset newObj.load(newData)>
		
		<cfreturn newObj>
		
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
	<cffunction name="formatAsLinkName" access="public" returntype="string">
		<cfargument name="stringIn"				required="yes" type="string">
		
		<cfset var resultString = trim(lcase(stringIn))>

		<cfset resultString = REReplace(resultString, "[^0-9a-zA-Z_ ]", "", "ALL")>
		<cfset resultString = replace(resultString, ' ', '_', 'all')>
		<cfset resultString = replace(resultString, "__", "_", 'all')>
		<cfset resultString = lCase(resultString)>

		
		<cfreturn resultString>
	</cffunction>


	<!---============================================================================================== --->
	<cffunction name="queryToArray" access="public" returntype="array">
		<cfargument name="queryIn"				required="yes" type="query">
		
		<cfset var resultArray = arraynew(1)>
		
		<cfloop query="queryIn">
			<cfset arrayAppend(resultArray, queryRowToStruct(queryIn, queryIn.currentrow))>		
		</cfloop>
		
		<cfreturn resultArray>
	</cffunction>



	<!---============================================================================================== --->
	<cffunction name="queryRowToStruct" access="public" returntype="struct">
		<cfargument name="query" 					required="yes" 	type="query" >
		<cfargument name="rowNumber" 	default="1" required="no"	type="numeric" >
		<cfset var result = structnew()>
		
		<cfif query.recordcount IS 0>
			<cfloop list="#query.columnlist#" index="elem" >
				<cfset result[elem] = "">
			</cfloop>
		<cfelse>
			<cfif query.recordcount GE rowNumber>
				<cfloop list="#query.columnlist#" index="elem" >
					<cfset result[elem] = query[elem][rowNumber]>
				</cfloop>
			<cfelse>
				<cfthrow message="Error in DataUtilities.queryRowToStruct():  The rowNumber #rowNumber# is greater than the number of rows in the query #query.recordcount#">
			</cfif>
		</cfif>
		
		
		<cfreturn result>
	</cffunction>
	
	<!---============================================================================================== --->
	<cffunction name="queryColumnsToStruct">
		<cfargument name="query" 		required="yes" 	type="query" >
		<cfargument name="columnKey"	required="yes" 	type="string" >
		<cfargument name="valueKey"		required="yes" 	type="string">
		
		
		<cfif NOT listFindNoCase(arguments.query.columnlist, arguments.columnKey)>
			<cfthrow message="Error in QueryToStruct().  Cannot find the column key '#arguments.columnkey#' in the query provided.">
		</cfif>
		<cfif NOT listFindNoCase(arguments.query.columnlist, arguments.valueKey)>
			<cfthrow message="Error in QueryToStruct().  Cannot find the column key '#arguments.valueKey#' in the query provided.">
		</cfif>
		
		<cfset var result 			= structnew()>
		<cfset var currColumn 	= ''>
		<cfset var currValue		= ''>
		
		<cfloop query="arguments.query">
			<cfset currColumn 	= arguments.query[arguments.columnKey][arguments.query.currentRow]>
			<cfset currValue	= arguments.query[arguments.valueKey][arguments.query.currentRow]>
			<cfset result[currColumn] = currValue>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	


	<!--- ========================================================== --->
	<cffunction name="getMeta">
		<cfargument name="dataIn"  required="yes">
		<cfargument name="rowNumber" default="1" type="numeric">
		
		<cfset var returnStruct = structnew()>
		<cfset var tempData = structnew()>
		
		<cfif isQuery(dataIn)>
			<cfif rowNumber GT 0 AND rowNumber LE dataIn.recordcount>
				<cfset dataIn = queryRowToStruct(dataIn, dataIn.currentRow)>
			</cfif>
		</cfif>
		
		
		<cfif isStruct(dataIn)>
			<cfset tempData.metaDataCommon 		= dataIn.metaDataCommon>
			<cfset tempData.metaDataLocalized 	= dataIn.metaDataLocalized>
			
			<cfif structKeyExists(dataIn, 'metaDataCommon') AND isJSON(dataIn.metaDataCommon)>
				<cfset structAppend(returnStruct, deserializeJSON(tempData.metaDataCommon))>
			</cfif>
	
			<cfif structKeyExists(dataIn, 'metaDataLocalized') AND isJSON(dataIn.metaDataLocalized)>
				<cfset structAppend(returnStruct, deserializeJSON(tempData.metaDataLocalized), true)>
			</cfif>
			
		<cfelseif isSimpleValue(dataIn) AND isJSON(dataIn)>
			<cfset returnStruct = deserializeJSON(dataIn)>
			
		</cfif>
		
		<cfreturn returnStruct>
	</cffunction>
	


	<!--- ========================================================== --->
	<cffunction name="createDataObject">
		<cfargument name="dataIn"  required="yes">
		<cfargument name="rowNumber" default="1" type="numeric">
		
		<cfset var returnDO 	= createObject('component', 'NexusWeb2.Data.DataObject')>
		<cfset var meta 		= structnew()>
		<cfset var returnData 	= structnew()>
		<cfset var tempMetaData = structnew()>
		
		<cfif isQuery(dataIn)>
			<cfif rowNumber GT 0 AND rowNumber LE dataIn.recordcount>
				<cfset dataIn = queryRowToStruct(dataIn, dataIn.currentRow)>
			</cfif>
		</cfif>
		
		<cfset meta = getMeta(dataIn)>
		
		<cfloop collection="#dataIn#" item="key">
			<cfif dataIn[key] CONTAINS '":"' AND isJSON(dataIn[key])>
				<cfset tempMetaData = deserializeJSON(dataIn[key])>
				<cfif isArray(tempMetaData)>
					<cfset returnData[key] = tempMetaData>
				<cfelse>
					<cfset structAppend(returnData, tempMetaData, false)>
				</cfif>
			<cfelse>
				<cfset returnData[key] = dataIn[key]>
			</cfif>
		</cfloop>
		
		<cfset returnDO.setData(returnData)>
		
		<cfreturn returnDO>
	</cffunction>
	



	<!---============================================================================================== --->
	<cffunction name="serializeJSONReadable" output="no">
		<cfargument name="input" required="yes">
		
		<cfset var output = serializeJSON(input)>
		
		<cfset output = replace(output, ',"', ',#chr(10)#"', "all")>
		<cfset output = replace(output, "{", "#chr(10)#{", "all")>
		<cfset output = replace(output, "},", "#chr(10)#},#chr(10)#", "all")>
		<cfset output = replace(output, '#chr(10)#,"', ',#chr(10)#"', "all")>
		<cfset output = replace(output, '{"', '{#chr(10)#"', "all")>
		
		<cfif NOT isJSON(output)>
			<cfset output = "Is not valid JSON#chr(10)#" & output>
		</cfif>
		
		<cfreturn trim(output)>
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
	<cffunction name="randomCode" access="public" returntype="string">
		<cfargument name="length" required="yes" type="numeric">
		<cfset var newCode = "">
		<cfloop from="1" to="#arguments.length#" index="i">
			<cfset num = randrange(65, 98)>
			<cfif num LE 90>
				<cfset newCode &= chr(num)>
			<cfelse>
				<cfset newCode &= num - 89>
			</cfif>
		</cfloop>
		
		<cfreturn newCode>
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
				.CharMapTable TD { border: 1px solid gray; padding: 2px; width: 24px; text-align: center; }
					.CharMapTable TD.unprintable{ background-color: ##DDD }
					.CharMapTable TD.special	{ background-color: ##FF9 }
					.CharMapTable TD.number	 	{ background-color: ##AFB }
					.CharMapTable TD.alphaUpper	{ background-color: ##BDF }
					.CharMapTable TD.alphaLower	{ background-color: ##DEF }
					.CharMapTable TD.extended	{ background-color: ##FCC }
					.CharMapTable TD.ISOextended{ background-color: ##FAA }
					
				.CharMapTable PRE { 
					border: 1px solid silver; width: 16px; height: 16px; font-weight: bold; text-align: center; margin: 0px auto; padding: 0px;
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
	
	
	<!--- ============================================================================================= --->
    <cffunction name="HTMLtoXHTML" access="public" returntype="xml">
    	<cfargument name="sHTML" type="string" required="yes" />
		<!---
		http://www.bennadel.com/blog/1723-Parsing-Invalid-HTML-Into-XML-Using-ColdFusion-Groovy-And-TagSoup.htm
		--->
        
        <!--- Set-Up Groovy --->
        <cfimport prefix="g" taglib="/approot/extensions/cfGroovy/" />
        
        <!---
        <cfset currentDirectory = getDirectoryFromPath(getCurrentTemplatePath()) />
        
        <cfset tagSoupJarFile = (currentDirectory & "tagsoup-1.2.jar") />
		--->
        
        <cfset tagSoupJarFile = expandPath("/extensions/cfGroovy/tagsoup-1.2.jar") />
        
        
        <!--- Set the HTML variable used in the Groovy script below --->
		<cfset html = arguments.sHTML />
        
        <!--- Re-Write the returned HTML into XHTML ---> 
         <g:script>
          
         <!---
         Get the class loader being used by the Groovy script
         engine. We will need this to load classes in the TagSoup
         JAR file.
         --->
         def classLoader = this.getClass().getClassLoader();
          
         <!---
         Add the TagSoup JAR file to the class loader's list of
         classes that it can instantiate.
         --->
         classLoader.addURL(
         new URL( "file:///" + variables.tagSoupJarFile )
         );
          
         <!---
         Get an instance of the the tag soup parser HTML parser
         from the class loader. This is a SAX-compliant parser.
         --->
         def tagSoupParser = Class.forName(
         "org.ccil.cowan.tagsoup.Parser",
         true,
         classLoader
         )
         .newInstance()
         ;
          
         <!---
         Create an instance of the Groovy XML Slurper using the
         TagSoup parsing engine.
         --->
         def htmlParser = new XmlSlurper( tagSoupParser );
          
         <!---
         Parse the raw HTML text into a valid XHTML document using
         the TagSoup parsing engine. This will give us GPathResult
         XML Document.
         --->
         def xhtml = htmlParser.parseText( variables.html );
          
         <!---
         Now that we have an XHTML (XML) document, we need to
         serialize that back into HTML mark up.
         --->
         def cleanHtmlWriter = new StringWriter()
          
         <!---
         This builds the markup in the string writer using the
         Streaming markup builder.
          
         NOTE: This step loses me a bit. I have not been able to
         find any great documentation on how this is uses or what
         exactly it does. But, it looks like somehow the XHTML
         document is being bound to the markup builder, which is
         then searialized to the string writer.
         --->
         cleanHtmlWriter << new groovy.xml.StreamingMarkupBuilder().bind(
         {
         mkp.declareNamespace( '': 'http://www.w3.org/1999/xhtml' );
         mkp.yield( xhtml );
         }
         );
          
         <!---
         Now that we have our X(HTML) document serialized in our
         string writer, let's convert it to a string and store it
         back into the ColdFusion varaibles scope.
         --->
         variables.xhtml = cleanHtmlWriter.toString().trim();
          
         </g:script>
        
        <!--- Instantiate the jTidy Object 
        <cfobject component="jtidy_cfc.jtidy" name="objJTidy">
        --->
        
        <!--- Parse the returned XHTML into XML --->
        <cfset xml = XmlParse(xhtml) />

        
        <cfreturn xml />
        
    </cffunction>


</cfcomponent>