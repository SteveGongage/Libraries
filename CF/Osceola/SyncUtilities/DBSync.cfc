
<cfcomponent>
	
	
	<!--- ================================================================================================================== --->
	<cffunction name="init">
		<cfargument name="datasource" 		required="yes">
		<cfargument name="tableName" 		required="yes">
		<cfargument name="identityColumns"	required="no" type="array" default="#arraynew(1)#">


		<cfset this.datasource				= arguments.datasource>
		<cfset this.tableName				= arguments.tableName>
		<cfset this.columnMap				= structnew()>
		<cfset this.columnMapDefault_source	= structnew()>
		<cfset this.columnMapDefault_target	= structnew()>
		<cfset this.activityLog				= arraynew(1)>
		<cfset this.counts					= structnew()>
		<cfset this.counts.inserted			= 0>
		<cfset this.counts.updated			= 0>
		<cfset this.counts.deleted			= 0>
		<cfset this.counts.errors			= 0>
		<cfset this.counts.noAction			= 0>
		<cfset this.counts.total			= 0>
		<cfset this.hasIdentity				= false>
		<cfset this.hadDBIdentity			= false>
		
		
		<cfstoredproc procedure="sp_columns" datasource="#this.datasource#">
			<cfprocparam type="in" variable="table_name" value="#this.tableName#" cfsqltype="cf_sql_varchar">
			<cfprocresult name="getColumnInfo">
		</cfstoredproc>
		
		<cfset this.tableInfo = structnew()>
		<cfset this.tableInfo.identities = arraynew(1)>

		<!--- Get Identity Information --->
		<cfset var columnMap = structnew()>
		<cfloop query="getColumnInfo">
			<cfset newItem = structnew()>
			<cfset newItem['nameSource']	= getColumnInfo.column_name>
			<cfset newItem['nameTarget']	= getColumnInfo.column_name>
			<cfset newItem['typeName'] 		= getColumnInfo.type_name>
			<cfset newItem['nullable'] 		= getColumnInfo.nullable>
			<cfset newItem['lengthBytes'] 	= getColumnInfo.length>
			<cfset newItem['lenghtChars'] 	= getColumnInfo.char_octet_length>
			<cfset newItem['isDBIdentity']	= false>
			<cfset newItem['cfQueryParamType'] = "cf_sql_int">
			
			<!--- Identity --->
			<cfset newItem['isIdentity'] 		= false>
			<cfif newItem['typeName'] CONTAINS "identity">
				<!--- If specified in the DB --->
				<cfset newItem['isIdentity'] 	= true>
				<cfset newItem['isDBIdentity']	= true>
				<cfset this.hasIdentity			= true>
				<cfset this.hadDBIdentity		= true>
				
				<cfset arrayAppend(this.tableInfo.identities, getColumnInfo.column_name)>
			<cfelseif arrayfindNoCase(arguments.identityColumns, getColumnInfo.column_name)>
				<!--- If it is manually specified --->
				<cfset newItem['isIdentity'] 	= true>
				<cfset newItem['isDBIdentity']	= false>
				<cfset this.hasIdentity			= true>
				
				<cfset arrayAppend(this.tableInfo.identities, getColumnInfo.column_name)>
			</cfif>
			
			
			<cfset newItem.typeName 		= trim(replace(newItem.typeName, 'identity', '', 'all'))>
			
			<!--- CFSQLType --->
			<cfif newItem.typeName IS "bit">
				<cfset newItem['cfQueryParamType'] = "cf_sql_bit">
			<cfelseif newItem.typeName IS "datetime">
				<cfset newItem['cfQueryParamType'] = "cf_sql_timestamp">
			<cfelseif newItem.typeName IS NOT "int">
				<cfset newItem['cfQueryParamType'] = "cf_sql_varchar">
			</cfif>
			
			
			<!--- default --->
			<cfset newItem['default'] 		= getColumnInfo.column_def>
			<cfif newItem.typeName CONTAINS "int" AND newItem.default IS NOT "">
				<cfif len(newItem.default) GE 5 AND newItem.default CONTAINS "((" AND newItem.default CONTAINS "))">
					<cfset newItem.default = mid(newItem.default, 3, len(newItem.default) - 4)>
				</cfif>
			</cfif>


			
			<cfset this.columnMap.source[newItem.nameSource] = newItem>
			<cfset this.columnMap.target[newItem.nameSource] = newItem>
			
		</cfloop>
		
		<cfset this.columnMap.sourceDefault	= duplicate(this.columnMap.source)>
		<cfset this.columnMap.targetDefault	= duplicate(this.columnMap.target)>

		
	</cffunction>
	
	
	<!--- ================================================================================================================== --->
	<!---
	<cffunction name="mapAllColumns">
		<cfargument name="mapIn" type="struct" required="yes">
		
		<cfset this.columnMap = duplicate(this.columnMapDefault_source)>
		<cfset var columnNames = structKeyList(this.columnMap)>
		
		
		
		<cfloop list="#columnNames#" index="currTargetKey">
			<cfif structKeyExists(arguments.mapIn, currTargetKey)>
				<cfset this.columnMap[currTargetKey].nameSource = arguments.mapIn[currTargetKey]>
			<cfelse>
				<cfset structDelete(this.columnMap, currTargetKey)>
			</cfif>
		</cfloop>
		
		
		<cfdump var="#this.columnMap#"><cfabort>
		
	</cffunction>
	--->
	
	
	
	<!--- ================================================================================================================== --->
	<cffunction name="changeSourceMap">
		<cfargument name="nameSource" type="string" required="yes">
		<cfargument name="nameTarget" type="string" required="yes">
		
		<cfif structKeyExists(this.columnMap.target, arguments.nameTarget)>
			<cfset var mapDef = this.columnMap.target[arguments.nameTarget]>
			
			<!--- Delete old def from Source --->
			<cfset structDelete(this.columnMap.source, mapDef.nameSource)>


			<!--- Update Mappings --->
			<cfset mapDef.nameSource = arguments.nameSource>
			<cfset this.columnMap.target[arguments.nameTarget] = mapDef>
			<cfset this.columnMap.source[arguments.nameSource] = mapDef>
		</cfif>
		
		
	</cffunction>
	
	
	<!--- ================================================================================================================== --->
	<cffunction name="sync">
		<cfargument name="method" 		required="yes"	type="string">		<!--- Mirror (delete all then copy), Contribute (add new, save edits, ignore delete) --->
		<cfargument name="dataIn" 		required="yes" 	type="query">
		<cfargument name="idColumns"	required="no"	type="array">
		
		<cfset formattedData = dataIntersect(arguments.dataIn)>
		
		<cfif 		arguments.method IS "mirror">
			<cfset sync_mirror(formattedData)>
		<cfelseif	arguments.method IS "insert">
			<cfset sync_insert(formattedData)>
		<cfelseif	arguments.method IS "full">
			<cfset sync_full(formattedData)>
		</cfif>

	</cffunction>



	<!--- ================================================================================================================== --->
	<!--- USEFUL for Debugging! --->
	<cffunction name="showInputMapping">
		<cfargument name="dataIn" required="yes">
		
		
		<cfset var dataInColumns 			= listToArray(arguments.dataIn.columnList)>
		<cfset var columnsNotFound.dataIn 	= "">
		<cfset var columnsNotFound.target 	= listSort(structKeyList(this.columnMap.target), 'textNoCase')>
		<cfset var columnsNotFound.source 	= listSort(structKeyList(this.columnMap.source), 'textNoCase')>

		<cfloop query="arguments.dataIn">
			
			<cfloop array="#dataInColumns#" index="currDataInColumn">
				<cfif structKeyExists(this.columnMap.source, currDataInColumn)>
					<!--- DataInColumn found in Source Map --->
					<cfset currMapping = this.columnMap.source[currDataInColumn]>
					
					<cfif listFindNoCase(columnsNotFound.target, currMapping.nameTarget)>
						<!--- Remove column from target columns not found --->
						<cfset columnsNotFound.target = listDeleteAt(columnsNotFound.target, listFindNoCase(columnsNotFound.target, currMapping.nameTarget))>
					</cfif>
					<cfif listFindNoCase(columnsNotFound.source, currMapping.nameSource)>
						<!--- Remove column from target columns not found --->
						<cfset columnsNotFound.source = listDeleteAt(columnsNotFound.source, listFindNoCase(columnsNotFound.source, currMapping.nameSource))>
					</cfif>
					
					
				<cfelseif NOT listFindNoCase(columnsNotFound.dataIn, currDataInColumn)>
					<!--- Add column to source columns not found --->
					<cfset columnsNotFound.dataIn = listAppend(columnsNotFound.dataIn, currDataInColumn)>
				</cfif>
				
			</cfloop>
			
		</cfloop>
		
		
		
		<cfoutput>
			<table border="1" cellpadding="4" cellspacing="0" style="border-collapse: collapse;">
				<tr>
					<th>Source Data</th>
					<th>Target Mapping</th>
					<th>Sample Value</th>
				</tr>
				<cfloop list="#columnsNotFound.target#" index="currTargetColumn">
					<tr style="background-color: ##FFE;">
						<td>&nbsp;</td>
						<td style="color: red; font-weight: bold;">#currTargetColumn#</td>
						<td></td>
					</tr>
				</cfloop>
				
				<cfloop list="#arguments.dataIn.columnList#" index="currDataInColumn">
					<cfif structKeyExists(this.columnMap.source, currDataInColumn)>
						<cfset currMapping = this.columnMap.source[currDataInColumn]>
						<tr style="background-color: ##DDD; color: ##666">
							<td>#currDataInColumn#</td>
							<td>#currMapping.nameTarget#</td>							
							<td>#arguments.dataIn[currDataInColumn][1]#</td>
						</tr>
					<cfelse>
						<tr style="background-color: ##FFE;">
							<td style="color: red; font-weight: bold;">#currDataInColumn#</td>
							<td>&nbsp;</td>
							<td style="color: red;">#arguments.dataIn[currDataInColumn][1]#</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfoutput>
		
		
		
		
	</cffunction>

	
	<!--- ================================================================================================================== --->
	<cffunction name="dataIntersect">
		<cfargument name="dataIn" required="yes">
		
		<cfset var returnData = querynew(structKeyList(this.columnMap.target))>
		
		<cfset var dataInColumns 			= listToArray(arguments.dataIn.columnList)>

		<cfloop query="arguments.dataIn">
			<cfset queryAddRow(returnData)>
			
			
			<cfloop array="#dataInColumns#" index="currDataInColumn">
				<cfif structKeyExists(this.columnMap.source, currDataInColumn)>
					<!--- DataInColumn found in Source Map --->
					<cfset currMapping = this.columnMap.source[currDataInColumn]>
					
					
					<!--- Add data to returnData cell --->
					<cfset querySetCell(returnData, currMapping.nameTarget, arguments.dataIn[currMapping.nameSource][currentRow])>
				</cfif>
				
			</cfloop>
			
		</cfloop>
		
	
		<cfreturn returnData>
	</cffunction>
	
		
	
	<!--- ================================================================================================================== --->
	<cffunction name="sync_mirror" description="delete everything then fill up the table with the incoming data.">
		<cfargument name="dataIn" 		required="yes" 	type="query">
		
		<cfset var columnList	= arguments.dataIn.columnList>
		<cfset var columnSQL	= "">
		<cfset var valueSQL		= "">
		<cfset var currColumn	= "">
		<cfset var currStatement = "">
		<cfset var updateFailed = false>
		
		<cfset addLog('Mirroring operation started for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
		<!--- Loop over incoming data and create SQL for it --->
		<cfset var SQLStatements = arraynew(1)>
		<cfloop query="arguments.dataIn">
			<cfset arrayAppend(SQLStatements, createInsertSQL(request.utilities.data.queryRowToStruct(arguments.dataIn, arguments.dataIn.currentRow)))>
		</cfloop>
		
		
		<cftransaction action="begin">
			<!--- Delete Existing Data --->
			<cfquery name="clearExistingData" datasource="#this.datasource#">
				DELETE FROM #this.tableName#
			</cfquery>
			
			<cfloop array="#SQLStatements#" index="currStatement">
				<cftry>
					<cfset this.counts.total++>
					
					<cfquery name="InsertRecord" datasource="#this.datasource#">
						#preserveSingleQuotes(currStatement)#
					</cfquery>
					
					<cfcatch type="any">
						<cfset updateFailed = true>
						<cfset addLog('Error adding record number #this.counts.total# - #cfcatch.Message#: #cfcatch.Detail#', 'error')>
						
						<cfoutput>
							<strong>#cfcatch.Message#</strong><br />
							#cfcatch.Detail#<br />
							<textarea style="width: 100%; height: 200px;">#currStatement#</textarea>
							
							<cfdump var="#request.utilities.data.queryRowToStruct(arguments.dataIn, this.counts.total)#">
						</cfoutput>
						<cfabort>
					</cfcatch>
				</cftry>
				
				<cfif NOT updateFailed>
					<cfset this.counts.inserted++>
				</cfif>
				
			</cfloop>
			
			
			<cfif updateFailed>
				<cftransaction action="rollback">
			</cfif>
				
			<cftransaction action="commit">
		</cftransaction>

		<cfset addLog('Total records looped over: #this.counts.total#', 'info')>
		<cfset addLog('Total records inserted: #this.counts.inserted#', 'info')>
		<cfset addLog('Total records updated: #this.counts.updated#', 'info')>
		<cfset addLog('Total records deleted: #this.counts.deleted#', 'info')>
		<cfset addLog('Total records no action: #this.counts.noAction#', 'info')>
		<cfset addLog('Mirroring operation ended for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
		
	</cffunction>

	<!--- ============================================================================================ --->
	<cffunction name="sync_full" description="Uses updates, inserts, and deletes to mirror the new data, but only for the columns provided.  Allows us to sync but not overwrite data in some columns and is faster than other syncs.  ">
		<cfargument name="dataIn" 		required="yes" 	type="query">
		
		<cfset var columnList	= arguments.dataIn.columnList>
		<cfset var columnSQL	= "">
		<cfset var valueSQL		= "">
		<cfset var currColumn	= "">
		<cfset var currStatement = "">
		<cfset var updateFailed = false>
		
		<cfset addLog('Full sync operation started for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
		<cfif arraylen(this.tableInfo.identities) IS 0>
			<cfthrow message="DBSync.Sync_Full cannot run without identity columns specified.">
		</cfif>
		
		<!---
		<cfset identities.insert = structnew()>
		<cfset identities.update = structnew()>
		--->
		<cfset var identities = structnew()>
		<cfset identities.all	 = structnew()>
		<cfloop array="#this.tableInfo.identities#" index="currIdentity">
			<!---
			<cfset identities.insert[currIdentity] 	= arraynew(1)>
			<cfset identities.update[currIdentity] 	= arraynew(1)>
			--->
			<cfset identities.all[currIdentity] 	= arraynew(1)>
		</cfloop>
		
		
		
		<cftransaction action="begin">
			<!--- Loop over incoming data and create SQL for it --->
			<cfset var SQLStatements = arraynew(1)>
			
			

			<!--- Insert or Update --->
			<cfloop query="arguments.dataIn">
					<cfquery name="lookupInfo" datasource="#this.datasource#">
						SELECT * FROM #this.tableName# WHERE 1 = 1
							<cfloop array="#this.tableInfo.identities#" index="currIdentity">
								AND #currIdentity# = <cfqueryparam value="#dataIn[currIdentity][dataIn.currentRow]#" cfsqltype="#this.columnMap.target[currIdentity].cfQueryParamType#">
							</cfloop>
					</cfquery>
				
								
				<cfset action = "skip">
				<cfif lookupInfo.recordcount IS 1>
					<!--- If the two structs are not similar --->
					<cfif NOT request.utilities.data.compareStructs(request.utilities.data.queryRowToStruct(lookupInfo), request.utilities.data.queryRowToStruct(dataIn, dataIn.currentRow))>
						<cfset action = "update">
					</cfif>
				<cfelseif lookupInfo.recordcount IS 0>
					<cfset action = "insert">
				</cfif>
				
				<cfloop array="#this.tableInfo.identities#" index="currIdentity">
					<!--- <cfset arrayAppend(identities[action][currIdentity], dataIn[currIdentity][dataIn.currentRow])> --->
					<cfif dataIn[currIdentity][dataIn.currentRow] IS NOT "">
						<cfset arrayAppend(identities['all'][currIdentity], dataIn[currIdentity][dataIn.currentRow])>
					</cfif>
				</cfloop>
				
				<cfif action IS "update">
					<cfset arrayAppend(SQLStatements, createUpdateSQL(request.utilities.data.queryRowToStruct(arguments.dataIn, arguments.dataIn.currentRow)))>
					<cfset this.counts.updated++>
				<cfelseif action IS "insert">
					<cfset arrayAppend(SQLStatements, createInsertSQL(request.utilities.data.queryRowToStruct(arguments.dataIn, arguments.dataIn.currentRow)))>
					<cfset this.counts.inserted++>
				<cfelseif action IS "skip">
					<cfset this.counts.noAction++>
				</cfif>
				
				
			</cfloop>
			


			<!--- Delete Missing Data --->
			<cfquery name="numberToDelete" datasource="#this.datasource#">
				SELECT count(*) AS totalFound FROM #this.tableName# WHERE 1 = 1
					<cfloop array="#this.tableInfo.identities#" index="currIdentity">
						AND #currIdentity# NOT IN (<cfqueryparam value="#arrayToList(identities['all'][currIdentity])#" list="yes" cfsqltype="#this.columnMap.target[currIdentity].cfQueryParamType#">)
					</cfloop>
			</cfquery>
			<cfset this.counts.deleted = numberToDelete.totalFound>
			
			<cfquery name="clearExistingData" datasource="#this.datasource#">
				DELETE FROM #this.tableName# WHERE 1 = 1
					<cfloop array="#this.tableInfo.identities#" index="currIdentity">
						AND #currIdentity# NOT IN (<cfqueryparam value="#arrayToList(identities['all'][currIdentity])#" list="yes" cfsqltype="#this.columnMap.target[currIdentity].cfQueryParamType#">)
					</cfloop>
			</cfquery>
			
			
			<cfloop array="#SQLStatements#" index="currStatement">
				<cftry>
					<cfset this.counts.total++>
					
					<cfquery name="InsertRecord" datasource="#this.datasource#">
						#preserveSingleQuotes(currStatement)#
					</cfquery>
					
					<cfcatch type="any">
						<cfset updateFailed = true>
						<cfset addLog('Error adding record number #this.counts.total# - #cfcatch.Message#: #cfcatch.Detail#', 'error')>
						
						<cfoutput>
							<strong>#cfcatch.Message#</strong><br />
							#cfcatch.Detail#<br />
							<textarea style="width: 100%; height: 200px;">#currStatement#</textarea>
							
							<cfdump var="#request.utilities.data.queryRowToStruct(arguments.dataIn, this.counts.total)#">
						</cfoutput>
						<cfabort>
					</cfcatch>
				</cftry>
				
				<cfif NOT updateFailed>
				</cfif>
				
			</cfloop>
			
			
			<cfif updateFailed>
				<cftransaction action="rollback">
			</cfif>
				
			<cftransaction action="commit">
		</cftransaction>

		<cfset addLog('Total records looped over: #this.counts.total#', 'info')>
		<cfset addLog('Total records inserted: #this.counts.inserted#', 'info')>
		<cfset addLog('Total records updated: #this.counts.updated#', 'info')>
		<cfset addLog('Total records deleted: #this.counts.deleted#', 'info')>
		<cfset addLog('Total records no action: #this.counts.noAction#', 'info')>
		<cfset addLog('Full Sync operation ended for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
	</cffunction>

	<!--- ================================================================================================================== --->
	<cffunction name="sync_insert">
		<cfargument name="dataIn" 		required="yes" 	type="query">
		
		<cfset var columnList	= arguments.dataIn.columnList>
		<cfset var columnSQL	= "">
		<cfset var valueSQL		= "">
		<cfset var currColumn	= "">
		<cfset var currStatement = "">
		<cfset var updateFailed = false>
		
		<cfset addLog('Insert operation started for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
		<!--- Loop over incoming data and create SQL for it --->
		<cfset var SQLStatements = arraynew(1)>
		<cfloop query="arguments.dataIn">
			<cfset arrayAppend(SQLStatements, createInsertSQL(request.utilities.data.queryRowToStruct(arguments.dataIn, arguments.dataIn.currentRow)))>
		</cfloop>
		
		
		<cftransaction action="begin">
			<cfloop array="#SQLStatements#" index="currStatement">
				<cftry>
					<cfset this.counts.total++>
					
					<cfquery name="InsertRecord" datasource="#this.datasource#">
						#preserveSingleQuotes(currStatement)#
					</cfquery>
					
					<cfcatch type="any">
						<cfset updateFailed = true>
						<cfset addLog('Error adding record number #this.counts.total# - #cfcatch.Message#: #cfcatch.Detail#', 'error')>
						
						<cfoutput>
							<strong>#cfcatch.Message#</strong><br />
							#cfcatch.Detail#<br />
							<textarea style="width: 100%; height: 200px;">#currStatement#</textarea>
							
							<cfdump var="#request.utilities.data.queryRowToStruct(arguments.dataIn, this.counts.total)#">
						</cfoutput>
						<cfabort>
					</cfcatch>
				</cftry>
				
				<cfif NOT updateFailed>
					<cfset this.counts.inserted++>
				</cfif>
				
			</cfloop>
			
			
			<cfif updateFailed>
				<cftransaction action="rollback">
			</cfif>
				
			<cftransaction action="commit">
		</cftransaction>

		<cfset addLog('Total records looped over: #this.counts.total#', 'info')>
		<cfset addLog('Total records inserted: #this.counts.inserted#', 'info')>
		<cfset addLog('Total records updated: #this.counts.updated#', 'info')>
		<cfset addLog('Total records deleted: #this.counts.deleted#', 'info')>
		<cfset addLog('Total records no action: #this.counts.noAction#', 'info')>
		<cfset addLog('Insert operation ended for Target: #this.datasource#.#this.tableName#', 'waypoint')>
		
	</cffunction>
	

	<!--- ================================================================================================================== --->
	<cffunction name="prepareGenericSQL">
		<cfargument name="dataRow" required="yes" type="struct">

		<cfset var columnSQL	= "">
		<cfset var valueSQL		= "">
		<cfset var ignoreColumn	= false>
		<cfset var currMap		= structnew()>
		<cfset var currValue	= "">
		
		<cfset var prepInfo 			= structnew()>
		<cfset prepInfo.columns			= arraynew(1)>
		<cfset prepInfo.identityFound 	= false>
		
		
		<cfloop list="#columnList#" index="currColumn">
			<cfset ignoreColumn 	= false>
			<cfset currMap			= this.columnMap.target[currColumn]>
			<cfset currValue 		= arguments.dataRow[currColumn]>
			
			<cfif currValue IS "">
				<cfif currMap.default IS NOT "" OR currMap.isIdentity>
					<cfset ignoreColumn = true>
					
				<cfelseif NOT currMap.nullable>
					<cfthrow message="Null value cannot be inserted for column #currColumn# and no default specified" detail="">
					
				</cfif>
				<cfset currValue = 'null'>
			
			<cfelseif currMap.typeName IS "datetime" AND isDate(currValue)>
				<cfset currValue = createODBCDateTime(currValue)>
			
			<cfelseif currMap.typeName CONTAINS "text" OR currMap.typeName CONTAINS 'char'>
				<cfset currValue = replace(currValue, "'", "''", "all")>
				<cfset currValue = "'#currValue#'">
			</cfif>
			
			<cfif NOT ignoreColumn>
				<cfset var currItem = structnew()>
				<cfset currItem.column = currColumn>
				<cfset currItem.value	= currValue>
				<cfset currItem.isIdentity	= this.columnMap.target[currColumn].isIdentity>
				<cfset currItem.cfsqltype 	= this.columnMap.target[currColumn].cfQueryParamType>
				
				<cfif currItem.isIdentity>
					<cfset prepInfo.identityFound = true>
				</cfif>
				
				
				<cfset arrayAppend(prepInfo.columns, currItem)>
			</cfif>
		</cfloop>
		
		
		<cfreturn prepInfo>
	</cffunction>
	
	
	<!--- ================================================================================================================== --->
	<cffunction name="createUpdateSQL"	>
		<cfargument name="dataRow" required="yes" type="struct">
		
		<cfset var prep = prepareGenericSQL(dataRow)>

		<cfif NOT prep.identityFound>
			<cfthrow message="DBSync.createUpdateSQL(): No identity column was detected.">
		</cfif>
		
		<cfset setList = "">
		<cfloop array="#prep.columns#" index="currItem">
			<cfif NOT currItem.isIdentity>
				<cfset setList = listAppend(setList, "#currItem.column# = #currItem.value#", "|")>
			</cfif>
		</cfloop>
		
		<cfsavecontent variable="outputSQL">
		<cfoutput>
			
			UPDATE #this.tableName# SET 
					#replace(setList, '|', ', ', 'all')#
				WHERE 
					1 = 1
					<cfloop array="#prep.columns#" index="currItem">
						<cfif currItem.isIdentity>
							AND #currItem.column# = #currItem.value#
						</cfif>
					</cfloop>
					
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn outputSQL>
		
	</cffunction>
	
	<!--- ================================================================================================================== --->
	<cffunction name="createInsertSQL"	>
		<cfargument name="dataRow" required="yes" type="struct">

		<cfset var prep 		= prepareGenericSQL(dataRow)>
		<cfset var columnSQL 	= "">
		<cfset var valueSQL 	= "">
		
		
		<cfloop array="#prep.columns#" index="currItem">
			<cfset columnSQL 	= listAppend(columnSQL, currItem.column, "|")>
			<cfset valueSQL 	= listAppend(valueSQL, currItem.value, "|")>
		</cfloop>

		
		<cfsavecontent variable="outputSQL">
		<cfoutput>
			<cfif this.hadDBIdentity>
				SET IDENTITY_INSERT #this.tableName# ON
			</cfif>
			INSERT INTO #this.tableName# (
				#replace(columnSQL, '|', ', ', 'all')#
			) VALUES (
				#replace(valueSQL, '|', ', ', 'all')#
			)
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn outputSQL>
		
	</cffunction>
	
	<!--- ================================================================================================================== --->
	<cffunction name="createInsertSQL_old"	>
		<cfargument name="dataRow" required="yes" type="struct">

		<cfset var columnSQL	= "">
		<cfset var valueSQL		= "">
		<cfset var ignoreColumn	= false>
		<cfset var currMap		= structnew()>
		<cfset var currValue	= "">
		
		<cfloop list="#columnList#" index="currColumn">
			<cfset ignoreColumn 	= false>
			<cfset currMap			= this.columnMap.target[currColumn]>
			<cfset currValue 		= arguments.dataRow[currColumn]>
			
			<cfif currValue IS "">
				<cfif currMap.default IS NOT "" OR currMap.isIdentity>
					<cfset ignoreColumn = true>
					
				<cfelseif NOT currMap.nullable>
					<cfthrow message="Null value cannot be inserted for column #currColumn# and no default specified" detail="">
					
				</cfif>
				<cfset currValue = 'null'>
			
			<cfelseif currMap.typeName IS "datetime" AND isDate(currValue)>
				<cfset currValue = createODBCDateTime(currValue)>
			
			<cfelseif currMap.typeName CONTAINS "text" OR currMap.typeName CONTAINS 'char'>
				<cfset currValue = replace(currValue, "'", "''", "all")>
				<cfset currValue = "'#currValue#'">
			</cfif>
			
			<cfif NOT ignoreColumn>
				<cfset columnSQL 	= listAppend(columnSQL, currColumn)>
				<cfset valueSQL 	= listAppend(valueSQL, currValue)>
			</cfif>
		</cfloop>
		

		<cfsavecontent variable="outputSQL">
		<cfoutput>
			<cfif this.hasDBIdentity>
				SET IDENTITY_INSERT #this.tableName# ON
			</cfif>
			
			INSERT INTO #this.tableName# (
				#replace(columnSQL, ',', ', ', 'all')#
			) VALUES (
				#replace(valueSQL, ',', ', ', 'all')#
			)
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn outputSQL>
	</cffunction>	

	
		
	<!--- ================================================================================================================== --->
	<cffunction name="addLog"	>
		<cfargument name="message">
		<cfargument name="type">
		
		<cfset var logItem 	= duplicate(arguments)>
		<cfset logItem.date = now()>
		<cfset logItem.message = "[SyncU] #logItem.message#">
		
		<cfset arrayAppend(this.activityLog, logItem)>
		
		<cfif logItem.type IS "error">
			<cfset this.counts.errors++>
		</cfif>
		
	</cffunction>
	
	
	
	<!--- ================================================================================================================== --->
	<cffunction name="getLog">
		<cfreturn this.activityLog>
	</cffunction>
	
		
	<!--- ================================================================================================================== --->
	<cffunction name="getErrors">
		<cfset var errors = arraynew(1)>
		<cfloop array="#this.activityLog#" index="currItem">
			<cfif currItem.type IS "error">
				<cfset arrayAppend(errors, currItem)>
			</cfif>
		</cfloop>
		
		<cfreturn errors>
	</cffunction>
	
		

</cfcomponent>

