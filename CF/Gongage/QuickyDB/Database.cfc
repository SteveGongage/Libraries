<!--- =========================================================================================================
	Created:		Steve Gongage (07/04/2013)
	Purpose:		Main database component.  Start with this.

	Usage:			<cfset myDB = new cf.Gongage.JSONDB.Database()>

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->

	<cfset variables.path 		= "">

	<cfset this.collections 	= {}>


<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="Path" type="string" required="true">

		<cfset variables.path 		= arguments.path>
		<cfset this.collections 	= {}>

		<cfif NOT directoryExists(variables.path)>
			<cfthrow message="Could not find directory '#variables.path#'">
		</cfif>

		<!--- Look for directories.  These will be the collections --->
		<cfdirectory action="list" directory="#variables.path#" name="dirList" type="file" filter="collection_*.js">

		<cfloop query="#dirList#">
			<cfset newCol = new Collection("#variables.path#\#dirList.name#")>

			<cfif newCol.isLoaded()>
				<cfset this.collections[newCol.name] = newCol>
			</cfif>


		</cfloop>

		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Collection
	------------------------------------------------------------------------------------->
	<cffunction name="collection" access="public">
		<cfargument name="name" 			type="string" 	required="true">
		<cfargument name="options"			type="struct"	required="false" default="#structnew()#">
		<cfset structAppend(arguments.options, {
			createIfMissing = false
		}, false)>

		<cfset var col = ''>


		<cfif structKeyExists(this.collections, arguments.name)>
			<cfset col = this.collections[arguments.name]>
		<cfelseif arguments.options.createIfMissing>
			<cfset col = newCollection("#variables.path#\#arguments.name#", {createIfMissing = true})>
			<cfset this.collections[arguments.name] = col>
		<cfelse>
			<cfthrow message="Cannot find collection #ucase(arguments.name)#" detail="To create this collection, call database.collection('#arguments.name#', {createIfMissing = true})">
		</cfif>

		<cfreturn col>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Save
	------------------------------------------------------------------------------------->
	<cffunction name="save" access="public">

		<cfloop collection="#this.collections#" item="currCollectionName">
			<cfset this.collections[currCollectionName].save()>
		</cfloop>

	</cffunction>

</cfcomponent>