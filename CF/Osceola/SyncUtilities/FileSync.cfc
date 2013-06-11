<cfcomponent>

	<cffunction name="syncFiles" access="public" returntype="struct">
		<cfargument name="files" 		type="array" required="yes">
		<cfargument name="sourceFolder" type="string" required="yes">
		<cfargument name="targetFolder" type="string" required="yes">
		
		<cfset results = structnew()>
		<cfset results.success 	= false>
		<cfset results.message	= "Nothing attempted">
		<cfset results.eventLog	= "">
		<cfset results.duration = 0>
		
		<cfset data = structnew()>
		<cfset data.startTime = now()>
		
		
		<cfif NOT directoryExists(arguments.sourceFolder)>
			
			<cfset results.message = "Could not find source folder '#arguments.sourceFolder#'">
		
		<cfelse>
			<cfif NOT directoryExists(arguments.targetFolder)>
				<cfdirectory action="create" directory="#arguments.targetFolder#">
				<cfset results.message &= "* Created target folder: '#arguments.targetFolder#'">
			</cfif>
			
			<!--- Find existing files in the target folder --->
			<cfdirectory action="list" directory="#arguments.targetFolder#" name="targetDirListing">
			
			<!--- Delete any files not in use anymore --->
			<cfloop query="targetDirListing">
				<cftry>
					<cfset currTargetFilePath = "#arguments.targetFolder#\#targetDIRListing.name#">
					<cfif NOT arrayFindNoCase(arguments.files, targetDIRListing.name) AND fileExists(currTargetFilePath)>
						<cffile action="delete" file="#currTargetFilePath#">
						<cfset results.eventLog &= "- Deleted: #targetDIRListing.name#<br />">
					</cfif>
					<cfcatch type="any">
						<cfset results.eventLog &= "* Unknown Error Copying: #currFile#<br />">
					</cfcatch>
				</cftry>
			</cfloop>
			
			<!--- Copy over any files that are missing --->
			<cfloop array="#arguments.files#" index="currFile">
				<cftry>
					<cfset currTargetFilePath = "#arguments.targetFolder#\#currFile#">
					<cfset currSourceFilePath = "#arguments.sourceFolder#\#currFile#">
					<cfif NOT fileExists(currSourceFilePath)>
						<cfset results.eventLog &= "* Missing Source: #currFile#<br />">
					<cfelseif fileExists(currTargetFilePath)>
						<!--- <cfset results.eventLog &= "= Exists: #currFile#<br />"> --->
					<cfelse>
						<cffile action="copy" source="#currSourceFilePath#" destination="#currTargetFilePath#">
						<cfset results.eventLog &= "+ Copied: #currFile#<br />">
					</cfif>
					
					<cfcatch type="any">
						<cfset results.eventLog &= "* Unknown Error Copying: #currFile#<br />">
					</cfcatch>
				</cftry>
			</cfloop>
			
			<cfset results.success = true>
			<cfset results.message = "files copied">
			
		</cfif>
		
		<cfset data.endTime = now()>
		
		<cfset results.duration = dateDiff('s', data.startTime, data.endTime)>
		
		<cfreturn results>
	</cffunction>
    
    
    <!--- Method to synchonize a source and target file set via FTP --->
    <cffunction name="syncFilesViaFTP" access="public" returntype="struct">
		<cfargument name="files" 		type="array" required="yes">
		<cfargument name="sourceFolder" type="string" required="yes">
		<cfargument name="targetFolder" type="string" required="yes">
        
        
        
		<!--- Create the Results structure --->
		<cfset results = structnew()>
		<cfset results.success 	= false>
		<cfset results.message	= "Nothing attempted">
		<cfset results.eventLog	= "">
		<cfset results.duration = 0>
		
        <!--- Create the Data structure --->
		<cfset data = structnew()>
		<cfset data.startTime = now()>
        
        <!--- Instantiate the Files To Overwrite array --->
        <cfset arrFilesToOverwrite = ArrayNew(1) />
		
        <!--- Perform a list action on the source folder --->
		<cfdirectory action="list" directory="#arguments.sourceFolder#" name="sourceDirListing" />
       
        <!--- Open the FTP Connection to Atlantis --->
        <cfftp
        	timeout="3600"
            action="open"
            secure="no"
            passive="yes"
            username="#request.global.credentials.FTP_FileStorage.username#"
            password="#request.utilities.data.OCMSDecrypt(request.global.credentials.FTP_FileStorage.passwordEncrypted)#"
            server="#request.global.credentials.FTP_FileStorage.server#"
            port="21"
            connection="FileSync" />
            
			<!--- SGON: Hardcoded username, password, and server.  I would see if we can store these in an structure in GlobalSettings.cfm and HASH the password, unhashing it here.  --->
			

		<!--- If the Source Directory doesn't exist, log the error message --->
		<cfif NOT directoryExists(arguments.sourceFolder)>
			
			<cfset results.message = "Could not find source folder '#arguments.sourceFolder#'">
            
            <!--- <cfdump var="#results#" /> --->
        
        <!--- Else, the Source Directory Exists, proceed --->
        <cfelse>
        	
            <!--- Check to see if the Target Directory Exists on the remote server --->
        	<cfftp timeout="600" retrycount="5"  name="TargetDirectoryExists" action="existsdir" directory="#arguments.targetFolder#" connection="FileSync" />
            
            <!--- If the Target Directory doesn't exists, create the directory and log the message --->
            <cfif NOT cfftp.returnvalue>
            	<cfftp timeout="600" retrycount="5" action="createdir" directory="#arguments.targetFolder#" connection="FileSync" />
                
				<cfset results.message &= "* Created target directory: '#arguments.targetFolder#'">
                <!--- <cfdump var="#results#" /> --->
			</cfif>
            
            
            <!--- BEGIN: Copy over files missing on target from source --->
            <!--- Find existing files in the target folder --->
			<cfftp timeout="3600" retrycount="5" action="listdir" directory="#arguments.targetFolder#" name="targetDirListing_DeleteRun" connection="FileSync" result="FTPList_DeleteRun" />
            
            <!--- Convert the query results to list format --->
			<cfset lsDirectoryContent 	= ValueList(sourceDirListing.Name, ",") />
            <cfset lsFTPContent			= ValueList(targetDirListing_DeleteRun.Name, ",") />
            
            <!--- Convert the lists into an array of values --->
            <cfset arDirectoryContent	= ListToArray(lsDirectoryContent) />
            <cfset arFTPContent			= ListToArray(lsFTPContent) />
            
            <!--- Remove the differences between the source and target and put them into their own list --->
            <cfset arDifferences		= arFTPContent.removeAll(arDirectoryContent) />
            
			<!---
				This list is a list of files currently on target that are not on source and should be deleted
				from target
			--->
			<cfset lsDifferences		= ArrayToList(arFTPContent) />
            
           
            <!--- BEGIN: Delete any files on target that are not on source --->
           	
            	<!--- If the list is not empty --->
				<cfif lsDifferences IS NOT "">
                	
                    <!--- Loop over the list of file differences --->
                    <cfloop list="#lsDifferences#" index="elem" delimiters=",">
                    	
                        <cfif elem IS NOT "Thumbs.db">
                        
                        	<cftry>
								<!--- Set the current Target File Path --->
                                <cfset currTargetFilePath = "#arguments.targetFolder#\#elem#">
                                
                                <!--- Delete the file from the Target Directory and log the message --->
                                <cfftp timeout="600" retrycount="5" action="remove" connection="FileSync" item="#currTargetFilePath#" result="DeleteComplete" />
                                <cfset results.eventLog &= "- Deleted: #elem#<br />">
                                <!--- If there's an issue, log it --->
                                <cfcatch>
                                    <cfset results.eventLog &= "* Unknown Error Deleting: #currTargetFilePath#<br />">
                                      
                                </cfcatch>
                            </cftry>
                        </cfif>
                                
                    </cfloop>
                </cfif>
			<!--- END: Delete any files on target that are not on source --->
             
           <!--- BEGIN: Copy over files missing on target that are on source --->  
           
		   <!--- Find existing files in the target folder --->
			<cfftp timeout="3600" retrycount="5" action="listdir" directory="#arguments.targetFolder#" name="targetDirListing_CopyRun" connection="FileSync" result="FTPList_CopyRun" />
            
            <!--- Convert the query results to list format --->
			<cfset lsDirectoryContent 	= ValueList(sourceDirListing.Name, ",") />
            <cfset lsFTPContent			= ValueList(targetDirListing_CopyRun.Name, ",") />
            
            <!--- Convert the lists into an array of values --->
            <cfset arDirectoryContent	= ListToArray(lsDirectoryContent) />
            <cfset arFTPContent			= ListToArray(lsFTPContent) />
            
            <!--- Remove the differences between the source and target and put them into their own list --->
            <cfset arDifferences		= arDirectoryContent.removeAll(arFTPContent) />
            
			<!---
				This list is a list of files currently on source that are not on target and should be copied
				from source.
			--->
			<cfset lsDifferences		= ArrayToList(arDirectoryContent) />
            
            <!--- Loop over the list of file names to be copied to target --->
            <cfloop list="#lsDifferences#" index="elem" delimiters=",">
				
                <!--- If the list is not empty, continue... --->
				<cfif lsDifferences IS NOT "">
                    
                    <!--- If the current element is not Thumbs.db, continue... --->
                    <cfif elem IS NOT "Thumbs.db">
                        
                        <cftry>
							<!--- Set the Target File Path and Source File Path --->
                            <cfset currTargetFilePath = "#arguments.targetFolder#\#elem#">
                            <cfset currSourceFilePath = "#arguments.sourceFolder#\#elem#">
                    		
                           <!--- Open the FTP connection and begin file copy to target --->
                           <cfftp
                            timeout="600" retrycount="5"
                            action="putFile"
                            localfile="#currSourceFilePath#"
                            remoteFile="#currTargetFilePath#"
                            connection="FileSync" />
                        
                        	<!--- Log the result as copied --->
                            <cfset results.eventLog &= "+ Copied: #elem#<br />">
                            
                            <!--- If there's an issue, catch it... --->
                            <cfcatch>
								
                                <!--- Log the result as not copied --->
								<cfset results.eventLog &= "* Unknown Error Copying: #currTargetFilePath#<br />">

                            </cfcatch>
                       	</cftry>
                    </cfif>
                </cfif>
            	
            </cfloop>
            <!--- END: Copy over files missing on target that are on source ---> 
            
            
            
            <!--- BEGIN: Overwrite of files that are different on target from on source --->
            <!--- Perform a list action on the source folder --->
			<cfdirectory action="list" directory="#arguments.sourceFolder#" name="sourceDirListing" />
            
            <!--- Find existing files in the target folder --->
			<cfftp timeout="3600" retrycount="5" action="listdir" directory="#arguments.targetFolder#" name="targetDirListing" connection="FileSync" result="FTPList" />
            
            <!---
				Compare the file sizes between the files in the sourceDirListing (cffile) and the files in the
				targetDirListing (cfftp) and look for files that have the same name but are different sizes.
				This will establish our file overwrite list.
			--->
            <cfquery name="qFileComparison" dbtype="query">
            	SELECT sourceDirListing.Name, sourceDirListing.Size
					FROM sourceDirListing, targetDirListing
					WHERE sourceDirListing.Size != targetDirListing.Length
						AND sourceDirListing.Name = targetDirListing.Name
						AND sourceDirListing.Type != 'Dir'
            </cfquery>
            
            <!--- If the qFileComparison Record Count is GT 0, convert it to a list and then an array --->
            <cfif qFileComparison.RecordCount GT 0>	
            
				<!--- Turn the query into a list. --->
                <cfset lsFilesToOverwrite = ValueList(qFileComparison.Name, ',') />
                
                <!--- Convert the list into an array --->
                <cfset arrFilesToOverwrite = ListToArray(lsFilesToOverwrite, ',') />
            </cfif>
			<!--- If the Files To Overwrite length is GT 0, proceed with overwriting files with size differences --->
            <cfif ArrayLen(arrFilesToOverwrite) GT 0>
                
                <!--- Loop over the Files To Overwrite array --->
                <cfloop array="#arrFilesToOverwrite#" index="currFile">
                	
                    <cftry>
						<!--- Set the Target File Path and Source File Path --->
                        <cfset currTargetFilePath = "#arguments.targetFolder#\#currFile#">
                        <cfset currSourceFilePath = "#arguments.sourceFolder#\#currFile#">
                    	
                        <!--- Put the files to the remote server --->
                        <cfftp
                        	timeout="600" retrycount="5"
                        	action="putFile"
                            localfile="#currSourceFilePath#"
                            remoteFile="#currTargetFilePath#"
                            connection="FileSync" />
                        
                        <!--- Set the event log message --->
						<cfset results.eventLog &= "+ Overwrite File: #currFile#<br />">
                        
                        <!--- <cfdump var="#results#" /> --->
                    	
                        <!--- Otherwise, there was a problem overwriting the file --->
                        <cfcatch type="any">
                        	
							<!--- Set the event log message --->
                        	<cfset results.eventLog &= "* Unknown Error Overwriting: #currFile#<br />">
                            
                            <!--- <cfdump var="#results#" /> --->
                        	<!---<cfdump var="#arguments.files#" />--->
                        </cfcatch>
                    </cftry>
                    
                </cfloop>
            </cfif>
			<!--- END: Overwrite of files that are different on target from on source --->

            <cfset results.success = true>
			<cfset results.message = "files copied">
            
         </cfif>
		
        <!--- Close the FTP Connection --->
            <cfftp 	action="close"
            		connection="FileSync"
                    stoponerror="Yes" />
                    
		<cfset data.endTime = now()>
		
		<cfset results.duration = dateDiff('s', data.startTime, data.endTime)>
		
		<cfreturn results>
	</cffunction>
</cfcomponent>