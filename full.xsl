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
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <!-- import common HTML templates and ToC templates -->
    <xsl:import href="html-common.xsl" />
    <xsl:import href="contents.xsl" />

    <!-- <xsl:output method="xml" omit-xml-declaration="yes"/> -->
    <!-- <xsl:preserve-space elements="*"/> -->
    <xsl:output method="html" indent="yes" />

    <!-- root template - varies for each type of transformer -->
    <xsl:template match="/">
        <xsl:apply-templates />
        <xsl:if test="/ead/archdesc/dsc">
            <exsl:document
                href="file:///home/cheshire/install/htdocs/hub/tocs/foo.bar"
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
        <!-- must go before dsc, otherwise would end up on final page, of 
            maybe many! -->
        <xsl:if test="$finding_aid_metadata">
            <xsl:apply-templates select="./eadheader" />
        </xsl:if>
        <!-- DSC -->
        <div class="dsc">
            <xsl:apply-templates select="./archdesc/dsc" />
        </div>
    </xsl:template>

    <!-- for component records -->
    <xsl:template match="/c3:component">
        <!-- link to collection level -->
        <xsl:text>LINKTOPARENT</xsl:text>
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./*/did[1]" />
        </div>
        <!-- TEMPLATES FOR MAIN BODY -->
        <div class="archdesc">
            <xsl:apply-templates select="./*/did[1]/abstract" />
            <xsl:apply-templates select="./*/scopecontent" />
            <xsl:apply-templates select="./*/bioghist" />
            <xsl:apply-templates select="./*/arrangement" />
            <!-- ACCESS + USE RESTRICTIONS -->
            <xsl:apply-templates select="./*/accessrestrict" />
            <xsl:apply-templates select="./*/userestrict" />
            <xsl:apply-templates select="./*/phystech" />
            <xsl:apply-templates select="./*/physloc" />
            <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY -->
            <xsl:apply-templates select="./*/appraisal" />
            <xsl:apply-templates select="./*/acqinfo" />
            <xsl:apply-templates select="./*/custodhist" />
            <xsl:apply-templates select="./*/accruals" />
            <xsl:apply-templates select="./*/processinfo" />
            <!-- USER INFO -->
            <xsl:apply-templates select="./*/otherfindaid" />
            <xsl:apply-templates select="./*/originalsloc" />
            <xsl:apply-templates select="./*/altformavail" />
            <xsl:apply-templates select="./*/relatedmaterial" />
            <xsl:apply-templates select="./*/separatedmaterial" />
            <!-- BIBLIOGRAPHY / CITATIONS -->
            <xsl:apply-templates select="./*/bibliography" />
            <xsl:apply-templates select="./*/prefercite" />
            <!-- MISCELLANEOUS -->
            <xsl:apply-templates select="./*/odd" />
            <xsl:apply-templates select="./*/note" mode="own-section" />

            <!-- CONTROLACCESS -->
            <xsl:apply-templates select="./*/controlaccess" />
        </div>
        <div class="dsc">
            <!-- somehow match all sub-levels -->
            <xsl:apply-templates
                select="./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12" />
        </div>
    </xsl:template>

    <!-- SUBORDINATE COMPONENTS (DSC) -->
    
    <xsl:template name="all-component"
        match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
        <xsl:if test="not(@audience and @audience = 'internal')">
            <xsl:if test="$horizontal_rule_between_units">
                <hr />
            </xsl:if>
            <div class="component">
                <xsl:call-template name="single-component" />
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="switch-view-link">
        <xsl:element name="a">
            <xsl:attribute name="class">
                <xsl:text>bgimg brief</xsl:text>
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