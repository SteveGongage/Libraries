<!--- =============================================================================================

Template: 	DataUtilities
Purpose:	A UDF library for various Data Conversion and Manipulation functions
Created:	7/17/2008 by Steven Gongage

	
=============================================================================================  --->


<cfcomponent extends="cf.Gongage.utilities.LibraryBase">
	
	
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
	
	

	
		



</cfcomponent>