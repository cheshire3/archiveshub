<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [ 
    <!ENTITY nbsp "&#160;">   <!-- white space in XSL -->
    <!ENTITY copy "&#169;">   <!-- copyright symbol in XSL -->
    ]>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &copy; 2005-2007 the University of Liverpool, all rights reserved.
-->

<xsl:stylesheet
  xmlns="http://www.loc.gov/ead"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/ead/ead.xsd"
  version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Strip all audience=internal -->
	
	<!-- this isn't reliable - it returns flat text
	<xsl:template match='*[@audience="internal"]' priority="100" />
	-->
	
	<xsl:template match="*">
		<xsl:choose>
			<xsl:when test="./@audience='internal'"/>
			<xsl:when test="name(.)='c3:component' or local-name(.)='c3component'">
				<!-- strip c3component wrapper -->
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>