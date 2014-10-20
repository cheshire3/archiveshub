<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c3="http://www.cheshire3.org" version="1.0">

    <!--
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="xml" encoding="utf-8"/>

    <xsl:template match="*">
        <xsl:variable name="tagname" select="local-name(.)" />
        <xsl:element name="{$tagname}">
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>