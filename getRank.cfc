<!--- Document Information -----------------------------------------------------

Title:		getRank.cfc

Author:		Dmitry Yakhnov
Email:		dmitry@yakhnov.info

Website:	http://www.yakhnov.info/
			http://www.coldfusiondeveloper.com.au/

Purpose:	Alexa rank and Google PR library

Modification Log:

Name				Date			Version		Description
================================================================================
Dmitry Yakhnov		6/8/2007		0.1			Created

------------------------------------------------------------------------------->
<cfcomponent name="getRank" hint="Alexa rank and Google PR library">

<cfset instance = StructNew() />

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" returntype="getRank" access="public" output="false">

	<!--- Feel free to change these parameters --->
	<cfset instance.UA = "Mozilla/4.0 (compatible; GoogleToolbar  3.0.119.3-beta; Windows XP 5.1)" />
	<cfset instance.Timeout = 30 />

	<!--- Do not modify this parameter --->
	<cfset instance.stupidGoogleHash = "Mining PageRank is AGAINST GOOGLE'S TERMS OF SERVICE. Yes, I'm talking to you, scammer." />

	<cfreturn this />

</cffunction>

<cffunction name="getAlexaRank" returntype="numeric" access="public" output="false">
	<cfargument name="URL" type="string" required="true" />

	<cfset var alexaRank = -1 />
	<cfset var cfhttp = StructNew() />

	<cftry>
		<cfhttp method="get" url="http://data.alexa.com/data?cli=10&dat=snbamz&url=#URLEncodedFormat(arguments.URL)#" charset="utf-8" useragent="#instance.UA#" timeout="#instance.Timeout#" />
		<cfcatch>
			<cfset cfhttp.StatusCode = "666" />
		</cfcatch>
	</cftry>

	<cfif Find("200",cfhttp.StatusCode) and isXml(cfhttp.FileContent)>
		<cfset xmlDoc = xmlParse(cfhttp.FileContent) />
		<cfif isDefined("xmlDoc.Alexa.SD.Popularity")>
			<cfset alexaRank = xmlDoc.Alexa.SD.Popularity.XmlAttributes.Text />
		</cfif>
	</cfif>

	<cfreturn alexaRank />

</cffunction>

<cffunction name="getGoogleRank" returntype="numeric" access="public" output="false">
	<cfargument name="URL" type="string" required="true" />

	<cfset var googleRank = -1 />
	<cfset var cfhttp = StructNew() />

	<cftry>
	    <cfhttp method="get" url="http://toolbarqueries.google.com/search?client=navclient-auto&ch=8#calculateChecksum(arguments.URL)#&ie=UTF-8&oe=UTF-8&features=Rank&q=info:#arguments.URL#" charset="utf-8" useragent="#instance.UA#" timeout="#instance.Timeout#" />
		<cfcatch>
			<cfset cfhttp.StatusCode = "666" />
		</cfcatch>
	</cftry>

	<cfif Find("200",cfhttp.StatusCode) and FindNoCase("Rank",cfhttp.FileContent) eq 1>
		<cfset googleRank = Reverse(spanExcluding(Reverse(cfhttp.FileContent),":")) />
	</cfif>

	<cfreturn googleRank />

</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

<cfscript>
function hex2dec(str){
	return InputBaseN(str, 16);
}
function dec2hex(str){
	return UCase(FormatBaseN(str, 16));
}
</cfscript>

<cffunction name="toHex8" returntype="string" access="private" output="false">
	<cfargument name="inNum" type="numeric" required="true" />

	<cfif inNum lt 16>
		<cfreturn "0" & dec2hex(arguments.inNum) />
	<cfelse>
		<cfreturn dec2hex(arguments.inNum) />
	</cfif>

</cffunction>
	
<cffunction name="zeroFill" returntype="string" access="private" output="false">
	<cfargument name="a" type="string" required="true" />
	<cfargument name="b" type="string" required="true" />

	<cfset var x = createObject("java","java.math.BigInteger").init(JavaCast("string",hex2dec("40000000"))) />
	<cfset var z = createObject("java","java.math.BigInteger").init(JavaCast("string",hex2dec("80000000"))) />
	<cfset var retA = createObject("java","java.math.BigInteger").init(JavaCast("string",arguments.a)) />
	<cfset var retB = createObject("java","java.math.BigInteger").init(JavaCast("string",arguments.b)) />
	<cfset var retB1 = createObject("java","java.math.BigInteger").init(JavaCast("string",arguments.b-1)) />

	<cfif z.and(retA)>
		<cfset retA = retA.shiftRight(1) />
		<cfset retA = retA.and(z.not()) />
		<cfset retA = retA.or(x) />
		<cfset retA = retA.shiftRight(retB1.intValue()) />
	<cfelse>
		<cfset retA = retA.shiftRight(retB.intValue()) />
	</cfif>

	<cfreturn retA />

</cffunction>

<cffunction name="calculateChecksum" returntype="string" access="private" output="false">
	<cfargument name="inStr" type="string" required="true" />

	<cfset var key = 16909125 />
	<cfset var i = 0 />

	<cfloop index="i" from="0" to="#Len(arguments.inStr)-1#">
		<cfset key = BitXor(key,BitXor(Asc(Mid(instance.stupidGoogleHash,(i mod Len(instance.stupidGoogleHash))+1,1)),Asc(Mid(arguments.inStr,i+1,1)))) />
		<cfset key = BitOr(zeroFill(key,23),BitSHLN(key,9)) />
	</cfloop>

	<cfset key = toHex8(zeroFill(key,BitAnd(8,255))) & toHex8(BitAnd(key,255)) />
	
	<cfreturn key />

</cffunction>

</cfcomponent>