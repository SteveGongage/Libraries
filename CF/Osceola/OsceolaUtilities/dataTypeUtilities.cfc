
<cfcomponent>

	<cffunction name="isEmail">
		<cfargument name="str" required="yes" type="string">
		<!---
			 * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
			 * Update by David Kearns to support '
			 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
			 * Should support + gmail style addresses now.
			 * More TLDs
			 * Version 4 by P Farrel, supports limits on u/h
			 * Added mobi
			 * v6 more tlds
			 * 
			 * @param str      The string to check. (Required)
			 * @return Returns a boolean. 
			 * @author Jeff Guillaume (SBrown@xacting.comjeff@kazoomis.com) 
			 * @version 7, May 8, 2009 
			 */
			function isEmail(str) {
				return (REFindNoCase("^['_a-z0-9-\+]+(\.['_a-z0-9-\+]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|asia|biz|cat|coop|info|museum|name|jobs|post|pro|tel|travel|mobi))$",
			arguments.str) AND len(listGetAt(arguments.str, 1, "@")) LTE 64 AND
			len(listGetAt(arguments.str, 2, "@")) LTE 255) IS 1;
			}
		--->
		
		<cfreturn (REFindNoCase("^['_a-z0-9-\+]+(\.['_a-z0-9-\+]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|asia|biz|cat|coop|info|museum|name|jobs|post|pro|tel|travel|mobi))$",
			arguments.str) AND len(listGetAt(arguments.str, 1, "@")) LTE 64 AND
			len(listGetAt(arguments.str, 2, "@")) LTE 255) IS 1>
			
	</cffunction>


</cfcomponent>

