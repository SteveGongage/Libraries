<cfcomponent>
	
	
	
	<!--- =============================================================================================================== --->
	<cffunction name="confirmEmployee">
		<cfargument name="employeeNumber" 	required="yes" type="numeric">
		<cfargument name="last2SSN" 				required="yes" type="numeric">
		
		<cfset var result 					= structnew()>
		<cfset result['success'] 			= false>
		<cfset result['message'] 			= ''>
		<cfset result['data']				= structnew()>
		<cfset result.data.nameFirst		= ''>
		<cfset result.data.nameLast			= ''>
		<cfset result.data.nameMiddle		= ''>
		<cfset result.data.employeeNumber	= ''>
		<cfset result.data.email			= ''>
		
		<cfset var empLookup = getEmployeeByNumber(arguments.employeeNumber)>
		<cfif empLookup.recordcount IS NOT 1>
			<cfset result.message = "Your employee ID and last 2 of your SSN did not match an employee in our records.">

		<cfelseif right(trim(empLookup.last4SSN), 2) IS NOT right(arguments.last2SSN, 2)>
			<cfset result.message = "Your employee ID and last 2 of your SSN did not match an employee in our records.">

		<cfelse>
			<cfset result.success 				= true>
			<cfset result.message 				= "Employee successfuly confirmed">
			<cfset result.data.nameFirst		= empLookup.nameFirst>
			<cfset result.data.nameLast			= empLookup.nameLast>
			<cfset result.data.nameMiddle		= empLookup.nameMiddle>
			<cfset result.data.employeeNumber	= empLookup.employeeNumber>
			<cfset result.data.email			= empLookup.email>
		</cfif>	
		
		<cfreturn result>
	</cffunction>

	
	<!--- =============================================================================================================== --->
	<cffunction name="getEmployeeByNumber">
		<cfargument name="employeeNumber" required="yes" type="numeric">
		
		<cfset var empLookup = querynew('default')>
		
		<cfquery name="empLookup" datasource="#request.global.datasource.cmsModules#">
			SELECT * FROM UnifiedAccounts_User 
				WHERE employeeNumber = <cfqueryparam value="#arguments.employeeNumber#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn empLookup>
	</cffunction>

	<!--- =============================================================================================================== --->
	<cffunction name="getEmployeeByLoginName">
		<cfargument name="loginName" required="yes" type="string">
		
		<cfset var empLookup = querynew('default')>
		
		<cfquery name="empLookup" datasource="#request.global.datasource.cmsModules#">
			SELECT * FROM UnifiedAccounts_User 
				WHERE loginName = <cfqueryparam value="#arguments.loginName#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn empLookup>
	</cffunction>

		<!---
		<cfset var empLookup = querynew('default')>
		<cfquery name="empLookup" datasource="ifas">
			SELECT 
					ID 			as employeeNumber, 
					FName 		as nameFirst, 
					LName 		as nameLast, 
					MName 		as nameMiddle, 
					NAME 		as nameFull,
					SSN			as SSN, 
					HR_STATUS 	as status, 
					Gender 		as sex, 
					BDT 		as dateBirth, 
					BEG 		as dateHired,
					E_Mail 		as email, 
					City 		as addressCity, 
					Zip 		as addressZip,  
					ST_1 		as addressStreet1, 
					ST_2 		as addressStreet2,
					HR1 		as HRParam1, 
					WorkSite 	as Worksite, 
					hr_hrEncode.Long_Desc as sIFASDepName,
					DIVISION 	as sDivisionName
				FROM HR_EmpMstr LEFT OUTER JOIN
					hr_hrEncode on HR_EmpMstr.department = hr_hrEncode.codeval
				WHERE
					(hr_hrEncode.codeid		= 'DEPARTMENT_CODE' OR hr_hrEncode.codeid is null)
					<cfif employeeNumber IS NOT 0>			
						AND ID = <cfqueryparam value="#numberformat(employeeNumber, '00000000')#" cfsqltype="cf_sql_varchar">
					<cfelse>
						AND 1 = 0
					</cfif>
		</cfquery>
	
		<cfreturn empLookup>
		--->
	
	
	<!--- =============================================================================================================== --->
	<!--- FUNCTION: AD Lookups --->		
	<cffunction name="lookupADUserByEmployeeNumber">
		<cfargument name="searchTerm" 	required="yes" type="numeric">
		
		<cfreturn lookupADUser(arguments.searchTerm, 'employeeNumber')>
	</cffunction>
	

	<cffunction name="lookupADUser">
		<cfargument name="searchTerm" 	required="yes" type="string">
		<cfargument name="searchBy"		required="yes" type="string">
		
		<cfset arguments.searchTerm = trim(arguments.searchTerm)>
		
		<cfset stLDAP		= structnew()>
		<!---
		<cfset stLDAP.queryServer				= 'venice.osceola.org'>
		<cfset stLDAP.queryUserName 			= "OCIS\ldapreadacct">
		<cfset stLDAP.queryPasswordEncrypted 	= 'p/Lxcd001ppX6frbl7El1QuLG8V07OVjF3TYAgJ7qEY='>
		<cfset stLDAP.encryptKey 				= "crGqskhUKgxs+3MnYZlXJQ==">
		<cfset stLDAP.encryptAlg				= "AES">
		<cfset stLDAP.encryptEncoding 			= "Base64">
		--->
		
		<cfset stLDAP.queryServer				= request.global.credentials.LDAP.server>
		<cfset stLDAP.queryUserName 			= request.global.credentials.LDAP.username>
		<cfset stLDAP.queryPasswordEncrypted 	= request.global.credentials.LDAP.passwordEncrypted>
		<cfset stLDAP.encryptKey 				= request.global.encryption.key>
		<cfset stLDAP.encryptAlg				= request.global.encryption.algorithm>
		<cfset stLDAP.encryptEncoding 			= request.global.encryption.encoding>
		
		<cfset stLDAP.QueryAttributes			= "sn,samAccountName,employeeID,mailNickname,name,displayName,givenname,mail,title,department,memberOf,telephoneNumber,facsimileTelephoneNumber,streetAddress,postOfficeBox,postalCode,l,st,homeMTA,distinguishedName,lastLogon,objectclass">
		<cfset stLDap.password					= decrypt(stLDAP.queryPasswordEncrypted, stLDAP.encryptKey, stLDAP.encryptAlg, stLDAP.encryptEncoding)>
		
		<cfswitch expression="#arguments.searchBy#">
			<cfcase value="employeeNumber,EmployeeID" delimiters=",">
				<cfset arguments.searchTerm = numberformat(arguments.searchTerm, '00000000')>
				<cfset filter 	= "(&(objectclass=person)(&(employeeID=#arguments.searchTerm#))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))">
			</cfcase>
			<cfcase value="LoginName">
				<cfset filter 	= "(&(objectclass=person)(&(mailNickname=#arguments.searchTerm#))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))">
			</cfcase>
			<cfcase value="Name">
				<cfset filter 	= "(&(objectclass=person)(|(name=*#arguments.searchTerm#*)(department=*#arguments.searchTerm#*))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))">
			</cfcase>
			<cfcase value="Everyone">
				<cfset filter 	= "(&(objectclass=person)(!(employeeID=''))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))">
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="Unknown 'Search By' criteria (#searchBy#)" detail="Allowed criteria are EmployeeID, LoginName, Name, or Everyone.">
			</cfdefaultcase>
		</cfswitch>

		
		<cfldap name="getADEmployee" action="query" 
			attributes	="#stLDAP.QueryAttributes#"
			filter		="#filter#"
			server		="#stLDAP.queryServer#"
			username	="#stLDAP.queryUserName#"
			password	="#stLDap.password#"	
				start	="dc=osceola,dc=org">
		
		<cfreturn getADEmployee>
	
	</cffunction>

</cfcomponent>