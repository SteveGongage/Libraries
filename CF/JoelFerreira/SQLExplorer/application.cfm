<!--- local|local|JS123 desktop|JS123 laptop|home --->
<cfif !reFindNoCase("localhost|127.0.0.1|10.10.", cgi.remote_host)>
	<span style="color:red;"><h1>Not Authorized</h1></span><cfabort>
</cfif>
