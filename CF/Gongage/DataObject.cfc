<cfcomponent name="BaseComponent">
	
	<cfset this.objectType				= "BaseComponent">
	
	<cfset variables.data 				= structnew()>
	<cfset variables.dataList 			= queryNew('default')>
	<cfset variables.dbTable 			= ''>
	<cfset variables.defaultData 		= structnew()>
	<cfset variables.isLoaded			= false>
	<cfset variables.hasData 			= false>
	
	
	<!--- Getters ---------------------------------------------------------------------------------->
	<cffunction name="has" returntype="any" output="false">
		<cfargument name="key" required="yes" type="string">
		<cfreturn (get(key) IS NOT "undefined")>
	</cffunction>

	<cffunction name="isNotEmpty" returntype="boolean" output="false">
		<cfargument name="key" required="yes" type="string">
		<cfset var tempValue = get(arguments.key)>
		<cfreturn (isSimpleValue(tempValue) AND tempValue IS NOT "undefined" AND tempValue IS NOT "" AND tempValue IS NOT 0)>
	</cffunction>
	<cffunction name="isEmpty" returntype="boolean">
		<cfargument name="key" required="yes" type="string">
		<cfreturn NOT isNotEmpty(arguments.key)>
	</cffunction>
		
	<cffunction name="isNotBlank" returntype="boolean" output="false">
		<cfargument name="key" required="yes" type="string">
		<cfset var tempValue = get(arguments.key)>
		<cfreturn (isSimpleValue(tempValue) AND tempValue IS NOT "undefined" AND tempValue IS NOT "")>
	</cffunction>
	<cffunction name="isBlank" returntype="boolean">
		<cfargument name="key" required="yes" type="string">
		<cfreturn NOT isNotBlank(arguments.key)>
	</cffunction>
		
	
		
	<cffunction name="get" returntype="any" output="false">
		<cfargument name="key" required="yes" type="string">

		<cfif isStruct(variables.data)>
			<cfif structKeyExists(variables.data, key)>
				<cfreturn variables.data[key]>
			<cfelse>
				<cfreturn 'undefined'>
			</cfif>
		<cfelseif isArray(variables.data)>
			<cfif isNumeric(key) AND key LE arrayLen(variables.data)>
				<cfreturn variables.data[key]>
			<cfelse>
				<cfreturn 'out of bounds'>
			</cfif>
		</cfif>
		
		<cfreturn 'undefined'>
	</cffunction>

	<cffunction name="getData" returntype="any" output="false">
		<cfreturn variables.data>
	</cffunction>


	
	<!--- Setters ---------------------------------------------------------------------------------->
	
	<cffunction name="load" returnType="any" output="true">
		<cfargument name="newValue" required="true">

		<cfset var loadResults = resultNew('false')>
		
		<!--- Set Data First --->
		<cfset setData(newValue)>
		
		<!--- Load Dependents : These are overridable for objects that inherit this --->
		<cfset loadResults = loadDependents(getData())>
		
		
		<!--- Check for Success! --->
		<cfif loadResults.success>
			<cfset variables.isLoaded = true>
		</cfif>

		<cfreturn loadResults>
	</cffunction>
	
	
	
	<cffunction name="set" returntype="void" output="false">
		<cfargument name="key">
		<cfargument name="value">
		
		<cfset variables.hasData = true>

		<cfset variables.data[key] = value>
	</cffunction>
	
	
	<cffunction name="setData" returntype="void" output="false">
		<cfargument name="newValue" required="true">
		<cfargument name="rowNum" default="0">

		<cfset variables.hasData = false>
		
		<cfset variables.data = prepareDataForStorage(newValue)>
		
		<cfif isStruct(variables.data) AND listLen(structKeyList(variables.data)) GT 0>
			<cfset variables.hasData = true>
		<cfelseif isSimpleValue(variables.data) AND variables.data IS NOT "">
			<cfset variables.hasData = true>
		</cfif>
		
		
		<cfif isQuery(arguments.newValue)>
			<cfset variables.dataList = arguments.newValue>
		<cfelse>
			<cfset variables.dataList = queryNew('default')>
		</cfif>
	</cffunction>


	<cffunction name="setDataSet" returntype="any" output="false">
		<cfargument name="newValue" default="" required="false">
		<cfargument name="label"	default="" required="false">

		<cfset var newData = prepareDataForStorage(newValue)>
		
		<cfif label IS NOT "">
			<cfset variables.data[label] = newData>
		</cfif>
		
		<cfset loadResults = resultNew(true)>
	</cffunction>
	

	
	
	<cffunction name="prepareDataForStorage">
		<cfargument name="newValue" required="yes">
		<cfargument name="rowNum" 	default="0">
		<cfset var newData = "">
		
		
		
		<cfif isQuery(newValue)>
			<!--- QUERY -------------------->
			<cfset newData = newValue>


			<cfif newValue.recordcount LE 1>
				<!--- With 0 or 1 result in query, just return a struct --->
				<cfset newData = request.utilities.data.QueryRowToStruct(newValue)>
			<cfelseif newValue.recordcount GT 1>
				<!--- With multiple results in the query --->
				<cfif arguments.rowNum GT 0>
					<cfset newData = request.utilities.data.QueryRowToStruct(newValue, rowNum)>
				<cfelse>
					<cfset newData = newValue>
				</cfif>
			</cfif>

		<cfelseif isStruct(newData)>
			<!--- Structs  ---------->
			<cfset newData = newValue>
		
		<cfelse>
			<!--- EVERYTHING ELSE ---------->
			<cfset newData = newValue>
		</cfif>
		
		<cfreturn newData>
	</cffunction>
	
	<!--- Other ---------------------------------------------------------------------------------->


	<cffunction name="resultNew" output="false">
		<cfargument name="success" 	required="true" 		type="boolean">
		<cfargument name="message" 	default="" 				required="false" type="string">
		<cfargument name="data" 	default="#getData()#" 	required="false" type="any">
		
		<cfset var initResult = createObject('component', 'Results.Result')>
		<cfset initResult.load(arguments.success, arguments.message, arguments.data)>
		
		<cfreturn initResult>
	</cffunction>

	
	<cffunction name="isLoaded"	returntype="boolean" output="false">
		<cfreturn variables.isLoaded>	
	</cffunction>
	
	<cffunction name="hasData"	returntype="boolean" output="true">
		<cfset var usefulDataFound = false>
		
		<cfloop collection="#variables.data#" item="currItem">
			<cfif NOT isSimpleValue(variables.data[currItem]) >				
				<cfset usefulDataFound = true>
			<cfelseif variables.data[currItem] IS NOT "" AND variables.data[currItem] IS NOT 0>
				<cfset usefulDataFound = true>
			</cfif>
		</cfloop>
		<cfreturn usefulDataFound>	
	</cffunction>
	
	<cffunction name="init">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="loadDependents" returntype="any" output="false">
		<cfreturn resultNew(true)>
	</cffunction>
	
</cfcomponent>
			


