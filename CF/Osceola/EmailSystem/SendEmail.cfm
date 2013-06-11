<!---

	<cf_SendEmail to="someone@osceola.org" subject="Your Subject">
		<cfoutput>
			Your Content Here!
		</cfoutput>
	</cf_SendEmail>


---->

<cfparam name="request.global.email.server" default="">
<cfparam name="request.global.email.from.generic.name" 		default="Osceola County">
<cfparam name="request.global.email.from.generic.address" 	default="webmaster@osceola.org">

<cfparam name="attributes.to"			default="">
<cfparam name="attributes.toGroup"		default="">
<cfparam name="attributes.fromName"		default="#request.global.email.from.generic.name#">
<cfparam name="attributes.fromEmail"	default="#request.global.email.from.generic.address#">
<cfparam name="attributes.from"			default="#attributes.fromName# <#attributes.fromEmail#>">
<cfparam name="attributes.replyTo"		default="#attributes.from#">
<cfparam name="attributes.subject"		default="">
<cfparam name="attributes.message"		default="">
<cfparam name="attributes.server"		default="#request.global.email.server#">
<cfparam name="attributes.bcc"		 	default="">
<cfparam name="attributes.showImage"	default="true">
<cfparam name="attributes.showLegal"	default="true">
<cfparam name="attributes.imageHREF"	default="http://www.osceola.org/Templates/Email/OsceolaCounty/email_MastHeadAndDrop.gif">

<cfset messageContent_Text 	= "">
<cfset messageContent_HTML 	= "">
<cfset sendMessage 			= false>


<cfif thisTag.hasEndTag>
	<!--- The message body will be contained within the start and end tags --->
	
	<cfif thisTag.executionMode IS "end">
		<cfset attributes.message = thisTag.generatedContent>
		<cfset sendMessage = true>
	</cfif>

<cfelse>
	<!--- This message is sent only using the start tag and the message attribute --->
	<cfset attributes.message = attributes.message>
	<cfset sendMessage = true>

</cfif>
	
<!--- ================================================================================================= --->
<cfif sendMessage>
	
	<!--- To Group --->
	<cfif attributes.toGroup IS NOT "" AND  structKeyExists(request.global.email.groups, attributes.toGroup)>
		<cfset attributes.to = listAppend(attributes.to, request.global.email.groups[attributes.toGroup])>
	</cfif>
	
	<!--- VALIDATION --->
	<cfif attributes.to IS "">
		<cfthrow message="SendMail requires an email address in the TO field">
	</cfif>

	<cfif trim(attributes.message) IS "">
		<cfthrow message="SendMail requires a non empty message">
	</cfif>
	
	
	
	<!--- ================================================================================================ --->
	<cfsavecontent variable="messageContent_HTML">
		<cfinclude template="mailTemplate.cfm">
	</cfsavecontent>
	
	
	<!--- ================================================================================================ --->
	<cfif attributes.to IS NOT "">
		<cfset lsEmailToList = attributes.to>
		<cfset lsEmailtoList = replace(lsEmailToList, ";", ",", "all")>
		
		
		<cfloop list="#lsEmailtoList#" index="sCurrentEmailTo" delimiters=";">
			<!---""--->
			<cfmail 
				type	="html"
				from	="#attributes.from#"	
				to		="#sCurrentEmailTo#"
				bcc		="#attributes.bcc#"
				replyTo ="#attributes.replyTo#"
				
				subject	="#attributes.subject#"		
				server	="#attributes.server#">#messageContent_HTML#</cfmail>
		</cfloop>
	
	</cfif>

	<cfset thisTag.generatedContent = "">
</cfif>


