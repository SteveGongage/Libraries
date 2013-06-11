<cfcomponent extends="Singleton" initmethod="init">

	<cfset this.name = 'IDK!'>
		
	<cffunction name="init">
		<cfset this.name = 'wakakakaka'>
		<cfreturn super.init('testSingleton', 'request')>
	</cffunction>


</cfcomponent>