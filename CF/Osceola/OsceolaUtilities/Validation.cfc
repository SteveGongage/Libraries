<cfcomponent>
	
	
	<cfset variables.form 	= form>
	<cfset this.errors		= arraynew(1)>

	<!--- ======================================================================================== --->	
	<cffunction name="init" access="public">
		<cfargument name="dataStructure" default="#form#">
		<cfset loadInput(arguments.dataStructure)>
	</cffunction>
		
	<!--- ======================================================================================== --->	
	<cffunction name="loadInput" access="public">
		<cfargument name="dataStructure" default="#form#">
		<cfset variables.form = dataStructure>
		<cfif structKeyExists(variables.form, 'fieldnames')>
			<cfset structDelete(variables.form, 'fieldNames')>
		</cfif>
	</cffunction>
	

	<!--- ======================================================================================== --->	
	<cffunction name="validate" access="public">
		<cfargument name="fieldName" 		type="string" 	required="yes">
		<cfargument name="fieldLabel" 		type="string" 	required="yes">
		<cfargument name="validationTest" 	type="string" 	required="yes">
		<cfargument name="testParam" 		type="any" 		required="no" 	default="">
		
		<cfset var result = resultNew(false, fieldName, fieldLabel, '', '')>
		<cfset var inputValue = "">
		
		
		<cfif NOT structKeyExists(variables.form, fieldName)>
			<cfset result.message = 'Cannot find "#fieldName#" in form input'>
			
		<cfelse>
			<cfset inputValue = variables.form[fieldName]>
			<cfset result.fieldValue = inputValue>
			
			<cfswitch expression="#validationTest#">
	
				<!--- MaxLength [] --->
				<cfcase value="maxLength">
					<cfif len(inputValue) LE testParam>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" exceeds the maximum length of #testParam# characters.'>
					</cfif>
				</cfcase>
				
				<!--- notBlank [] --->
				<cfcase value="notblank">
					<cfif len(inputValue) GT 0>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" cannot be blank'>
					</cfif>
				</cfcase>
				
				<!--- isBoolean [] --->
				<cfcase value="isBoolean">
					<cfif isBoolean(inputValue)>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" must be Yes or No'>
					</cfif>
				</cfcase>
				
				<!--- isNumeric [positive, min:max] --->
				<cfcase value="isNumeric">
					<cfif isNumeric(inputValue)>
						<cfset result.isValid = true>
						
						<cfif 		listFindNoCase(arguments.testParam, "positive") AND inputValue LT 0>
							<cfset result.isValid = false>
							<cfset result.message = 'The value for "#fieldLabel#" must be numeric'>
						<cfelseif	listlen(arguments.testParam, ':') IS 2>
							<cfif inputValue LT listFirst(arguments.testParam, ':') OR inputValue GT listLast(arguments.testParam, ':')>
								<cfset result.isValid = false>
								<cfset result.message = 'The value for "#fieldLabel#" must be between #listFirst(arguments.testParam, ':')# and #listLast(arguments.testParam, ':')#'>
							</cfif>
						</cfif>
						
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" must be numeric'>
					</cfif>
				</cfcase>
				
				<!--- InList [(item1,item2,item3)]--->
				<cfcase value="inList">
					<cfif listFindNoCase(arguments.testParam, inputValue)>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" is not an available option: [#arguments.testParam#]'>
					</cfif>
				</cfcase>
				
				
				<!--- isDate [] --->
				<cfcase value="isDate">
					<cfif isDate(inputValue) OR trim(inputValue) IS "">
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" is not a valid date'>
					</cfif>
				</cfcase>
				
				<!--- isPhoneNumber [] --->
				<cfcase value="isPhoneNumber">
                	<cfset phoneRegExOld = "^((\(\d{3}\) ?)|(\d{3}-))?\d{3}-\d{4}$">
                	<cfset phoneRegEx = "^[01]?[- .]?\(?[2-9]\d{2}\)?[- .]?\d{3}[- .]?\d{4}$">
                    
					<cfif reFindNoCase(phoneRegEx, inputValue)>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" is not a valid phone number'>
					</cfif>
				</cfcase>
				
				<!--- isEmail [] --->
				<cfcase value="isEmail">
					<cfif reFindNoCase("^([\w\d\-\.]+)@{1}(([\w\d\-]{1,67})|([\w\d\-]+\.[\w\d\-]{1,67}))\.(([a-zA-Z\d]{2,4})(\.[a-zA-Z\d]{2})?)$", inputValue)>
						<cfset result.isValid = true>
					<cfelse>
						<cfset result.message = 'The value for "#fieldLabel#" is not a valid email address'>
					</cfif>
				</cfcase>
				
				
				
				<!--- Unknown Tests Pass Automatically --->
				<cfdefaultcase>
					<cfset result.isValid = true>
				</cfdefaultcase>
			
			</cfswitch>
		</cfif>
		
		

		
		<cfif NOT result.isValid>
			<cfset handleValidationError(result)>
		</cfif>

		
		<cfreturn result>
	</cffunction>
	
	
	<!--- ======================================================================================== --->	
	<cffunction name="outputErrors" access="public" output="no">
		<cfargument name="userFriendlyMode" default="true" type="boolean">
		<cfset var errorOutput = "">

		<!--- Build Report based on Validation this.errors --->
		<cfif arraylen(this.errors) GT 0>
			<cfsavecontent variable="errorOutput">
			<cfoutput>
				<cfif arguments.userFriendlyMode>
					<!--- This reports a USER friendly view of the errors --->
					<div class="ValidationErrorReport">
						<cfif arraylen(this.errors) IS 1>
							<strong>Please correct the following issues:</strong>
							<br />
						<cfelse>
							#arraylen(this.errors)# issues were discovered during validation:<br />
						</cfif>
						<ul>
						<cfloop array="#this.errors#" index="currResult">
							<li>#currResult.message#</li>
						</cfloop>
						</ul>
					</div>
				<cfelse>
					<!--- This reports a detailed ADMIN view of the errors --->
					<cfif arraylen(this.errors) IS 1>
						An issue was discovered during validation.<br />
					<cfelse>
						#arraylen(this.errors)# issues were discovered during validation.<br />
					</cfif>
					<table width="100%" cellpadding="2" cellspacing="1" border="1" style="font-size: 10px;">
					<tr><th>Label</th><th>Name</th><th>Message</th><th>Current Value</th></tr>
					<cfloop array="#this.errors#" index="currResult">
						<tr><td><strong>#currResult.fieldLabel#</strong></td> <td>#currResult.fieldName#</td> <td>#currResult.message#</td> <td> <cfif currResult.fieldValue IS NOT "">#currResult.fieldValue#<cfelse><em>[blank]</em></cfif></td></tr>
					</cfloop>
					</table>
				</cfif>
			</cfoutput>
			</cfsavecontent>
		</cfif>
	
		<cfreturn errorOutput>
	</cffunction>	


	<!--- ======================================================================================== --->	
	<cffunction name="addError">
		<cfargument name="fieldName" 	default="unknown" 	type="string">
		<cfargument name="fieldLabel" 	default="unknown" 	type="string">
		<cfargument name="message" 		default="" 			type="string">
		<cfargument name="value" 		default="#variables.form[fieldName]#" 			type="string">
		<cfset var result = resultNew(false, fieldName, fieldLabel, value, message)>
		
		<cfset handleValidationError(result)>
		
		<cfreturn result>
	</cffunction>
	

		
	<!--- ======================================================================================== --->	
	<!--- Was everything valid?  Here are the functions to answer that question --->
	<cffunction name="isValidated" access="public">		<cfreturn arraylen(this.errors) IS 0>	</cffunction>
	<cffunction name="isInputValid" access="public">	<cfreturn arraylen(this.errors) IS 0>	</cffunction>
	

	
	<!--- ======================================================================================== --->	
	<cffunction name="isFieldValid" access="public">
		<cfargument name="fieldName" required="true">
		<cfset var result = resultNew()>

		<cfloop array="#this.errors#" index="currError">
			<cfif  currError.fieldname IS arguments.fieldName>
				<cfreturn currError>
			</cfif>
		</cfloop>
		
		<cfreturn resultNew(true, fieldName)>
	</cffunction>
	

	<!--- ======================================================================================== --->	
	<cffunction name="getErrorMessagesForField" access="public">
		<cfargument name="fieldName" required="true">
		<cfset var message = "">
		<cfset var currError = structnew()>
		
		<cfloop array="#this.errors#" index="currError">
			<cfif  currError.fieldname IS arguments.fieldName>
				<cfset message = listAppend(message, currError.message)>
			</cfif>
		</cfloop>
		
		<cfreturn message>
	</cffunction>
	
	
	
	<!--- ======================================================================================== --->	
	<cffunction name="getErrors" access="public">
		<cfreturn this.errors>
	</cffunction>






	<!--- ======================================================================================== --->	
	<!--- ======================================================================================== --->	
	<!--- ======================================================================================== --->	
	<cffunction name="handleValidationError" access="private">
		<cfargument name="failedResult">
		<!--- Add this error to the error array --->
		<cfset arrayappend(this.errors, failedResult)>
		
		<!---
			*** Add Code Here if you want anything special to happen when a validation error occurs ***
		--->
		
	</cffunction>
	
	
	<!--- ======================================================================================== --->	
	<cffunction name="resultNew" access="private">
		<cfargument name="isValid" 		default="false" 	type="boolean">
		<cfargument name="fieldName" 	default="unknown" 	type="string">
		<cfargument name="fieldLabel" 	default="unknown" 	type="string">
		<cfargument name="fieldValue" 	default="" 			type="string">
		<cfargument name="message" 		default="" 			type="string">

		<cfset var result = arguments>
		
		<cfreturn result>
	</cffunction>
	

	
</cfcomponent>