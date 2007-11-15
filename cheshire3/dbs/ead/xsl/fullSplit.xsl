<!DOCTYPE xsl:stylesheet [ 
    <!ENTITY nbsp "&#160;">   <!-- white space in XSL -->
    <!ENTITY copy "&#169;">   <!-- copyright symbol in XSL -->
    ]>

<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &copy; 2005-2007 the University of Liverpool
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  version="1.0">
  
	<!-- import common HTML templates and ToC templates -->
	<xsl:import href="html-common.xsl"/>
	<xsl:import href="contents.xsl"/>
	  
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	<xsl:preserve-space elements="*"/>
  
	<!-- root template - varies for each type of transformer -->
	<xsl:template match="/">
		<xsl:apply-templates/>
		<xsl:if test="/ead/archdesc/dsc"> 
			<exsl:document
			  href="file:///home/cheshire/cheshire3/install/htdocs/ead/tocs/foo.bar"
			  method="html"
			  omit-xml-declaration="no"
			  indent="yes">
			    <!-- content for this document should go here -->
				<xsl:call-template name="toc"/>
			</exsl:document>
		</xsl:if>
	</xsl:template>


	<xsl:template match="/ead">
  		<div id="record-head">
			<!-- Core information about described material from <did> -->
			<xsl:apply-templates select="./archdesc/did"/>
			<!-- finding aid metadata from <eadheader> - creator, revisions etc -->
			<xsl:if test="$finding_aid_metadata">
			  <xsl:apply-templates select="./eadheader"/>
			</xsl:if>
		</div>
		<div class="archdesc">
			<xsl:apply-templates select="./archdesc" />
		</div>
	    <p style="page-break-before: always" />
	    <!-- DSC -->
		<div class="dsc">
			<xsl:apply-templates select="./archdesc/dsc"/>
		</div>
	</xsl:template>
	
 
	<!--DSC SECTION-->
	<xsl:template name="all-component" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:if test="not(@audience and @audience = 'internal')">
			<xsl:if test="$horizontal_rule_between_units">
				<hr/>    
			</xsl:if>
			<p style="page-break-before: always"/>
			<xsl:call-template name="single-component" />
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>


