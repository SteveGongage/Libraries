<!--- =========================================================================================================
	Created:		Steve Gongage (4/11/2013)
	Purpose:		Fuse system for an App Module

	Usage:			Included by AppModule.cfc

========================================================================================================= --->
<cfcomponent>
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	<!--- ================================================================================================ --->
	
	<cfset THIS.pathString 		= ''>
	<cfset THIS.path 			= []>
	<cfset VARIABLES.fuseVarName 	= "f">
	<cfset VARIABLES.fuses 			= {}>		<!--- Contains fuse structure --->
	<cfset VARIABLES.activeLevel	= 0>
	
	<!--- Constant Settings --->
	<cfset VARIABLES.pathDelimiter = "|">

	
	<!--- ================================================================================================ --->
	<!--- Functions --->
	<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Init method for this component
	------------------------------------------------------------------------------------->
	<cffunction name="init" access="public">
		<cfargument name="fuseVarName"			type="string" default="#VARIABLES.fuseVarName#">

		<cfset VARIABLES.activeLevel = 0>

		<!--- Setup Input --->
		<cfset THIS.input 	= setupInput()>

		<!--- Parse the Fuse Path --->
		<cfset THIS.pathString = ''>
		<cfif structKeyExists(THIS.input, ARGUMENTS.fuseVarName)>
			<cfset THIS.pathString = THIS.input[ARGUMENTS.fuseVarName]>
		</cfif>
		<cfset THIS.path = listToArray(THIS.pathString, VARIABLES.pathDelimiter)>

		<!--- Default Fuse --->
		<cfset VARIABLES.fuses 			= fuseNew()>
		<cfset VARIABLES.fuses.name 	= '_default'>
		<cfset VARIABLES.fuses.isLoaded	= true>
		<cfset VARIABLES.fuses.args 	= {}>

		<cfreturn this>
	</cffunction>


	

	<!-----------------------------------------------------------------------------------
		Go to the next level
	------------------------------------------------------------------------------------->
	<cffunction name="goNext" access="public">
		<cfset var activeFuse 	= fuseNew()>


		<cfif  VARIABLES.activeLevel LE arraylen(THIS.path)>
			<cfset activeFuse = getActiveFuse(VARIABLES.activeLevel)>

			<cfif NOT activeFuse.isLoaded>
				<cfoutput><p style="color: red;">Could not find #VARIABLES.activeLevel#</p></cfoutput>
			</cfif>
			<cfset VARIABLES.activeLevel++>
		</cfif>


		<cfset var fuseMod = new fuseModule(activeFuse, this)>
		<cfset fuseMod.go()>

	</cffunction>


	<!-----------------------------------------------------------------------------------
		Handles and throws errors
	------------------------------------------------------------------------------------->
	<cffunction name="handleError">
		<cfargument name="message" default="">
		<cfargument name="detail" default="">

		<cfthrow message="FuseSystem Error: #ARGUMENTS.message#" detail="#ARGUMENTS.detail#">

	</cffunction>

	<!-----------------------------------------------------------------------------------
		Include the template at the next level
	------------------------------------------------------------------------------------->
	<!---
	<cffunction name="include" access="public">
		<cfargument name="fuse" type="struct" required="true">

		<cfif ARGUMENTS.fuse.isLoaded AND ARGUMENTS.fuse.include IS NOT "">
			<cfinclude template="#ARGUMENTS.fuse.include#">
		</cfif>

	</cffunction>
	--->


	<!-----------------------------------------------------------------------------------
		Get Active Fuse
	------------------------------------------------------------------------------------->
	<cffunction name="lastFuse" access="public">
		<cfreturn getActiveFuse(arraylen(THIS.path))>
	</cffunction>
	<!-----------------------------------------------------------------------------------
		Get Active Fuse
	------------------------------------------------------------------------------------->
	<cffunction name="getActiveFuse" access="public">
		<cfargument name="level" type="numeric" default="1">

		<cfset var targetFuse 		= fuseNew()>
		<cfset var targetFusePath	= []>

		
		<cfif ARGUMENTS.level IS 0>
			<!--- If level is 0, then we always want the default --->
			<cfset targetFuse = getFuse('_default')>
		<cfelseif ARGUMENTS.level LE arraylen(THIS.path)>
			<cfloop from="1" to="#ARGUMENTS.level#" index="i">
				<cfset arrayAppend(targetFusePath, THIS.path[i])>
			</cfloop>
			<cfset targetFuse = getFuse(targetFusePath)>
		</cfif>

	
		<cfif NOT targetFuse.isLoaded AND ARGUMENTS.level IS 1>
			<!--- If level is 1 but we couldn't find the right one, then we always want the default --->
			<cfset targetFuse = getFuse('_default')>
		</cfif>
		
		<cfreturn targetFuse>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Add a Fuse to the Fusebox
	------------------------------------------------------------------------------------->
	<cffunction name="setFuse" access="public">
		<cfargument name="name" 	required="true" type="string" />
		<cfargument name="include"	required="true" type="string" />
		<cfargument name="args"		required="false" type="struct" default="#structnew()#" />

	
		<cfif trim(ARGUMENTS.name) IS NOT "">
			<cfset var targetPath		= getFusePathArray(ARGUMENTS.name)>
			<cfset var targetFuse 		= getFuse(targetPath)>
			<cfset targetFuse.name 		= listLast(ARGUMENTS.name, VARIABLES.pathDelimiter)>
			<cfset targetFuse.title 	= targetFuse.name>
			<cfset targetFuse.pathString= ARGUMENTS.name>
			<cfset targetFuse.include 	= ARGUMENTS.include>
			<cfset targetFuse.args 		= ARGUMENTS.args>
			<cfset targetFuse.path 		= targetPath>
			<cfset targetFuse.isLoaded	= true>

			<cfif structKeyExists(ARGUMENTS.args, 'title')>
				<cfset targetFuse.title = ARGUMENTS.args.title>
			</cfif>

			<!--- Stick the new fuse in the correct location in the path --->
			<cfset var parentPath = duplicate(targetFuse.path)>
			<cfset arrayDeleteAt(parentPath, arraylen(targetFuse.path))>
			<cfset var parentFuse = VARIABLES.fuses>
			<cfif arrayLen(parentPath) GT 0>
				<cfset parentFuse = getFuse(parentPath)>
			</cfif>
	
			<cfif parentFuse.isLoaded AND parentFuse.pathString IS NOT targetFuse.pathString>
				<cfset parentFuse.subFuses[targetFuse.name] = targetFuse>
			</cfif>

				
		</cfif>
			
	</cffunction>

	<!-----------------------------------------------------------------------------------
		Get a fuse given a path
	------------------------------------------------------------------------------------->
	<cffunction name="getFuse" access="public">
		<cfargument name="fusePathIn" 	required="true" type="any" />

		<cfset var fusePath 	= getFusePathArray(ARGUMENTS.fusePathIn)>
		<cfset var returnFuse 	= VARIABLES.fuses>

		<cfset var isFound		= false>

		<cfif arraylen(fusePath) GT 0>
			<cfset isFound 	= true>
			<cfif fusePath[1] IS "_default">
				<cfset returnFuse = VARIABLES.fuses>
			<cfelse>
				<cfloop array="#fusePath#" index="currFuseName">
					<cfif structKeyExists(returnFuse.subFuses, currFuseName)>
						<cfset returnFuse 	= returnFuse.subFuses[currFuseName]>
					<cfelse>
						<cfset returnFuse 	= fuseNew()>
						<cfset isFound 		= false>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			
		</cfif>
	
		<cfif NOT isFound>
			<cfset returnFuse = fuseNew()>
		</cfif>

		<cfreturn returnFuse>
	</cffunction>



	<!-----------------------------------------------------------------------------------
		Get fuse path array from string
	------------------------------------------------------------------------------------->
	<cffunction name="getFusePathArray" access="public">
		<cfargument name="fusePath" type="any">

		<cfset var returnPath = []>
		<cfif isSimpleValue(ARGUMENTS.fusePath)>
			<cfset returnPath = listToArray(ARGUMENTS.fusePath, VARIABLES.pathDelimiter)>
		<cfelseif isArray(ARGUMENTS.fusePath)>
			<cfset returnPath = ARGUMENTS.fusePath>
		</cfif>

		<cfreturn returnPath>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Return all fuses
	------------------------------------------------------------------------------------->
	<cffunction name="getAllFuses" access="public">
		<cfreturn VARIABLES.fuses>
	</cffunction>



	<!-----------------------------------------------------------------------------------
		Create a new Fuse record
	------------------------------------------------------------------------------------->
	<cffunction name="FuseNew" access="private">
		<cfreturn {
			name 	= '',
			title 	= '',
			include	= '',
			path 	= [],
			subFuses= {},
			isLoaded= false,
			args 	= {}
		}>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		Get a structure of values given a list of scopes of increasing precident
		@listOfScopes.description		"List of scopes ordered by increasing precident (later scopes will overwrite earlier ones)"
	------------------------------------------------------------------------------------->
	<cffunction name="setupInput" access="private">
		<cfargument name="listOfScopes" type="string" default="URL,FORM">
		<cfset var input = structNew() />
		<cfset var elem = ''>
		
		<cfloop list="#ARGUMENTS.listOfScopes#" index="elem">
			<cfif isDefined('#elem#')>
				<cfset structAppend(input, evaluate('#elem#'), true) />
			</cfif>
		</cfloop>

		<cfreturn input>
	</cffunction>


</cfcomponent>