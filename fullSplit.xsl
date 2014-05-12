<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c3="http://www.cheshire3.org"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
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
        <div class="toclist" >
            <xsl:if test="/ead/archdesc/dsc">
                <xsl:call-template name="toc" />
            </xsl:if>
        </div>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="ead">
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
        <xsl:processing-instruction name="soft-break"/>
        <!-- DSC -->
        <xsl:apply-templates select="./archdesc/dsc" />
    </xsl:template>

    <!-- for component records -->
    <xsl:template match="c3:component|c3component">
        <!-- link to collection level -->
        <xsl:text>LINKTOPARENT</xsl:text>
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./*/did[1]" />
        </div>
        <!-- TEMPLATES FOR MAIN BODY -->
        <div class="archdesc">
            <xsl:apply-templates select="./*/did[1]/abstract" />
            <xsl:apply-templates
                select="./*/scopecontent|./*/descgrp/scopecontent" />
            <xsl:apply-templates select="./*/bioghist|./*/descgrp/bioghist" />
            <xsl:apply-templates
                select="./*/arrangement|./*/descgrp/arrangement" />
            <!-- ACCESS + USE RESTRICTIONS -->
            <xsl:apply-templates
                select="./*/accessrestrict|./*/descgrp/accessrestrict" />
            <xsl:apply-templates
                select="./*/userestrict|./*/descgrp/userestrict" />
            <xsl:apply-templates select="./*/phystech|./*/descgrp/phystech" />
            <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY -->
            <xsl:apply-templates select="./*/appraisal|./*/descgrp/appraisal" />
            <xsl:apply-templates select="./*/acqinfo|./*/descgrp/acqinfo" />
            <xsl:apply-templates select="./*/custodhist|./*/descgrp/custodhist" />
            <xsl:apply-templates select="./*/accruals|./*/descgrp/accruals" />
            <xsl:apply-templates
                select="./*/processinfo|./*/descgrp/processinfo" />
            <!-- USER INFO -->
            <xsl:apply-templates
                select="./*/otherfindaid|./*/descgrp/otherfindaid" />
            <xsl:apply-templates
                select="./*/originalsloc|./*/descgrp/originalsloc" />
            <xsl:apply-templates
                select="./*/altformavail|./*/descgrp/altformavail" />
            <xsl:apply-templates
                select="./*/relatedmaterial|./*/descgrp/relatedmaterial" />
            <xsl:apply-templates
                select="./*/separatedmaterial|./*/descgrp/separatedmaterial" />
            <!-- BIBLIOGRAPHY / CITATIONS -->
            <xsl:apply-templates
                select="./*/bibliography|./*/descgrp/bibliography" />
            <xsl:apply-templates select="./*/prefercite|./*/descgrp/prefercite" />
            <!-- MISCELLANEOUS -->
            <xsl:apply-templates select="./*/odd|./*/descgrp/odd" />
            <xsl:apply-templates select="./*/note|./*/descgrp/note" />

            <!-- CONTROLACCESS -->
            <xsl:apply-templates
                select="./*/controlaccess|./*/descgrp/controlaccess" />
        </div>
        <xsl:processing-instruction name="soft-break"/>
        <!-- somehow match all sub-levels -->
        <xsl:apply-templates
            select="./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12" />
    </xsl:template>

    <!--DSC SECTION -->
    
    <xsl:template name="all-component"
        match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
        <xsl:if test="not(@audience and @audience = 'internal')">
            <xsl:if test="$horizontal_rule_between_units">
                <hr />
            </xsl:if>
            <xsl:processing-instruction name="soft-break"/>
            <xsl:call-template name="single-component" />
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
