<!--- =========================================================================================================
	Created:		Steve Gongage (07/04/2013)
	Purpose:		

	Usage:			

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->

	
	<cfset this.name 			= "">
	<cfset this.items 			= []>

	<cfset variables.isLoaded 	= false>
	<cfset variables.filePath 	= "">


<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="filePath" 		type="string" required="false" default="">
		<cfargument name="options"			type="struct"	required="false" default="#structnew()#">

		<cfset structAppend(arguments.options, {
			createIfMissing = false
		}, false)>

		<cfset variables.filePath 	= arguments.filePath>
		<cfset variables.isLoaded 	= false>
		<cfset this.name 			= "">  
		<cfset this.items 			= []>


		<cfif variables.filePath IS NOT "">

			<cfif NOT fileExists(variables.filePath) AND arguments.options.createIfMissing>
				<!--- If the data file does not exist --->
				<cfset this.name = replacenocase(listLast(listFirst(dirList.name, "."), "\"), "collection_", "")>
				<cfset this.save()>
			</cfif>			


			<cffile action="read" file="#variables.filePath#" variable="fileContent">

			
			<cfif trim(fileContent) IS NOT "" AND isJSON(fileContent)>
				<cfset fileJSON 			= deserializeJSON(fileContent)>
				<cfset this.name 			= fileJSON.name>
				<cfloop array="#fileJSON.items#" index="currItemData">
					<cfset newItem = new Item(currItemData, true)>
					<cfif newItem.isLoaded()>			
						<cfset arrayAppend(this.items, newItem)>
					</cfif>
				</cfloop>
				<cfset variables.isLoaded 	= true>
			</cfif>
		
		</cfif>
	


		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Find
	------------------------------------------------------------------------------------->
	<cffunction name="Find" access="public">
		<cfargument name="filters" type="struct" default="#structnew()#">

		<cfset var returnSet 	= []>
		<cfset var isIncluded 	= false>
		<cfset var currItem 	= ''>

		<cfif listLen(structKeyList(arguments.filters)) IS 0>
			<!--- If no filters, return everything --->
			<cfset returnSet = this.items>
		<cfelse>
			<!--- Have each item check if it matches the filters --->
			<cfloop array="#this.items#" index="currItem">
				<cfset isIncluded = currItem.isMatch(filters)>

				<cfif isIncluded>
					<cfset arrayAppend(returnSet, currItem)>
				</cfif>
			</cfloop>
		</cfif>

		


		<cfreturn returnSet>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		FindOne
	------------------------------------------------------------------------------------->
	<cffunction name="FindOne" access="public">
		<cfargument name="filters" type="struct" default="{}">

		
		<cfset var foundItems = this.find(arguments.filters)>

		<cfset var returnItem = {}>

		<cfif arraylen(foundItems) GT 0>
			<cfset returnItem = foundItems[1]>
		</cfif>


		
		<cfreturn returnItem>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Insert
	------------------------------------------------------------------------------------->
	<cffunction name="insert" access="public">
		<cfargument name="itemData" type="struct" required="true">

		<cfset var newItem = new Item(arguments.itemData)>

		<!--- Make sure we are not inserting something with an identical _ID --->
		<cfset var lookupSameKey = this.find({'_ID' = newItem.get('_ID')})>

		<cfif arraylen(lookupSameKey) GT 0>
			<cfthrow message="Cannot insert this item into collection #ucase(this.name)#" detail="An item in collection #ucase(this.name)# has the identical ID '#newItem.get('_ID')#'">
		</cfif>

		<cfset arrayAppend(this.items, newItem)>


		<cfreturn newItem>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Save
	------------------------------------------------------------------------------------->
	<cffunction name="save" access="public">

		<cfset var dataToSave = {
			name 	= this.name
			, items = []
		}>

		<cfloop array="#this.items#" index="currItem">
			<cfset currItem.isSynced = true>
			<cfset arrayAppend(dataToSave.items, currItem.data)>
		</cfloop>

		<cfset var fileContent = serializeJSON(dataToSave)>

		<cffile action="write" file="#variables.filePath#" output="#fileContent#">
	</cffunction>

	<!-----------------------------------------------------------------------------------
		IsLoaded
	------------------------------------------------------------------------------------->
	<cffunction name="isLoaded" access="public">
		<cfreturn variables.isLoaded>
	</cffunction>


</cfcomponent>