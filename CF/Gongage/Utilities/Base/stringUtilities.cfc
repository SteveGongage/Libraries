<!--- =========================================================================================================
	Created:		Steve Gongage (4/08/2013)
	Purpose:		String Utilities

	Usage:			

========================================================================================================= --->
<cfcomponent extends="cf.Gongage.utilities.LibraryBase">
	
	<!--- ================================================================================================ --->
	<!--- Properties --->
	

	
	<!--- ================================================================================================ --->
	<!--- Functions --->



	
	<!---============================================================================================== --->
	<cffunction name="parseInt">
		<cfargument name="input" type="string">
		<cfset var i = 0>
		<cfset var output = "">
		<cfloop from="1" to="#len(input)#" index="i">
			<cfset curr = mid(input, i, 1)>
			<cfif isNumeric(curr)>
				<cfset output &= curr>
			</cfif>
			
		</cfloop>
		
		<cfreturn output>
	</cffunction>

	
	<!---============================================================================================== --->
	<cffunction name="encodeTemporaryValue" access="public" returntype="string" output="no">
		<cfargument name="value" 		required="yes"	type="string">
		<cfargument name="expiresOn"	required="no" 	default="#dateAdd('h', 1, now())#" type="date">
		
		<cfset var returnData 	= ''>
		<cfset var expirationString = dateformat(arguments.expiresOn, 'yyyymmdd') & timeformat(arguments.expireson, 'HHmm')>
		
		<cfset returnData = 	hash(arguments.value)>
		<cfset returnData &= 	hash(expirationString)>
		<cfset returnData &= 	expirationString>
		<cfset returnData &= 	arguments.value>
		
		<cfreturn returnData>
	</cffunction>

	<!---============================================================================================== --->
	<cffunction name="decodeTemporaryValue" access="public" returntype="string" output="no">
		<cfargument name="dataIn"		required="yes" type="string">
		
		<cfset var returnValue 	= "">
		<cfset var data 		= structnew()>
		<cfset data.input			= arguments.dataIn>
		<cfset data.isValidHash		= false>
		<cfset data.isValidDate		= false>
		<cfset data.isConfirmed		= false>
		<cfset data.expiresOn		= now()>
		<cfset data.hashedValue		= "">
		<cfset data.hashedDate		= "">
		<cfset data.plainDate		= "">
		<cfset data.plainValue		= "">
		
		<cfif len(dataIn) GE 77>
			<cfset data.hashedValue		= mid(dataIn, 1, 32)>
			<cfset data.hashedDate		= mid(dataIn, 33, 32)>
			<cfset data.plainDate		= mid(dataIn, 65, 12)>
			<cfset data.plainValue		= mid(dataIn, 77, len(dataIn) - 76)>
			
			<cfif 		hash(data.plainValue) 	IS data.hashedValue 
					AND hash(data.plainDate) 	IS data.hashedDate>
				<cfset data.isValidHash	= true>
			</cfif>
	
			<cfif isNumeric(data.plainDate)>
				<cftry>
					<cfset data.expiresOn = createDateTime(mid(data.plainDate, 1, 4), mid(data.plainDate, 5, 2), mid(data.plainDate, 7, 2), mid(data.plainDate, 9, 2), mid(data.plainDate, 11, 2), 59)>
					<cfif dateCompare(data.expiresOn, now()) GE 0>
						<cfset data.isValidDate = true>
					</cfif>
					<cfcatch type="any">
						<cfset data.isValidDate = false>
					</cfcatch>
				</cftry>
			</cfif>
			
			<cfset data.isConfirmed = data.isValidHash AND data.isValidDate>
			
			<cfif data.isConfirmed>
				<cfset returnValue = data.plainValue>	
			</cfif>
		</cfif>
		
		<cfset request.decodeResults = data>	<!--- output the decode results just in case they are needed --->
		<cfreturn returnValue>	
	</cffunction>	
	


	<!--------------------------------------
		A Temp ID is a 32 char hash of today's date in mm-dd-yyyy format and an n length integer representing the ID of the user.  
			- 32 char hash of the user's idUser value
			- 32 char hash of today's date
			- n length integer for the user's idUser value
	--------------------------------------->
	<cffunction name="encodeTemporaryID" access="public" returntype="string">
		<cfargument name="id" required="yes" type="numeric">
		
		<cfset var tempID = ''>
		<cfset var dateUsed		= '#day(now())#'& hour(now())>
		
		<cfset tempID &= hash(arguments.id)>
		<cfset tempID &= hash(dateUsed)>
		<cfset tempID &= arguments.id>
		
		<cfreturn tempID>
	</cffunction>
	<cffunction name="decodeTemporaryID" access="public" returntype="string">
		<cfargument name="encodedID" required="yes" type="string">
		<cfset var id = 0>
		<cfset var dateUsedNow 		= '#day(now())#'& hour(now())>
		<cfset var dateUsedOld		= '#day(now())#'& hour(now()) - 1>
		
		<cfset var decoding = structnew()>
		<cfif len(encodedID) GT 64>
			<cfset decoding.id				= right(encodedID, len(encodedID) - 64)>
			<cfset decoding.idHash 			= left(encodedID, 32)>
			<cfset decoding.idHash_valid 	= hash(decoding.id)>
			<cfset decoding.dateHash		= mid(encodedID, 33, 32)>
			<cfset decoding.dateHash_valid 	= hash(dateUsedNow)>
			<cfset decoding.dateHash_older	= hash(dateUsedOld)>
			<cfset decoding.validated		= false>
			<cfif decoding.idHash IS decoding.idHash_valid>
				<cfif 		decoding.dateHash IS decoding.dateHash_valid>
					<!--- If the date hash is exactly correct --->
					<cfset decoding.validated = true>
					<cfset id = decoding.id>
				<cfelseif	decoding.dateHash IS decoding.dateHash_older>
					<!--- If the date hash was correct last hour (just in case encoding and decoding happen on the transition between 2 hours) --->
					<cfset decoding.validated = true>
					<cfset id = decoding.id>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn id>
	</cffunction>



	<cfscript>

