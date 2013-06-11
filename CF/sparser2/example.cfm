<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>sParser2 Component example</title>
</head>

<body>
<b>Example 1:</b><br />
Get all hints from the public methods (and its arguments) of our own CFC:<br /><br />
<cfset parser=CreateObject("component","sparser2").init(ExpandPath("./") & "sparser2.cfc")>
<cfset all_hints=parser.selector("cffunction[access=public][hint]").query()>
<cfloop query="all_hints">
	<cfoutput><b>#all_hints.currentRow#. #all_hints.name#</b> (<i>#all_hints.hint#</i>)<br /></cfoutput>
	<!--- grab all required arguments of the current method --->
	<cfset req_par=CreateObject("component","sparser2").init(all_hints.i_content)>
    <cfset req_arguments=req_par.selector("cfargument[required=yes]").query()>
    <cfset opt_arguments=req_par.selector("cfargument[required=no]").query()>
    <!--- display required arguments of current method --->
    <cfif req_arguments.recordCount gt 0>
    	<i>Required arguments:</i><br />
        <cfset tmp_hint="no hint">
        <cfif isDefined("opt_arguments.hint")>
        	<cfif opt_arguments.hint neq "">
            	<cfset tmp_hint=opt_arguments.hint>
            </cfif>
        </cfif>
		<cfoutput query="req_arguments">
        ::#req_arguments.name# (#req_arguments.type#) (<i>#tmp_hint#</i>)<br />
        </cfoutput>
    </cfif>
    <cfif opt_arguments.recordCount gt 0>
    	<i>Optional arguments:</i><br />
        <cfoutput query="opt_arguments">
        <cfset tmp_hint="no hint">
        <cfif isDefined("opt_arguments.hint")>
        	<cfif opt_arguments.hint neq "">
            	<cfset tmp_hint=opt_arguments.hint>
            </cfif>
        </cfif>
        <cfif isDefined("opt_arguments.default")>
        	<cfif opt_arguments.default neq "">
	        ::#opt_arguments.name# (default=#opt_arguments.default# (#opt_arguments.type#)) (<i>#tmp_hint#</i>)<br />
            <cfelse>
	        ::#opt_arguments.name# (#opt_arguments.type#) (<i>#tmp_hint#</i>)<br />
            </cfif>
        <cfelse>
	        ::#opt_arguments.name# (#opt_arguments.type#) (<i>#tmp_hint#</i>)<br />
        </cfif>
        </cfoutput>
    </cfif>
    <br />
</cfloop>
<hr/><br />
<!---
<b>Example 2:</b><br />
Get all main links from www.getrailo.org:<br />
<cfset parser=CreateObject("component","sparser2").init("http://www.getrailo.org")>
<cfset menu=parser.selector("ul##navPrimary a").query()>
<cfdump var="#menu#" label="Getrailo.org main menu links"/>
--->
</body>
</html>