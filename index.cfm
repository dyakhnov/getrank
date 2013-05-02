<html>

<head>
	<title>getRank! Example</title>
	<style>
		body {
			font-family: Arial;
			font-size: 80%;
		}
	</style>
</head>

<body>

<cfset getRank = createObject("component","getRank").init() />
<cfset aCheck = ListToArray("www.yahoo.com,www.msn.com,www.aol.com,www.adobe.com,www.google.com,www.yakhnov.info,www.travellerspoint.com") />

<cfloop index="i" from="1" to="#ArrayLen(aCheck)#">
	<cfoutput><a href="http://#aCheck[i]#/">#aCheck[i]#</a><br />Alexa = #getRank.getAlexaRank(aCheck[i])#, Google = #getRank.getGoogleRank(aCheck[i])#</cfoutput><br /><br /><cfflush>
</cfloop>

</body>

</html>