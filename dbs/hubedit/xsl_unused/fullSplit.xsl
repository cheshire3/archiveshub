<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    xmlns:c3="http://www.cheshire3.org"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all #default xhtml c3"
    version="1.0">
    
    <!--
    This file was produced for the Archives Hub v3. Copyright &#169;
    2005-2013 the University of Liverpool
    -->

    <!-- import common HTML templates and ToC templates -->
    <xsl:import href="html-common.xsl" />
    <xsl:import href="contents.xsl" />

    <!--    <xsl:output method="xml" omit-xml-declaration="yes"/>-->
    <!--    <xsl:preserve-space elements="*"/>-->
    <xsl:output method="html" indent="yes" />

    <!-- root template - varies for each type of transformer -->
    <xsl:template match="/">
        <xsl:apply-templates />
        <xsl:if test="/ead/archdesc/dsc">
            <exsl:document
                href="file:///home/cheshire/install/htdocs/hubedit/tocs/foo.bar"
                method="xml" omit-xml-declaration="yes" indent="yes">
                <!-- content for this document should go here -->
                <xsl:call-template name="toc" />
            </exsl:document>
        </xsl:if>
    </xsl:template>


    <xsl:template match="/ead">
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./archdesc/did" />
        </div>
        <div class="archdesc">
            <xsl:apply-templates select="./archdesc" />
        </div>
        <!-- finding aid metadata from <eadheader> - creator, revisions etc -->
        <xsl:if test="$finding_aid_metadata">
            <xsl:apply-templates select="./eadheader" />
        </xsl:if>
        <p style="page-break-before: always" />
        <!-- DSC -->
        <xsl:apply-templates select="./archdesc/dsc" />
    </xsl:template>

    <!--DSC SECTION-->
    <xsl:template name="all-component"
        match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
        <xsl:if test="not(@audience and @audience = 'internal')">
            <xsl:if test="$horizontal_rule_between_units">
                <hr />
            </xsl:if>
            <p style="page-break-before: always" />
            <xsl:call-template name="single-component" />
        </xsl:if>
    </xsl:template>

    <xsl:template name="switch-view-link">
        <xsl:element name="a">
            <xsl:attribute name="class">
                <xsl:text>bgimg brief disabled</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$script" />
                <xsl:text>/summary.html?recid=</xsl:text>
                <xsl:value-of select="$recid" />
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Go to Brief Description.</xsl:text>
            </xsl:attribute>
            <xsl:text>Brief Description</xsl:text>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
