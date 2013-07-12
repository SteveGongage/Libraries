<!--- =========================================================================================================
	Created:		Steve Gongage (07/04/2013)
	Purpose:		Single data item

	Usage:			

========================================================================================================= --->
<cfcomponent>

<!--- ================================================================================================ --->
<!--- Properties --->
<!--- ================================================================================================ --->


	<cfset variables.isloaded 	= false>
	<cfset this.data 			= {}>
	<cfset this.isSynced 		= true>

	<cfset variables.defaultUndefinedValue = "">

<!--- ================================================================================================ --->
<!--- Functions --->
<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="data" 	type="struct" 	required="true">
		<cfargument name="isSynced"	type="boolean" 	default="false">

		<cfset this.data._ID 			= createUUID()>
		<cfset this.data._dateUpdated	= now()>
		<cfset this.isSynced 			= arguments.isSynced>

		<cfloop collection="#arguments.data#" item="currKey">
			<cfset this.data[currKey] = arguments.data[currKey]>
		</cfloop>
		

		<cfset variables.isLoaded = true>

		
		<cfreturn THIS>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		IsLoaded
	------------------------------------------------------------------------------------->
	<cffunction name="isLoaded" access="public">
		<cfreturn variables.isLoaded>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Get
	------------------------------------------------------------------------------------->
	<cffunction name="get" access="public">
		<cfargument name="key" type="string" required="true">
		<cfargument name="defaultUndefinedValue" type="string" required="false" default="#variables.defaultUndefinedValue#">

		<cfif structKeyExists(this.data, arguments.key)>
			<cfreturn this.data[arguments.key]>
		<cfelse>
			<cfreturn arguments.defaultUndefinedValue>
		</cfif>
		<cfreturn variables.isLoaded>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		isMatch
	------------------------------------------------------------------------------------->
	<cffunction name="isMatch" access="public">
		<cfargument name="filters" type="struct" default="{}">

		<cfset var filterKeys = structKeyList(arguments.filters)>
		<cfset var isMatch = false>

		<cfloop list="#filterKeys#" index="currFilterKey">
			<cfset currFilter = {
				type 		= "match"
				, key 		= currFilterKey
				, value 	= arguments.filters[currFilterKey]
				, isMatch 	= false
			}>



			<cfif structKeyExists(this.data, currFilter.key)>
				<cfswitch expression="#currFilter.type#">
					<cfcase value="match">
						<cfset currFilter.isMatch = this.data[currFilter.key] IS currFilter.value>
					</cfcase>
				</cfswitch>
			</cfif>

			<cfif currFilter.isMatch>
				<cfset isMatch = true>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn isMatch>
	</cffunction>


</cfcomponent>