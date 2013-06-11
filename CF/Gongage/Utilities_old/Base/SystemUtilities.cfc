<!--- =========================================================================================================
	Created:		Steve Gongage (4/26/2013)
	Purpose:		System utilities library for ColdFusion and Java system functions

	Usage:			included in the default utilities library

========================================================================================================= --->
<cfcomponent extends="cf.Gongage.Utilities.UtilityBase">
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	<!--- ================================================================================================ --->
	

	
	<!--- ================================================================================================ --->
	<!--- Functions --->
	<!--- ================================================================================================ --->

	
	<!-----------------------------------------------------------------------------------
		Clear the CF HTML Head
	------------------------------------------------------------------------------------->
	<cffunction name="clearCFHTMLHead" group="action" hint="Clear the HTML Head content created thus far.  Useful for when it is necessary to clean up output for something like CSV or other non HTML formats.  Removes things like Google Maps API keys being injected for instance.">
		<!--- http://www.coldfusiondeveloper.nl/post.cfm/clearing-the-cfhtmlhead-buffer-in-railo --->
		<cfset var out = getPageContext().getOut()>
		<cfset var method = "">
		<cfloop condition="(getMetaData(out).getName() is 'coldfusion.runtime.NeoBodyContent')">
			<cfset out = out.getEnclosingWriter()>
		</cfloop>
		
		<cfset method = out.getClass().getDeclaredMethod("initHeaderBuffer",arrayNew(1))>
		<cfset method.setAccessible(true)>
		<cfset method.invoke(out,arrayNew(1))>
	</cffunction>


	<!-----------------------------------------------------------------------------------
		
	------------------------------------------------------------------------------------->
	<cffunction name="getHostName" group="settings" hint="Returns the host name for the current server">
		<cfreturn CreateObject("java", "java.net.InetAddress").getHostName()>
	</cffunction>

	<!-----------------------------------------------------------------------------------
		
	------------------------------------------------------------------------------------->
	<cffunction name="getServerName" group="settings" hint="Returns the server name for the current server">
		<!--- Pre CF 10 --->
		<!---
		<cfreturn createObject("java", "jrunx.kernel.JRun").getServerName()>
		--->

		<cfreturn createObject('component', 'CFIDE.adminapi.runtime').getInstanceName()>

	</cffunction>




</cfcomponent>



