<!--- =========================================================================================================
	Created:		Steve Gongage (7/14/2012)
	Purpose:		Developer tools for outputting data during testing and debugging.  Required by the LibraryCollection.

	Usage:			included in the default utilities library

========================================================================================================= --->
<cfcomponent hint="Developer tools for outputting data during testing and debugging.  Required by the LibraryCollection.">


	<cfset variables.stylesheet = "">
	<cfsavecontent variable="variables.stylesheet">
	<cfoutput>
		<style>
			TABLE.gDumpTable { border-spacing: 2px; border-collapse: separate; font-size: 10px; width: 800px; font-family: Verdana, Geneva, sans-serif; }
				.gDumpTable TABLE {border-spacing: 2px; border-collapse: separate; font-size: 10px; width:  100%;}
				.gDumpTable OL LI { list-style-type: none; }
				.gDumpTable .helpHint { font-style: italic; padding: .5em; }
				.gDumpTable .helpFunctionGroup 	{ font-weight: normal; font-size: 11px; }
				.gDumpTable .helpFunctionAccess	{ font-weight: normal; font-style: italic;}

				.gDumpTable TD,
				.gDumpTable TH { background-color: ##EEDDFF; vertical-align: top; padding: 4px;}
				.gDumpTable > TBODY > TR > TD:first-child { background-color: ##BBAAEE; text-align: right; width: 120px; font-weight: bold;}
					.gDumpTable > TBODY > TR > TD:first-child > A { text-decoration: none; color: ##03A; }

				.gDumpTable > THEAD > TR > TH { text-align: left; padding-left: 1em; background-color: ##538; color: white; }
				.gDumpTable > THEAD > TR > TH  H3 { font-weight: bold; font-size: 17px; float: left; margin: 0px; line-height: 1.5em; }
				.gDumpTable > THEAD > TR > TH  .right {  float: right; text-align: right; }
				.gDumpTable > THEAD > TR > TH  H4 { font-style: italic; font-weight: bold; font-size: 11px;  margin: 0px; line-height: 1.2em; }
				.gDumpTable > THEAD > TR > TH  H5 { font-style: italic; font-weight: normal;font-size: 11px; margin: 0px; line-height: 1.2em; }
		</style>
	</cfoutput>
	</cfsavecontent>



	<!---============================================================================================== --->
	<cffunction name="component"  group="Objects" hint="Helpful documentation for any component.">
		<cfargument name="comp" required="true" type="any">

		<cfset var message 		= "">

		<cfif NOT isObject(arguments.comp)>
			<cfthrow message="Invalid comp supplied">
		</cfif>
		<cfset var libMeta		= getMetaData(arguments.comp)>

		<cfset var compName		= listLast(replaceNOCASE(libMeta.name, '.cfc', ''), '.')>

		<cfif NOT structKeyExists(libMeta, 'hint')>
			<cfset libMeta.hint = "">
		</cfif>

		<!--- Get an idea of what kind of function access levels and groups we have --->
		<cfset functionTypes = arraynew(1)>
		<cfloop array="#libMeta.functions#" index="currFunction">
			<cfset structAppend(currFunction, {
				'access' 		= 'public',
				'hint'			= '',
				'group'			= ''
			}, false)>

			<cfset currFunctionType = "#currFunction.access#:#currFunction.group#">
			<cfif NOT arrayFindNoCase(functionTypes, currFunctionType)>
				<cfset arrayAppend(functionTypes, currFunctionType)>
			</cfif>
		</cfloop>
		<cfset arraySort(functionTypes, 'textNoCase')>


		<cfsavecontent variable="output">
		<cfoutput>
			<!--- Output Common Styles --->
			#outputStyles('purple')#

			<style>
					TABLE.helpFunctionTable { }
						.helpFunctionTable TD,
						.helpFunctionTable TH { background-color: ##FFFFEE; }
						.helpFunctionTable > TBODY > TR > TD:first-child { background-color: ##FFFFCC; width: 150px; }
						.helpFunctionTable .helpFunctionName 	{ font-weight: bold; }

						TABLE.helpParamTable { }
							.helpParamTable TD,
							.helpParamTable TH { background-color: ##EEF8FF; }
							.helpParamTable > TBODY > TR > TD:first-child { background-color: ##CCDDFF; width: 120px; text-align: right; }
							.helpParamTable TR.required TD,
							.helpParamTable TR.required TH { font-weight: bold; }
							.helpParamTable TR.required TD.helpParamDefault { color: ##C88; }
							.helpParamTable TD.helpParamType { width: 50px; font-style: italic;}

			</style>

			<!--- COMPONENT table --->
			<table class="gDumpTable">
				<!--- Component Basic Information --->
				<thead>
					<tr>
						<th colspan="2">
							<h3>#LOCAL.compName#</h3>

							<div class="right">
								<h4>#libMeta.fullName#</h4>
								<cfif structKeyExists(libMeta, 'extends') AND libMeta.extends.fullName IS NOT "WEB-INF.cftags.component">
									<h5>extends: #libMeta.extends.fullName#</h5>
								</cfif>

							</div>
							<div style="clear: both;"></div>
						</th>
					</tr>
				</thead>

				<cfif libMeta.hint IS NOT "">
					<tr>
						<td colspan="2" style="padding-left: 1em;">
							#libMeta.hint#
							<cfif LOCAL.message IS NOT "">
								<div>#LOCAL.message#</div>
							</cfif>
						</td>
					</tr>	
				</cfif>


				<!--- Component Methods --->

				<!--- Loop through method types --->
				<cfloop list="Public,Remote,Private" index="currAccess">
					<!--- Loop through method groups --->
					<cfloop array="#functionTypes#" index="currFunctionType">
						<cfset currTypeAccess 	= listFirst(currFunctionType, ":")>
						<cfset currTypeGroup 	= "">
						<cfif listLen(currFunctionType, ":") GT 1>
							<cfset currTypeGroup 	= listLast(currFunctionType, ":")>
						</cfif>
	

						<cfif currTypeAccess IS currAccess>
							
							<tr>
								<td>
									<div class="helpFunctionGroup">
										<cfif currTypeGroup IS "">
											UNGROUPED
										<cfelse>
											#uCase(currTypeGroup)#
										</cfif>										
									</div>

									<div class="helpFunctionAccess">
										Access: #currAccess#
									</div>
								</td>
								<td>

									<!--- FUNCTION table --->
									<table class="helpFunctionTable">
										<cfloop array="#libMeta.functions#" index="currFunction">
											<cfset structAppend(currFunction, {
												'access' 		= 'public',
												'hint'			= '',
												'group'			= ''
											}, false)>

											<cfif currFunction.access IS currAccess AND currFunction.group IS currTypeGroup>
												<tr>
													<td>
														<div class="helpFunctionName">#currFunction.name#</div>
													</td>
													<td>
														<cfif currFunction.hint IS NOT "">
															<div class="helpHint">
																#currFunction.hint#
															</div>
														</cfif>
														<cfif arrayLen(currFunction.parameters) GT 0>

															<!--- PARAM table --->
															<table class="helpParamTable">
																<cfloop array="#currFunction.parameters#" index="currParam">
																	<cfset structAppend(currParam, {
																		'required'	= false,
																		'type'		= 'any',
																		'default'	= ''
																	}, false)>

																	<tr <cfif currParam.required> class="required" </cfif>>
																		<td>
																			#currParam.name#
																		</td>
																		<td class="helpParamType">
																			#currParam.type#
																		</td>
																		<td class="helpParamDefault">
																			<cfif NOT currParam.required>
																				"#currParam.default#"
																			<cfelse>
																				required
																			</cfif>
																		</td>
																	</tr>
																</cfloop>
															</table>
															<!--- PARAM table end --->
														</cfif>
													</td>
												</tr>
											</cfif>
										</cfloop>
									</table>
									<!--- FUNCTION table end --->
								</td>
							</tr>	
						</cfif>				
					</cfloop>
	
						
				</cfloop>

			</table>
			<!--- COMPONENT table end --->

			</cfoutput>
		</cfsavecontent>
	
		<cfreturn output>


	</cffunction>


	<!---============================================================================================== --->
	<cffunction name="table" group="Database" hint="Dumb a database table (not including data)">
		<cfargument name="dsn"		 	type="string" required="true">
		<cfargument name="tableName" 	type="string" required="true">

		<cfset var output = "">
		<cfset var fields = "">

		<cfdbinfo datasource="#arguments.dsn#" type="columns" name="cols" table="#arguments.tableName#">

		<cfsavecontent variable="output">
		<cfoutput>

			<!--- Output Common Styles --->
			#outputStyles('purple')#

			<table class="gDumpTable">
				<thead>
					<tr>
						<th colspan="3">
							<h3>#arguments.tableName#</h3>

							<div class="right">
								<h4>#arguments.dsn#.#arguments.tableName#</h4>
							</div>
							<div style="clear: both;"></div>
						</th>
					</tr>
				</thead>
				<cfloop query="cols">
					<tr>
						<td>#cols.column_name#</td>
						<td style="width: 80px;">#replaceNOCASE(cols.type_name, 'identity', '')# (#cols.column_size#)</td>
						<td>
							<cfif cols.is_Nullable>
								<span class="label">Nullable</span>
							</cfif>
							<cfif cols.is_primaryKey>
								<span class="label">Primary Key</span>
							</cfif>
							<cfif cols.type_name CONTAINS 'identity'>
								<span class="label">Identity</span>
							</cfif>
						</td>
					</tr>
				</cfloop>

			</table>
			
		</cfoutput>
		</cfsavecontent>


		<cfreturn output>
	</cffunction>


	<!---============================================================================================== --->
	<cffunction name="subcomponents" group="Objects" hint="Shows details of a sub component of a component">
		<cfargument name="library" type="component" required="true">
		<cfset var output = "">
		<cfset var compList = listSort(structKeyList(arguments.library), 'textNoCase')>

		<cfset var currMeta = getMetaData(arguments.library)>

		<cfsavecontent variable="output">
		<cfoutput>
			<!--- Output Common Styles --->
			#outputStyles('purple')#

			<script>
				function toggleSubComponent(name, link) {
					var allCompDivs = document.getElementsByClassName('gDumpSubComponent');
					var targetDiv = document.getElementById('gDumpSubComponent_'+ name);

					

					for each(comp in allCompDivs) {	
						if (typeof(comp.style) != 'undefined' && comp != targetDiv ) {
							comp.style.display = 'none';
						}
					}

					if (targetDiv.style.display == 'block') {
						targetDiv.style.display = 'none';
					} else {
						targetDiv.style.display = 'block';
					}
					
				}
			</script>

			<table class="gDumpTable">
				<thead>
					<tr>
						<th colspan="2">
							<h3>#listLast(currMeta.name, '.')#</h3>

							<div class="right">
								<h4>#currMeta.fullName#</h4>
								<cfif structKeyExists(currMeta, 'extends')>
									<h5>extends: #currMeta.extends.fullName#</h5>
								</cfif>

							</div>
							<div style="clear: both;"></div>
						</th>
					</tr>
				</thead>

				<cfloop list="#compList#" index="currKey">
					<cfif isObject(arguments.library[currKey])>
						<tr>
							<td style="text-align: right;"><a href="##gDumpSubComponent" onclick="toggleSubComponent('#currKey#', this);">#uCase(currKey)#</a></td>
							<td>		
								<cfset meta = getMetaData(arguments.library[currKey])>
								<cfif structKeyExists(meta, 'hint')>
									#meta.hint#
								</cfif>
							</td>
						</tr>
					</cfif>
		
				</cfloop>
			</table>

			<a name="gDumpSubComponent"></a>
			<cfloop list="#compList#" index="currKey">
				<cfif isObject(arguments.library[currKey])>
					<!-- dump of subcomponent #currKey# -->
					<div id="gDumpSubComponent_#currKey#" style="display: none;" class="gDumpSubComponent">
						#component(arguments.library[currKey])#
					</div>
				</cfif>
			</cfloop>


		</cfoutput>
		</cfsavecontent>

		<cfreturn output>
	</cffunction>


	<!--- ============================================================================================= --->
	<cffunction name="outputStyles" group="Private" hint="Outputs base styles for internal methods.  Not intended for public use..." access="private">
		<cfset var output = "">
		<cfsavecontent variable="output">
		<cfoutput>
			<style>
				TABLE.gDumpTable { border-spacing: 2px; border-collapse: separate; font-size: 10px; width: 800px; font-family: Verdana, Geneva, sans-serif; }
					.gDumpTable TABLE {border-spacing: 2px; border-collapse: separate; font-size: 10px; width:  100%;}
					.gDumpTable OL LI { list-style-type: none; }
					.gDumpTable .helpHint { font-style: italic; padding: .5em; }
					.gDumpTable .helpFunctionGroup 	{ font-weight: normal; font-size: 11px; }
					.gDumpTable .helpFunctionAccess	{ font-weight: normal; font-style: italic;}

					.gDumpTable TD,
					.gDumpTable TH { background-color: ##EEDDFF; vertical-align: top; padding: 4px;}
					.gDumpTable > TBODY > TR > TD:first-child { background-color: ##BBAAEE; text-align: right; width: 120px; font-weight: bold;}
						.gDumpTable > TBODY > TR > TD:first-child > A { text-decoration: none; color: ##03A; }

					.gDumpTable > THEAD > TR > TH { text-align: left; padding-left: 1em; background-color: ##538; color: white; }
					.gDumpTable > THEAD > TR > TH  H3 { font-weight: bold; font-size: 17px; float: left; margin: 0px; line-height: 1.5em; }
					.gDumpTable > THEAD > TR > TH  .right {  float: right; text-align: right; }
					.gDumpTable > THEAD > TR > TH  H4 { font-style: italic; font-weight: bold; font-size: 11px;  margin: 0px; line-height: 1.2em; }
					.gDumpTable > THEAD > TR > TH  H5 { font-style: italic; font-weight: normal;font-size: 11px; margin: 0px; line-height: 1.2em; }
			</style>

		</cfoutput>
		</cfsavecontent>
		<cfreturn output>
	</cffunction>

	<!--- ============================================================================================= --->
	<cffunction name="charMap" group="Strings" hint="Outputs a table mapping each character in a string to it's ascii value.">
		<cfargument name="stringIn" type="string">
		
		<cfset var i = 0>
		<cfset var maxPerRow = 40>
		<cfset var map = arraynew(1)>
		<cfset var mapItem = structnew()>
	
		<cfloop from="1" to="#len(stringIn)#" index="i">
			<cfset mapItem = structnew()>
			<cfset mapItem['original'] 	= mid(stringIn, i, 1)>
			<cfset mapItem['ascii']		= asc(mapItem['original'])>
			<cfset mapItem['position']	= i>
			<cfset mapItem['type']		= 'unknown'>
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
		
		<cfset var outputCode = "">
		<cfsavecontent variable="outputCode">
			<cfoutput>
			<style>
				.CharMapTable {
					border-collapse: collapse; font-size: 11px; width: auto; margin: 1em;
				}
					.CharMapTable TD { border: 1px solid gray; padding: 2px; width: 24px; text-align: center; color: ##888;}
						.CharMapTable TD.unprintable{ background-color: auto;  }
						.CharMapTable TD.special	{ background-color: ##FFD; }
						.CharMapTable TD.number	 	{ background-color: ##AFB; }
						.CharMapTable TD.alphaUpper	{ background-color: ##BDF; }
						.CharMapTable TD.alphaLower	{ background-color: ##DEF; }
						.CharMapTable TD.extended	{ background-color: ##FCC; }
						.CharMapTable TD.ISOextended{ background-color: ##FAA; }
						
					.CharMapTable PRE { 
						border: 1px solid silver; width: 16px; height: 16px; font-size: 1.2em; font-weight: bold; color: ##333; text-align: center; margin: 0px auto; padding: 0px;
					}
			</style>
			
			<table style="" class="CharMapTable">
			<tr>
				<cfset var rc = 0>
				<cfloop array="#map#" index="mapItem">
					<cfset rc++>
					<td class="#mapItem['type']#">
						<pre>#mapItem['original']#</pre>
						<br />
						#mapItem['ascii']#
						<br />
					</td>

					<cfif rc GT maxPerRow>
						<cfset rc = 0>
							</tr>
						</table>
						<table class="CharMapTable">
							<tr>						
					</cfif>

				</cfloop>
			</tr>
			</table>
			</cfoutput>			
		</cfsavecontent>

		<cfreturn outputCode>
	</cffunction>

</cfcomponent>