/** ------------------------------------------------------------------------------------------------------
	  Computes the Levenshtein distance between two strings.
	  
	 * @param s      First string. (Required)
	 * @param t      Second string. (Required)
	 * @return Returns a number. 
	 * @author Nicholas Zographos (nicholas@nezen.net) 
	 * @version 1, March 15, 2004 
	 * @url http://www.cflib.org/index.cfm?event=page.udfbyid&udfid=1067
	 */
	function levDistance(s,t) {
	    var d = ArrayNew(2);
	    var i = 1;
	    var j = 1;
	    var s_i = "A";
	    var t_j = "A";
	    var cost = 0;
	    
	    var n = len(s)+1;
	    var m = len(t)+1;
	    
	    d[n][m]=0;
	    
	    if (n is 1) {
	        return m;
	    }
	    
	    if (m is 1) {
	        return n;
	    }
	    
	     for (i = 1; i lte n; i=i+1) {
	      d[i][1] = i-1;
	    }

	    for (j = 1; j lte m; j=j+1) {
	      d[1][j] = j-1;
	    }
	    
	    for (i = 2; i lte n; i=i+1) {
	      s_i = Mid(s,i-1,1);

	      for (j = 2; j lte m; j=j+1) {
	          t_j = Mid(t,j-1,1);

	        if (s_i is t_j) {
	          cost = 0;
	        }
	        else {
	          cost = 1;
	        }
	        d[i][j] = min(d[i-1][j]+1, d[i][j-1]+1);
	        d[i][j] = min(d[i][j], d[i-1][j-1] + cost);
	      }
	    }
	    
	    return d[n][m];
	}



