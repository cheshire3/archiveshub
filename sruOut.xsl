<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
    This file was produced, and released as part of Cheshire for Archives v3.x.
    Copyright &#169; 2005-2008 the University of Liverpool, all rights reserved.
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:c3="http://www.cheshire3.org"
  xsi:schemaLocation="http://www.loc.gov/ead/ead.xsd"
  version="1.0">
  
    <!-- import common HTML templates and ToC templates -->
    <xsl:import href="interopXmlOut.xsl"/>

	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
	   <xsl:apply-templates />
	</xsl:template>
    
    <xsl:param name="script" select="'/api/sru/hub'"/>
	
	<!-- Strip all audience=internal -->
	
	<!-- this isn't reliable - it returns flat text
	<xsl:template match='*[@audience="internal"]' priority="100" />
	-->
	
    <!-- ARCHREF  -->
    <xsl:template match="archref">
        <xsl:copy>
            <xsl:copy-of select="@title"/>
            <xsl:copy-of select="@target"/>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:value-of select="$script"/>
                        <xsl:text>?</xsl:text>
                        <xsl:text>operation=searchRetrieve</xsl:text>
                        <xsl:text>&amp;version=1.1</xsl:text>
                        <xsl:text>&amp;maximumRecords=1</xsl:text>
                        <xsl:text>&amp;recordSchema=ead</xsl:text>
                        <xsl:text>&amp;query=rec.identifier+exact+</xsl:text>
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner XML -->
            <xsl:apply-templates />
        </xsl:copy>
        
    </xsl:template>
    
</xsl:stylesheet>