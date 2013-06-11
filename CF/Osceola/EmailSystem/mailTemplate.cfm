<cfoutput>
<html>
<head>
<title>#attributes.subject#</title>
<meta http-equiv="Content-Type" content="text/html;">
<style>
	##Container {
		margin: auto; 
		width: 450px;
		min-width: 280px;
		max-width: 450px;
		font-size: 13px;
		padding: 0px;
	}
	
	##Container table 	{font-size: 13px;}
	##Container td 		{font-size: 13px; padding: 2px; margin: 0px;}
	##Container th 		{font-size: 13px; padding: 2px; margin: 0px;}
	##Header {	padding: 0px;	}
	
	##Message {	padding: 10px; color: ##333333;	font-size: 100%;}
	##Message h1 { font-size: 140%; margin: 2px; color: ##003366; text-decoration: underline; }
	##Message h2 { font-size: 130%; margin: 2px; color: ##003366; text-decoration: underline; }
	##Message h3 { font-size: 110%; margin: 2px; text-decoration: underline; }
	##Message a { color: blue; }
	##Message strong {font-style: normal; font-weight: bold; text-decoration: none; color: ##006699;}
	##Message em {font-style: italic; font-weight: normal; text-decoration: none; color: ##006699;}
</style>

</head>
<body style="background-color: ##FFFFFF;">
<div id="Container">
	<cfif attributes.showImage AND attributes.imageHREF IS NOT "">
		<img src="#attributes.imageHREF#" align="right" height="481" width="100" alt="Osceola County, Florida" style="margin:0px; border: 0px; padding: 0px;" >
	</cfif>
	
	<div id="Message">
		#attributes.message#
		<cfif attributes.showLegal>
			<br />
			<hr />
			<div id="Footer" style="font-size: 90%; margin-top: 20px;">
				<p>
					<strong>Please do not reply to this email.</strong>  
					This is an automated email and replies are automatically deleted.
					If you need to contact the county, you can reach us at our contact website: 
					<a href="http://www.osceola.org/Contact_Us/home.cfm" target="_blank">http://www.osceola.org/Contact_Us/home.cfm</a>
					or by calling the county hotline at: 407-742-2ASK (407-742-2275).
				</p>
				<p>This email was sent to you from Osceola.org, Osceola County's Official Website.  At no time will Osceola County ever ask you for a password, credit card number or any other sensitive or personal information.</p>
				<p>
					The contents of this email are intended solely  for the intended recipient.  If you are not the intended recipient of this email, please contact us through Osceola.org's online trouble report form at the following URL: 
					<a href="http://www.osceola.org/Contact_Us/home.cfm" target="_blank">http://www.osceola.org/Contact_Us/home.cfm</a>
				</p>
			</div>
		</cfif>
	</div>
</div>
</body>
</html>
</cfoutput>