/** ------------------------------------------------------------------------------------------------------
		StringSimilarity
		Brad Wood
		brad@bradwood.com
		May 2007
		Code adopted from Siderite Zackwehdex's Blog
			http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html

		URL: http://www.codersrevolution.com/index.cfm/2008/7/29/ColdFusion-Levenshtein-Distance-String-comparison-and-highlighting

		Parameters:
			s1:			First string to be compared
			s2:			Second string to be compared
			maxOffset:	Average number of characters that s1 will deviate from s2 at any given point.
						This is used to control how far ahead the function looks to try and find the 
						end of a peice of inserted text.  Play with it to suit.

	*/

    function similarity(s1,s2,maxOffset)
        {
            var c = 0;
            var offset1 = 0;
            var offset2 = 0;
            var lcs = 0;
			// These two strings will contain the "highlighted" version
			var _s1 = createObject("java","java.lang.StringBuffer").init(javacast("int",len(s1)*3));
			var _s2 = createObject("java","java.lang.StringBuffer").init(javacast("int",len(s2)*3));
			// These chaactes will surround differences in the strings 
			// (Inserted into _s1 and _s2)
			var h1 = "<span style=""background: yellow;"">";
			var h2 = "</span>";
			var return_struct = structNew();
			// If both strings are empty 
            if (not len(trim(s1)) and not len(trim(s2)))
				{	
					return_struct.lcs = 0;
					return_struct.similarity = 1;
					return_struct.distance = 0;
					return_struct.s1 = "";
					return_struct.s2 = "";
		            return return_struct;
				}
			// If s2 is empty, but s1 isn't
            if (len(trim(s1)) and not len(trim(s2)))
				{
					return_struct.lcs = 0;
					return_struct.similarity = 0;
					return_struct.distance = len(s1);
					return_struct.s1 = h1 & s1 & h2;
					return_struct.s2 = "";
		            return return_struct;
				}
			// If s1 is empty, but s2 isn't
			else if (len(trim(s2)) and not len(trim(s1)))
				{
					return_struct.lcs = 0;
					return_struct.similarity = 0;
					return_struct.distance = len(s2);
					return_struct.s1 = "";
					return_struct.s2 = h1 & s2 & h2;
		            return return_struct;
				}
				
			// Examine the strings, one character at a time, anding at the shortest string
			// The offset adjusts for extra characters in either string.
            while ((c + offset1 lt len(s1))
                   and (c + offset2 lt len(s2)))
            {
				// Pull the next charactes out of s1 anbd s2
				next_s1 = mid(s1,c + offset1+1,iif(not c,3,1)); // First time through check the first three
				next_s2 = mid(s2,c + offset2+1,iif(not c,3,1)); // First time through check the first three
				// If they are equal
                if (compare(next_s1,next_s2) eq 0)
					{
						// Our longeset Common String just got one bigger
						lcs = lcs + 1;
						// Append the characters onto the "highlighted" version
						_s1.append(left(next_s1,1));
						_s2.append(left(next_s2,1));
					}
				// The next two charactes did not match
				// Now we will go into a sub-loop while we attempt to 
				// find our place again.  We will only search as long as
				// our maxOffset allows us to.
                else
	                {
						// Don't reset the offsets, just back them up so you 
						// have a point of reference
	                    old_offset1 = offset1;
	                    old_offset2 = offset2;
						_s1_deviation = "";
						_s2_deviation = "";
						// Loop for as long as allowed by our offset 
						// to see if we can match up again
	                    for (i = 0; i lt maxOffset; i=i+1)
	                    {
							next_s1 = mid(s1,c + offset1 + i+1,3); // Increments each time through.
							len_next_s1 = len(next_s1);
							bookmarked_s1 = mid(s1,c + offset1+1,3); // stays the same
							next_s2 = mid(s2,c + offset2 + i+1,3); // Increments each time through.
							len_next_s2 = len(next_s2);
							bookmarked_s2 = mid(s2,c + offset2+1,3); // stays the same
							
							// If we reached the end of both of the strings
							if(not len_next_s1 and not len_next_s2)
								{
									// Quit
									break;
								}
							// These variables keep track of how far we have deviated in the
							// string while trying to find our match again.
							_s1_deviation = _s1_deviation & left(next_s1,1);
							_s2_deviation = _s2_deviation & left(next_s2,1);
							// It looks like s1 has a match down the line which fits
							// where we left off in s2
	                        if (compare(next_s1,bookmarked_s2) eq 0)
		                        {
									// s1 is now offset THIS far from s2
		                            offset1 =  offset1+i;
									// Our longeset Common String just got bigger
									lcs = lcs + 1;
									// Now that we match again, break to the main loop
		                            break;
		                        }
								
							// It looks like s2 has a match down the line which fits
							// where we left off in s1
	                        if (compare(next_s2,bookmarked_s1) eq 0)
		                        {
									// s2 is now offset THIS far from s1
		                            offset2 = offset2+i;
									// Our longeset Common String just got bigger
									lcs = lcs + 1;
									// Now that we match again, break to the main loop
		                            break;
		                        }
	                    }
						//This is the number of inserted characters were found
						added_offset1 = offset1 - old_offset1;
						added_offset2 = offset2 - old_offset2;
						
						// We reached our maxoffset and couldn't match up the strings
						if(added_offset1 eq 0 and added_offset2 eq 0)
							{
								_s1.append(h1 & left(_s1_deviation,added_offset1+1) & h2);
								_s2.append(h1 & left(_s2_deviation,added_offset2+1) & h2);
							}
						// s2 had extra characters
						else if(added_offset1 eq 0 and added_offset2 gt 0)
							{
								_s1.append(left(_s1_deviation,1));
								_s2.append(h1 & left(_s2_deviation,added_offset2) & h2 & right(_s2_deviation,1));
							}
						// s1 had extra characters
						else if(added_offset1 gt 0 and added_offset2 eq 0)
							{
								_s1.append(h1 & left(_s1_deviation,added_offset1) & h2 & right(_s1_deviation,1));
								_s2.append(left(_s2_deviation,1));
							}
	                }
                c=c+1;	
            }
			// Anything left at the end of s1 is extra
			if(c + offset1 lt len(s1))
				{
					_s1.append(h1 & right(s1,len(s1)-(c + offset1)) & h2);
				}
			// Anything left at the end of s2 is extra
			if(c + offset2 lt len(s2))
				{
					_s2.append(h1 & right(s2,len(s2)-(c + offset2)) & h2);
				}
				
			// Distance is the average string length minus the longest common string
			distance = (len(s1) + len(s2))/2 - lcs;
			// Whcih string was longest?
			maxLen = iif(len(s1) gt len(s2),de(len(s1)),de(len(s2)));
			// Similarity is the distance divided by the max length
			similarity = iif(maxLen eq 0,1,1-(distance/maxLen));
			// Return what we found.
			return_struct.lcs = lcs;
			return_struct.similarity = similarity;
			return_struct.distance = distance;
			return_struct.s1 = _s1.toString(); // "highlighted" version
			return_struct.s2 = _s2.toString(); // "highlighted" version
            return return_struct;
        }


	</cfscript>

</cfcomponent>