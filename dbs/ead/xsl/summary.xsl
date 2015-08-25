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

    <!-- import common HTML templates -->
    <xsl:import href="html-common.xsl" />

    <!-- <xsl:output method="xml" omit-xml-declaration="yes"/> -->
    <!-- <xsl:preserve-space elements="*"/> -->
    <xsl:output method="html" indent="yes" />


    <!-- Strip all subordinate levels of description -->
    <xsl:template
        match="dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"
        priority="99" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <!-- for complete EAD instances -->
    <xsl:template match="ead">
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./archdesc/did" />
            <!-- finding aid metadata from <eadheader> - creator, revisions 
                etc -->
        </div>
        <div class="archdesc">
            <!-- TEMPLATES FOR MAIN BODY -->
    	    <xsl:apply-templates select="./archdesc/scopecontent|./archdesc/descgrp/scopecontent"/>
    	    <xsl:apply-templates select="./archdesc/bioghist|./archdesc/descgrp/bioghist"/>
            <!--	    <xsl:apply-templates select="./archdesc/acqinfo|./archdesc/descgrp/acqinfo"/>-->
            <xsl:apply-templates select="./archdesc/accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]|./archdesc/descgrp/accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]" />
            <xsl:apply-templates select="./archdesc/accessrestrict/legalstatus|./archdesc/descgrp/accessrestrict/legalstatus" />
            <xsl:apply-templates select="./archdesc/userestrict|./archdesc/descgrp/userestrict"/>
            <!--	    <xsl:apply-templates select="./archdesc/relatedmaterial|./archdesc/descgrp/relatedmaterial"/>-->
            <xsl:apply-templates select="./*/arrangement|./*/descgrp/arrangement" />
            <xsl:apply-templates select="./archdesc/otherfindaid|./archdesc/descgrp/otherfindaid"/>
            <xsl:apply-templates select="./*/did/abstract" />
            
            <xsl:apply-templates select="./archdesc/note[@label='archiveshub']" mode="own-section" />

            <xsl:apply-templates select="./archdesc/controlaccess|./archdesc/descgrp/controlaccess"/>
            
        </div>
        <xsl:if test="$count_subordinates_in_summary">
            <xsl:variable name="sub_count"
                select="count(./archdesc/dsc/c|./archdesc/dsc/c01)" />
            <xsl:variable name="all_count"
                select="count(//c|//c01|//c02|//c03|//c04|//c05|//c06|//c07|//c08|//c09|//c10|//c11|//c12)" />
            <div class="dsc">
                <xsl:if test="$sub_count &gt; 0">
                    <xsl:call-template name="count-subcomponents">
                        <xsl:with-param name="sub_count">
                            <xsl:value-of select="$sub_count" />
                        </xsl:with-param>
                        <xsl:with-param name="all_count">
                            <xsl:value-of select="$all_count" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </div>
        </xsl:if>
        <xsl:if test="$finding_aid_metadata">
            <xsl:apply-templates select="./eadheader" />
        </xsl:if>
    </xsl:template>

    <!-- for component records -->
    <xsl:template match="c3:component|c3component">
        <!-- links to higher levels -->
        <xsl:text>LINKTOPARENT</xsl:text>
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./*/did[1]" />
        </div>
        <!-- TEMPLATES FOR MAIN BODY -->
        <xsl:apply-templates select="./*/scopecontent|./*/descgrp/scopecontent"/>
        <xsl:apply-templates select="./*/bioghist|./*/descgrp/bioghist"/>
<!--        <xsl:apply-templates select="./*/acqinfo|./*/descgrp/acqinfo"/>-->
        <xsl:apply-templates select="./*/accessrestrict|./*/descgrp/accessrestrict"/>
        <xsl:apply-templates select="./*/userestrict|./*/descgrp/userestrict"/>
<!--        <xsl:apply-templates select="./*/otherfindaid|./*/descgrp/otherfindaid"/>-->
<!--        <xsl:apply-templates select="./*/relatedmaterial|./*/descgrp/relatedmaterial"/>-->
        <xsl:apply-templates select="./*/controlaccess|./*/descgrp/controlaccess"/>
        
        <xsl:if test="$count_subordinates_in_summary">
            <xsl:variable name="sub_count"
                select="count(./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12)" />
            <xsl:variable name="all_count"
                select="count(./c//c|./c01//c02|./c02//c03|./c03//c04|./c04//c05|./c05//c06|./c06//c07|./c07//c08|./c08//c09|./c09//c10|./c10//c11|./c11//c12)" />
            <div class="dsc">
                <xsl:if test="$sub_count &gt; 0">
                    <xsl:call-template name="count-subcomponents">
                        <xsl:with-param name="sub_count">
                            <xsl:value-of select="$sub_count" />
                        </xsl:with-param>
                        <xsl:with-param name="all_count">
                            <xsl:value-of select="$all_count" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="count-subcomponents">
        <xsl:param name="sub_count" />
        <xsl:param name="all_count" />
        <h2 class="redheading">Additional Described Material</h2>
        <p>
            <xsl:text>This record has </xsl:text>
            <b>
                <xsl:value-of select="$sub_count" />
            </b>
            <xsl:choose>
                <xsl:when test="$sub_count &gt; 1">
                    <xsl:text> further sections</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> further section</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>, describing a total of </xsl:text>
            <b>
                <xsl:value-of select="$all_count" />
            </b>
            <xsl:text> items.</xsl:text>
        </p>
        <p>
            <xsl:text>See the </xsl:text>
            <xsl:call-template name="switch-view-link" />
            <xsl:choose>
                <xsl:when test="$sub_count &gt; 1">
                    <xsl:text> to view them.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> to view it.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </p>
        <!--
        <p>
            <xsl:element name="a">
                <xsl:attribute name="href">
                      <xsl:text>SCRIPT?operation=search&amp;withinCollection=RECID&amp;cqlquery=QSTRING</xsl:text>
                      <xsl:value-of select="./@target"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_top</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:text>Repeat your search within this collection only.</xsl:text>
                </xsl:attribute>
                <xsl:text>Search within this collection</xsl:text>
            </xsl:element>
        </p>
        -->
    </xsl:template>
    
    <!--BUILDING REFS AND ANCS-->
    
    <!--
    we can't assume that this will work in Summary view so overwrite it here
    -->
    <xsl:template match="ref[@target]">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:text>DATAURL/RECID</xsl:text>
                <!-- TODO: somehow resolve to the correct page -->
                <xsl:text>#</xsl:text>
                <xsl:value-of select="./@target" />
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Go to referenced section in the Detailed Description [some sections unavailable in 'Summary' view.]</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template name="switch-view-link">
        <xsl:element name="a">
            <xsl:attribute name="class">
                <xsl:text>bgimg tip detailed</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$data_script" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$recid" />
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Go to Detailed Description.</xsl:text>
            </xsl:attribute>
            <xsl:text>Detailed Description</xsl:text>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
