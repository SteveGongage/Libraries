<!--- =========================================================================================================
	Created:		Steve Gongage (4/25/2013)
	Purpose:		Data dump utilities library 

	Usage:			included in the default utilities library

========================================================================================================= --->
<cfcomponent extends="cf.Gongage.utilities.LibraryBase">

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
			<style>
				TABLE.helpComponentTable { border-spacing: 2px; border-collapse: separate; font-size: 10px; width: 800px; font-family: Verdana, Geneva, sans-serif; }
					.helpComponentTable TABLE {border-spacing: 2px; border-collapse: separate; font-size: 10px; width:  100%;}
					.helpComponentTable OL LI { list-style-type: none; }
					.helpComponentTable .helpHint { font-style: italic; padding: .5em; }
					.helpComponentTable .helpFunctionGroup 	{ font-weight: normal; font-size: 11px; }
					.helpComponentTable .helpFunctionAccess	{ font-weight: normal; font-style: italic;}

					.helpComponentTable TD,
					.helpComponentTable TH { background-color: ##EEDDFF; vertical-align: top; padding: 4px;}
					.helpComponentTable TD.helpLabel,
					.helpComponentTable TH.helpLabel { background-color: ##BBAAEE; text-align: right; width: 120px;}

					TABLE.helpFunctionTable { }
						.helpFunctionTable TD,
						.helpFunctionTable TH { background-color: ##FFFFEE; }
						.helpFunctionTable TD.helpLabel,
						.helpFunctionTable TH.helpLabel { background-color: ##FFFFCC; width: 150px; }
						.helpFunctionTable .helpFunctionName 	{ font-weight: bold; }

						TABLE.helpParamTable { }
							.helpParamTable TD,
							.helpParamTable TH { background-color: ##EEF8FF; }
							.helpParamTable TD.helpLabel,
							.helpParamTable TH.helpLabel { background-color: ##CCDDFF; width: 120px; text-align: right; }
							.helpParamTable TR.required TD,
							.helpParamTable TR.required TH { font-weight: bold; }
							.helpParamTable TR.required TD.helpParamDefault { color: ##C88; }
							.helpParamTable TD.helpParamType { width: 50px; font-style: italic;}

			</style>

			<!--- COMPONENT table --->
			<table class="helpComponentTable">
				<!--- Component Basic Information --->
				<tr>
					<td colspan="2" class="helpLabel" style="text-align: left; padding-left: 1em; background-color: ##538; color: white;">
						<div style="font-weight: bold; font-size: 17px; float: left;">#LOCAL.compName#</div>
						<div style=" float: right; text-align: right;">
							<div style="font-style: italic; font-weight: bold;">#libMeta.fullName#</div>
							<cfif structKeyExists(libMeta, 'extends')>
								<div style="font-style: italic; font-weight: normal;">extends #libMeta.extends.fullName#</div>
							</cfif>

						</div>
						<div style="clear: both;"></div>
					</td>
				</tr>

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
								<td class="helpLabel">
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
													<td class="helpLabel">
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
																		<td class="helpLabel">
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

	<!--- ============================================================================================= --->
	<cffunction name="charMap" hint="Outputs a table mapping each character in a string to it's ascii value.">
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