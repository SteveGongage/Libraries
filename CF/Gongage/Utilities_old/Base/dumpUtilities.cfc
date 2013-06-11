<!--- =========================================================================================================
	Created:		Steve Gongage (4/25/2013)
	Purpose:		Data dump utilities library 

	Usage:			included in the default utilities library

========================================================================================================= --->
<cfcomponent extends="cf.Gongage.Utilities.UtilityBase">


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


</cfcomponent>