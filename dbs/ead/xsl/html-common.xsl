<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c3="http://www.cheshire3.org"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:addthis="http://www.addthis.com/help/api-spec"
    exclude-result-prefixes="#all"
    version="1.0">

    <!--
     This file was produced for the Cheshire3 for Archives and the Archives Hub.
     Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <!--
    include configurations from external file - over-rideable locally
    (i.e. in this file)
    -->
    <xsl:include href="./configuration.xsl" />

    <xsl:variable name="script" select="'SCRIPT'" />
    <xsl:variable name="data_script" select="'DATAURL'" />
    <xsl:variable name="recid" select="'RECID'" />
    <xsl:variable name="toc_cache_url" select="'TOC_CACHE_URL'" />

    <!-- Strip all audience="internal" -->
    <xsl:template match="*[@audience='internal']" priority="100" />

    <!-- DID -->
    <xsl:template match="did">
        <a>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id" />
                    </xsl:when>
                    <xsl:when test="unitid/@id">
                        <xsl:value-of select="./unitid/@id" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id(.)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </a>

        <xsl:variable name="unittitle">
            <xsl:choose>
                <xsl:when test="unittitle">
                    <xsl:apply-templates select="unittitle[1]" />
                </xsl:when>
                <xsl:when test="/ead/archdesc/did/unittitle">
                    <xsl:apply-templates select="/ead/archdesc/did/unittitle" />
                </xsl:when>
                <xsl:when test="/ead/eadheader/filedesc/titlestmt/titleproper">
                    <xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt/titleproper"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(untitled)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="unitid">
            <xsl:choose>
                <xsl:when test="unitid[@type='persistent']">
                    <xsl:apply-templates select="unitid[@type='persistent'][1]" />
                </xsl:when>
                <xsl:when test="unitid[@label='Former Reference']">
                     <xsl:apply-templates
                            select="unitid[@label != 'Former Reference'][1]"/>
                </xsl:when>
                <xsl:when test="unitid">
                    <xsl:apply-templates select="unitid[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- "what is this display?" help link -->
        <a href="http://archiveshub.ac.uk/utilitybarhelp/"
            class="helplink tip utilitybarhelp">
            <xsl:text>About this page</xsl:text>
        </a>

        <h1 class="unittitle">
            <xsl:value-of select="normalize-space($unittitle)" />
        </h1>

        <!-- call utility bar -->
        <xsl:call-template name="utilitybar">
            <xsl:with-param name="unittitle" select="normalize-space($unittitle)" />
            <xsl:with-param name="unitid" select="normalize-space($unitid)" />
            <xsl:with-param name="digital" select="boolean(./dao|..//dao)" />
            <!-- Enable search withinCollection if is a component, or has components -->
            <xsl:with-param name="withinCollection" select="boolean(/c3component|/c3:component) or boolean(//c|//c01|//c02|//c03|//c04|//c05|//c06|//c07|//c08|//c09|//c10|//c11|//c12)"/>
            <xsl:with-param name="repcode">
                <!-- determine repository code -->
                <xsl:choose>
                    <xsl:when test="string-length(unitid/@repositorycode)">
                        <xsl:value-of select="unitid/@repositorycode" />
                    </xsl:when>
                    <xsl:when
                        test="string-length(/ead/eadheader/eadid/@mainagencycode)">
                        <xsl:value-of select="/ead/eadheader/eadid/@mainagencycode" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>REPOSITORYCODE</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if
            test="./dao|../dao|../odd/dao|../scopecontent/dao|./daogrp|../daogrp|../odd/daogrp|../scopecontent/daogrp">
            <div class="daos">
                <h2 class="daohead">Digital Materials</h2>
                <xsl:apply-templates
                    select="./dao|../dao|../odd/dao|../scopecontent/dao|./daogrp|../daogrp|../odd/daogrp|../scopecontent/daogrp" />
            </div>
        </xsl:if>

        <div class="did">
            <xsl:apply-templates select="." mode="didtable" />
            <xsl:if test="processinfo">
                <xsl:apply-templates select="processinfo" />
            </xsl:if>
            <xsl:apply-templates select="note" mode="own-section" />
        </div>

    </xsl:template>

    <xsl:template match="did" mode="didtable">
        <table
            summary="Descriptive Information - core information about the described material"
            class="did">
            <xsl:if test="repository">
                <tr>
                    <td>
                        <span class="fieldname">This material is held at</span>
                    </td>
                    <td>
                        <strong>
                            <xsl:value-of select="repository[1]" />
                        </strong>
                    </td>
                </tr>
            </xsl:if>

            <tr>
                <td>
                    <span class="fieldname">Reference Number(s)</span>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="unitid">
                            <xsl:for-each select="unitid">
                                <xsl:choose>
                                    <xsl:when test="@label = 'Former Reference' or
                                                    @label = 'alternative' or
                                                    @label = 'altrefno' or
                                                    @type = 'previous' or
                                                    @label = 'former'">
                                        <!-- deal with these separately -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="position() &gt; 1">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                        <span style="font-weight: bolder">
                                            <xsl:apply-templates
                                                select="." />
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>(none)</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>

            <xsl:if test="unitid[@label='Former Reference'] or
                          unitid[@label='alternative'] or
                          unitid[@label='altrefno']">
                <tr>
                    <td>
                        <span class="fieldname">Alt. Ref. Number</span>
                    </td>
                    <td>
                        <xsl:apply-templates
                            select="unitid[@label='Former Reference']" />
                        <xsl:apply-templates
                            select="unitid[@label='alternative']" />
                        <xsl:apply-templates
                            select="unitid[@label='altrefno']" />
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="unitid[@type='previous'] or
                          unitid[@label='former']">
                <tr>
                    <td>
                        <span class="fieldname">Previous Ref. Number</span>
                    </td>
                    <td>
                        <xsl:apply-templates select="unitid[@type='previous']" />
                        <xsl:apply-templates select="unitid[@label='former']" />
                    </td>
                </tr>
            </xsl:if>

            <tr>
                <td>
                    <span class="fieldname">Dates of Creation</span>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test=".//unitdate">
                            <xsl:for-each select=".//unitdate">
                                <strong>
                                    <xsl:apply-templates
                                        select="." />
                                </strong>
                                <xsl:if test="position() &lt; last()">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <strong>
                                <xsl:text>[undated]</xsl:text>
                            </strong>
                        </xsl:otherwise>
                    </xsl:choose>

                </td>
            </tr>

            <xsl:if test="origination">
                <tr>
                    <td>
                        <span class="fieldname">Name of Creator</span>
                    </td>
                    <td>
                        <xsl:for-each select="origination">
                            <xsl:apply-templates />
                            <xsl:if test="position() &lt; last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>

                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="langmaterial|../langmaterial">
                <tr>
                    <td>
                        <span class="fieldname">Language of Material</span>
                    </td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="langmaterial">
                                <xsl:apply-templates
                                    select="langmaterial" />
                            </xsl:when>
                            <xsl:when test="../langmaterial">
                                <xsl:apply-templates
                                    select="../langmaterial" />
                            </xsl:when>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="physdesc">
                <tr>
                    <td>
                        <span class="fieldname">Physical Description</span>
                    </td>
                    <td>
                        <xsl:apply-templates select="physdesc" />
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="physloc">
                <tr>
                    <td>
                        <span class="fieldname">Location</span>
                    </td>
                    <td>
                        <xsl:value-of select="physloc" />
                    </td>
                </tr>
            </xsl:if>

        </table>
    </xsl:template>

    <!-- EADHEADER -->
    <xsl:template match="eadheader">
        <div class="cataloguinginfo">
            <h2 class="fieldhead-auto">
                <xsl:text>Cataloguing Info</xsl:text>
                <xsl:text> </xsl:text>
                <a href="#eadheader" class="jstoggle-text"></a>
            </h2>
            <div id="eadheader" class="jshide">
                <table
                    summary="Cataloguing Information - core information about this record"
                    class="eadheader">
                    <xsl:apply-templates select="filedesc" />
                    <xsl:apply-templates select="profiledesc" />
                    <xsl:apply-templates select="revisiondesc" />
                </table>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="filedesc">
        <xsl:if test="titlestmt">
            <xsl:apply-templates select="titlestmt" />
        </xsl:if>
        <xsl:if test="publicationstmt">
            <tr>
                <td class="field-name">Publication</td>
                <td class="field-value">
                    <xsl:apply-templates select="publicationstmt" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="editionstmt">
            <tr>
                <td class="field-name">Edition</td>
                <td class="field-value">
                    <xsl:apply-templates select="editionstmt" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="seriesstmt">
            <tr>
                <td class="field-name">Series</td>
                <td class="field-value">
                    <xsl:apply-templates select="seriesstmt" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="notesstmt">
            <tr>
                <td class="field-name">Notes</td>
                <td class="field-value">
                    <xsl:apply-templates select="notesstmt" />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="titlestmt">
        <!-- ignore titleproper, usually the same as title of material (unittitle) -->
        <xsl:if test="titleproper">
            <tr>
                <td class="field-name">Title</td>
                <td class="field-value">
                    <xsl:apply-templates select="titleproper" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="subtitle">
            <tr>
                <td class="field-name">Sub-title</td>
                <td class="field-value">
                    <xsl:apply-templates select="subtitle" />
                </td>
            </tr>
        </xsl:if>
        <xsl:for-each select="author">
            <tr>
                <td class="field-name">Author</td>
                <td class="field-value">
                    <xsl:apply-templates select="." />
                </td>
            </tr>
        </xsl:for-each>
        <xsl:if test="sponsor">
            <tr>
                <td class="field-name">Sponsor</td>
                <td class="field-value">
                    <xsl:apply-templates select="sponsor" />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="profiledesc">
        <xsl:if test="creation">
            <tr>
                <td class="field-name">Creation</td>
                <td class="field-value">
                    <xsl:apply-templates select="./creation" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="descrules">
            <tr>
                <td class="field-name">Descriptive Rules</td>
                <td class="field-value">
                    <xsl:apply-templates select="./descrules" />
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="langusage">
            <tr>
                <td class="field-name">Language Usage</td>
                <td class="field-value">
                    <xsl:apply-templates select="./langusage" />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="revisiondesc">
        <xsl:if test="./text()">
            <tr>
                <td class="field-name">Revisions</td>
                <td class="field-value">
                    <xsl:apply-templates />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="unitid">
        <!-- check if content starts with country code -->
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:if
            test="not(starts-with(translate(./text(), $uc, $lc), translate(./@countrycode, $uc, $lc)))">
            <xsl:value-of select="@countrycode" />
            <xsl:text> </xsl:text>
            <xsl:value-of select="@repositorycode" />
            <xsl:text> </xsl:text>
        </xsl:if>
        <span>
            <xsl:if test="./@label">
                <xsl:attribute name="title">
                   <xsl:value-of select="./@label" />
               </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </span>
    </xsl:template>

    <!-- ARCHDESC -->
    <xsl:template match="archdesc">
        <!-- TEMPLATES FOR MAIN BODY-->

        <xsl:apply-templates select="./did/abstract" />

        <xsl:apply-templates select="./scopecontent|./descgrp/scopecontent" />
        <xsl:apply-templates select="./bioghist|./descgrp/bioghist" />
        <xsl:apply-templates select="./arrangement|./descgrp/arrangement" />

        <xsl:if test="./admininfo">
            <div class="admininfo">
                <xsl:apply-templates select="./admininfo" />
            </div>
        </xsl:if>

        <xsl:if test="./add">
            <div class="add">
                <xsl:apply-templates select="./add" />
            </div>
        </xsl:if>

        <!-- ACCESS + USE RESTRICTIONS -->
        <xsl:apply-templates select="./accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]|./descgrp/accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]" />
        <xsl:apply-templates select="./accessrestrict/legalstatus|./descgrp/accessrestrict/legalstatus" />
        <xsl:apply-templates select="./userestrict|./descgrp/userestrict" />
        <xsl:apply-templates select="./phystech|./descgrp/phystech" />

        <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY -->
        <xsl:apply-templates select="./appraisal|./descgrp/appraisal" />
        <xsl:apply-templates select="./acqinfo|./descgrp/acqinfo" />
        <xsl:apply-templates select="./custodhist|./descgrp/custodhist" />
        <xsl:apply-templates select="./accruals|./descgrp/accruals" />
        <xsl:apply-templates select="./processinfo|./descgrp/processinfo" />
        <!-- USER INFO -->
        <xsl:apply-templates select="./otherfindaid|./descgrp/otherfindaid" />
        <xsl:apply-templates select="./originalsloc|./descgrp/originalsloc" />
        <xsl:apply-templates select="./altformavail|./descgrp/altformavail" />
        <xsl:apply-templates select="./relatedmaterial|./descgrp/relatedmaterial" />
        <xsl:apply-templates select="./separatedmaterial|./descgrp/separatedmaterial" />
        <!-- BIBLIOGRAPHY / CITATIONS -->
        <xsl:apply-templates select="./bibliography|./descgrp/bibliography" />
        <xsl:apply-templates select="./prefercite|./descgrp/prefercite" />
        <!-- MISCELLANEOUS -->
        <xsl:apply-templates select="./odd" />
        <!--xsl:apply-templates select="./note[@label!='archiveshub']" mode="own-section" /-->
        <xsl:apply-templates select="./note" mode="own-section" />

        <!-- CONTROLACCESS -->
        <xsl:apply-templates select="./controlaccess|./descgrp/controlaccess" />
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template match="langmaterial|langusage">
        <xsl:choose>
            <xsl:when test="not(./text())">
                <xsl:for-each select="language">
                    <xsl:apply-templates />
                    <xsl:if test="position() &lt; count(../language)">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="physdesc" mode="component">
        <xsl:if test="not.[@audience='internal']">
            <p>
                <xsl:apply-templates />
            </p>
        </xsl:if>
    </xsl:template>

    <xsl:template match="bioghist">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Administrative / Biographical History</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="scopecontent">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Scope and Content</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="arrangement">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Arrangement</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <!-- ACCESS + USE RESTRICTIONS -->
    <xsl:template match="accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Conditions Governing Access</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*[not(local-name(.)='legalstatus')]"/>
    </xsl:template>

    <xsl:template match="accessrestrict/legalstatus">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Legal Status</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../../archdesc or ../../../../c3:component or ../../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <p>
            <xsl:apply-templates />
        </p>
    </xsl:template>

    <xsl:template match="userestrict">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Conditions Governing Use</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="phystech">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Physical Characteristics and/or Technical Requirements</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>


    <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY -->
    <xsl:template match="admininfo">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Administrative Information</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>


    <xsl:template match="appraisal">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Appraisal Information</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="acqinfo">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Acquisition Information</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="custodhist">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Custodial History</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="accruals">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Accruals</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="processinfo">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Archivist's Note</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="abstract">
        <h2>About</h2>
        <p><xsl:apply-templates /></p>
    </xsl:template>
    

    <!-- USER INFO -->
    <!-- OTHER FINDING AIDS -->
    <xsl:template match="otherfindaid">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Other Finding Aids</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <!-- ORIGINAL + ALTERNATIVE FORMS -->
    <xsl:template match="originalsloc">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Location of Originals</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="altformavail">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Alternative Form Available</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <!-- SEPARATED + RELATED MATERIAL -->
    <xsl:template match="relatedmaterial">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Related Material</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />

    </xsl:template>

    <xsl:template match="separatedmaterial">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Separated Material</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>


    <!-- BIBLIOGRAPHY / CITATIONS -->
    <xsl:template match="bibliography">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Bibliography</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="bibref">
                <ol>
                    <xsl:for-each select="bibref">
                        <li>
                            <xsl:apply-templates select="." />
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[local-name()!='head']" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="prefercite">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text>Preferred Citation</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>

    <!--
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="./@render or ./@altrender">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <em>
                    <xsl:apply-templates/>
                </em>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->

    <!-- ODD -->
    <xsl:template match="odd">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
           <xsl:choose>
                <xsl:when test="head">
                    <xsl:value-of select="head" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Other Descriptive Data</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates />
    </xsl:template>


    <!-- CONTROLLED ACCESS TERMS -->
    <xsl:template match="controlaccess">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <xsl:variable name="headstring">
            <xsl:text></xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="local-name(..) = 'controlaccess'" />
            <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                <h2 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 class="fieldhead-auto">
                    <xsl:value-of select="$headstring" />
                </h3>
            </xsl:otherwise>
        </xsl:choose>

        <table class="controlaccess">

            <!-- Subjects -->
            <xsl:if test=".//subject">
                <xsl:variable name="indexName">
                    <xsl:text>Subjects</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//subject">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>dc.subject</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <!-- cross-search links -->
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <!-- Personal Names -->
            <xsl:if test=".//persname">
                <xsl:variable name="indexName">
                    <xsl:text>Personal Names</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//persname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.personalName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink" />
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <!-- Family Names -->
            <xsl:if test=".//famname">
                <xsl:variable name="indexName">
                    <xsl:text>Family Names</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//famname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>ead.familyName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink" />
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <!-- Corporate Names -->
            <xsl:if test=".//corpname">
                <xsl:variable name="indexName">
                    <xsl:text>Corporate Names</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//corpname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.corporateName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink" />
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <!-- Geographical Names -->
            <xsl:if test=".//geogname">
                <xsl:variable name="indexName">
                    <xsl:text>Geographical Names</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//geogname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.geographicName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <!-- cross search links -->
                            <xsl:if test="$link_to_googlemaps">
                                <xsl:call-template name="googlemapslink" />
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test=".//title">
                <xsl:variable name="indexName">
                    <xsl:text>Titles</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//title">
                    <tr>
                        <td>
                            <xsl:apply-templates />
                        </td>
                        <!-- cross search links -->
                        <td class="cross-search">
                            <xsl:if test="$link_to_copac">
                                <xsl:call-template name="copaclink" />
                            </xsl:if>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_amazon">
                                <xsl:call-template name="amazonlink" />
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test=".//function">
                <xsl:variable name="indexName">
                    <xsl:text>Functions</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//function">
                    <tr>
                        <td>
                            <xsl:value-of select="." />
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test=".//genreform">
                <xsl:variable name="indexName">
                    <xsl:text>Genre/Form</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//genreform">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.genreForm</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

            <xsl:if test=".//occupation">
                <xsl:variable name="indexName">
                    <xsl:text>Occupation</xsl:text>
                </xsl:variable>
                <tr>
                    <td colspan="2">
                        <h3 class="fieldhead-auto">
                            <xsl:value-of select="$indexName" />
                        </h3>
                    </td>
                </tr>
                <xsl:for-each select=".//occupation">
                    <tr>
                        <td>
                            <xsl:value-of select="." />
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>

        </table>

        <xsl:apply-templates select="controlaccess" />

    </xsl:template>

    <!-- COMPONENT -->

    <xsl:template name="single-component">
        <a>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id" />
                    </xsl:when>
                    <xsl:when test="did/@id">
                        <xsl:value-of select="did/@id" />
                    </xsl:when>
                    <xsl:when test="did/unitid/@id">
                        <xsl:value-of select="did/unitid/@id" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id(did)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </a>

        <h2 class="unittitle">
            <xsl:choose>
                <xsl:when test="did/unittitle">
                    <xsl:apply-templates select="did/unittitle" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Untitled</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </h2>

        <xsl:if
            test="./dao|./did/dao|./odd/dao|./scopecontent/dao|./daogrp|./did/daogrp|./odd/daogrp|./scopecontent/daogrp">
            <div class="daos">
                <h3 class="daohead">Digital Materials</h3>
                <xsl:apply-templates
                    select="./dao|./did/dao|./odd/dao|./scopecontent/dao|./daogrp|./did/daogrp|./odd/daogrp|./scopecontent/daogrp" />
            </div>
        </xsl:if>

        <!-- did for this component -->
        <xsl:apply-templates select="did" mode="didtable" />

        <xsl:apply-templates select="./did/abstract" />

        <xsl:apply-templates select="did/note" mode="own-section" />
        <xsl:apply-templates select="scopecontent" />
        <xsl:apply-templates select="bioghist" />
        <xsl:apply-templates select="arrangement" />

        <xsl:if test="admininfo">
            <xsl:apply-templates select="admininfo" />
        </xsl:if>

        <!-- ACCESS + USE RESTRICTIONS -->
        <xsl:apply-templates select="accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]|descgrp/accessrestrict[*[not(local-name(.)='head')][not(local-name(.)='legalstatus')]]" />
        <xsl:apply-templates select="accessrestrict/legalstatus|descgrp/accessrestrict/legalstatus" />
        <xsl:apply-templates select="userestrict|descgrp/userestrict" />
        <xsl:apply-templates select="phystech|descgrp/phystech" />
        <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY -->
        <xsl:apply-templates select="appraisal|descgrp/appraisal" />
        <xsl:apply-templates select="acqinfo|descgrp/acqinfo" />
        <xsl:apply-templates select="custodhist|descgrp/custodhist" />
        <xsl:apply-templates select="accruals|descgrp/accruals" />
        <xsl:apply-templates select="processinfo|descgrp/processinfo" />
        <!-- USER INFO -->
        <xsl:apply-templates select="otherfindaid|descgrp/otherfindaid" />
        <xsl:apply-templates select="originalsloc|descgrp/originalsloc" />
        <xsl:apply-templates select="altformavail|descgrp/altformavail" />
        <xsl:apply-templates select="relatedmaterial|descgrp/relatedmaterial" />
        <xsl:apply-templates select="separatedmaterial|descgrp/separatedmaterial" />
        <!-- BIBLIOGRAPHY / CITATIONS -->
        <xsl:apply-templates select="bibliography|descgrp/biography" />
        <xsl:apply-templates select="prefercite|descgrp/prefercite" />
        <!-- MISCELLANEOUS -->
        <xsl:apply-templates select="odd" />
        <xsl:apply-templates select="note" mode="own-section" />

        <!-- CONTROLACCESS -->
        <xsl:apply-templates select="controlaccess|descgrp/controlaccess" />

        <xsl:apply-templates
            select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" />
    </xsl:template>


    <!-- HEAD - Not displayed! -->
    <xsl:template match="head"/>

    <xsl:template match="head" mode="inline">
        <b>
            <xsl:value-of select="." />
        </b>
        <xsl:text>: </xsl:text>
    </xsl:template>


    <!-- ADDRESS -->
    <xsl:template match="address">
        <address>
            <xsl:apply-templates />
        </address>
    </xsl:template>

    <xsl:template match="addressline">
        <xsl:apply-templates />
        <xsl:text>, </xsl:text>
    </xsl:template>

    <!-- DATE -->
    <xsl:template match="date">
        <xsl:apply-templates />
    </xsl:template>

    <!-- NOTES -->
    <xsl:template match="bioghist/note">
        <b>
            <xsl:text>Bibliographic Sources</xsl:text>
        </b>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="note">
        <xsl:text>[ </xsl:text>
        <b>
            <xsl:text>Note</xsl:text>
        </b>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates mode="inline" />
        <xsl:text> ]</xsl:text>
    </xsl:template>

    <xsl:template match="note" mode="own-section">
        <xsl:if test="@audience!='internal' or not(@audience)">
            <xsl:variable name="headstring">
                <xsl:text>Note</xsl:text>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="../../archdesc or ../../../c3:component or ../../../c3component">
                    <h2 class="ead">
                        <xsl:value-of select="$headstring" />
                    </h2>
                </xsl:when>
                <xsl:otherwise>
                    <h3 class="ead">
                        <xsl:value-of select="$headstring" />
                    </h3>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>

    <!-- Simple Link -->
    <xsl:template name="simplelink">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="./@href" />
            </xsl:attribute>
            <xsl:if test="./@title">
                <xsl:attribute name="title">
                    <xsl:value-of select="./@title" />
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="./@show = 'new'">
                        <xsl:text>_new</xsl:text>
                    </xsl:when>
                    <xsl:when test="./@show = 'replace'">
                        <xsl:text>_self</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>_top</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner HTML -->
            <xsl:variable name="txt">
                <xsl:value-of select="string(.)" />
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="string(.)">
                    <xsl:value-of select="normalize-space($txt)" />
                </xsl:when>
                <xsl:when test="./@title">
                    <xsl:value-of select="./@title" />
                </xsl:when>
                <xsl:when test="./@label">
                    <xsl:value-of select="./@label" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@href" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- IMAGES-->
    <xsl:template name="image">
        <xsl:element name="img">
            <xsl:attribute name="src">
                <xsl:value-of select="./@href" />
            </xsl:attribute>
            <xsl:if test="./@title">
                <xsl:attribute name="title">
                  <xsl:value-of select="./@title" />
                   </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="./daodesc">
                        <xsl:variable name="txt">
                            <xsl:value-of select="string(./daodesc)" />
                        </xsl:variable>
                        <xsl:value-of select="normalize-space($txt)" />
                    </xsl:when>
                    <xsl:when test="./@title">
                          <xsl:value-of select="./@title" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./@href" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
        <!-- caption -->
        <xsl:apply-templates select="./daodesc" />
    </xsl:template>

    <!-- BUILDING REFS AND ANCS-->
    <xsl:template match="ref[@target]">
        <a>
            <xsl:attribute name="href">
                <xsl:text>PAGE#</xsl:text>
                <xsl:value-of select="./@target" />
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates />
        </a>
    </xsl:template>

    <!-- ARCHREF  -->
    <xsl:template match="archref">
        <xsl:element name="a">
            <xsl:if test="./@title">
                <xsl:attribute name="title">
                  <xsl:value-of select="./@title" />
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="./@show = 'new'">
                        <xsl:text>_new</xsl:text>
                    </xsl:when>
                    <xsl:when test="./@show = 'replace'">
                        <xsl:text>_self</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>_top</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when
                test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:value-of select="$data_script" />
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="@href" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner HTML -->
            <xsl:value-of select="string(.)" />
        </xsl:element>
    </xsl:template>

    <!-- EXTREFS -->
    <xsl:template match="extref">
        <xsl:call-template name="simplelink" />
    </xsl:template>
    <!-- extptr -->
    <xsl:template match="extptr">
        <xsl:choose>
            <xsl:when test="./@audience = 'internal'" />
            <xsl:when test="./@href">
                <xsl:choose>
                    <xsl:when test="@show='embed'">
                        <xsl:call-template name="image" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="simplelink" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- DAO - Digital Archival Objects -->
    <xsl:template match="dao">
        <div class="dao">
            <xsl:choose>
                <xsl:when test="./@audience = 'internal'" />
                <xsl:when test="./@href">
                    <xsl:choose>
                        <xsl:when test="@show='embed'">
                            <xsl:call-template name="image" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="simplelink" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="title">
                        <xsl:text>Location of Digital Object not provided.</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- DAOGRPs -->
    <xsl:template match="daogrp">
        <div class="dao">
            <xsl:choose>
                <xsl:when test="./@audience = 'internal'" />
                <xsl:when test="count(./daoloc) = 2 and ./daoloc/@role='thumb'">
                    <xsl:call-template name="daogrp-thumb" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="daogrp-multi" />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- DAOGRP - representing thumbnail link to main object -->
    <xsl:template name="daogrp-thumb">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="./daoloc[@role='reference']/@href" />
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>View Full Image</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="./@show='new'">
                        <xsl:text>_new</xsl:text>
                    </xsl:when>
                    <xsl:when test="./@show='replace'">
                        <xsl:text>_self</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>_blank</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="./daoloc/@role='thumb'">
                    <xsl:element name="img">
                        <xsl:attribute name="src">
                            <xsl:value-of select="./daoloc[@role='thumb']/@href" />
                        </xsl:attribute>
                        <xsl:attribute name="alt">
                            <xsl:choose>
                                <xsl:when test="./daoloc[@role='thumb']/@title">
                                    <xsl:value-of
                            select="./daoloc[@role='thumb']/@title" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Thumbnail unavailable</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                    <br />
                </xsl:when>
                <xsl:when test="./@title">
                    <xsl:value-of select="./@title" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Full image</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <!-- caption -->
        <xsl:apply-templates select="./daodesc" />
    </xsl:template>

    <!--
        DAOGRP - representing single, bundled or nested links + description
    -->
    <xsl:template name="daogrp-multi">
        <xsl:apply-templates select="./daodesc" />
        <xsl:for-each select="daoloc">
            <div class="dao">
                <xsl:choose>
                    <xsl:when test="./@audience = 'internal'" />
                    <xsl:when test="./@href">
                        <xsl:choose>
                            <xsl:when test="../@show='embed'">
                                <xsl:call-template name="image" />
                            </xsl:when>
                            <xsl:when test="./@label='thumb'">
                                <xsl:call-template name="image" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="./@href" />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:choose>
                                            <xsl:when test="../@show='new'">
                                                <xsl:text>_new</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="../@show='replace'">
                                                <xsl:text>_self</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>_blank</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="./daodesc">
                                            <xsl:value-of select="string(./daodesc)" />
                                        </xsl:when>
                                        <xsl:when test="./@title">
                                            <xsl:value-of select="./@title" />
                                        </xsl:when>
                                        <xsl:when test="../@title">
                                            <xsl:value-of select="../@title" />
                                        </xsl:when>
                                        <xsl:when test="./@label">
                                            <xsl:value-of select="./@label" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="./@href" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:for-each>
    </xsl:template>

    <!-- LINE BREAKS-->
    <xsl:template match="lb">
        <br />
    </xsl:template>

    <!-- CHANGES e.g. in revisiondesc -->
    <xsl:template match="change">
        <div>
            <xsl:apply-templates select="date" />
            <ul>
                <xsl:for-each select="item">
                    <li>
                        <xsl:apply-templates select="." />
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>

    <!-- LISTS-->
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@type='ordered'">
                <ol>
                    <xsl:for-each select="item">
                        <li>
                            <xsl:apply-templates />
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:when test="@type='unordered'">
                <ul>
                    <xsl:for-each select="item">
                        <li>
                            <xsl:apply-templates />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:when test="@type='marked'">
                <ul>
                    <xsl:for-each select="item">
                        <li>
                            <xsl:apply-templates />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:when test="@type='simple'">
                <ul type="none">
                    <xsl:for-each select="item">
                        <li>
                            <xsl:apply-templates />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:for-each select="item">
                        <li>
                            <xsl:apply-templates />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- CHRON LISTS-->
    <xsl:template match="chronlist">
        <ul>
            <xsl:for-each select="chronitem">
                <xsl:value-of select="." />
                <br />
            </xsl:for-each>
        </ul>
    </xsl:template>


    <!-- MISCELLANEOUS -->
    <xsl:template match="p">
        <xsl:if test="@id">
            <a name="{@id}">
                <xsl:text> </xsl:text>
            </a>
        </xsl:if>
        <p>
            <xsl:apply-templates />
        </p>
    </xsl:template>

    <xsl:template match="p" mode="inline">
        <!--xsl:if test="not.[@audience='internal']"-->
        <xsl:if test="not(@audience='internal')">
            <xsl:if test="@id">
                <a name="{@id}">
                    <xsl:text> </xsl:text>
                </a>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:if>
    </xsl:template>

    <xsl:template match="blockquote">
        <blockquote>
            <xsl:apply-templates />
        </blockquote>
    </xsl:template>

    <xsl:template match="defitem">
        <xsl:apply-templates />
        <xsl:text>; </xsl:text>
    </xsl:template>

    <!-- rendering/altrendering for all elements -->
    <xsl:template match="*">
        <xsl:choose>
            <!-- @render -->
            <xsl:when test="@render='bold'">
                <b>
                    <xsl:apply-templates />
                </b>
            </xsl:when>
            <xsl:when test="@render='italic'">
                <i>
                    <xsl:apply-templates />
                </i>
            </xsl:when>
            <xsl:when test="@render='underline'">
                <u>
                    <xsl:apply-templates />
                </u>
            </xsl:when>
            <xsl:when test="@render='quoted'">
                <xsl:text>&apos;</xsl:text>
                <xsl:apply-templates />
                <xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='singlequote'">
                <xsl:text>&apos;</xsl:text>
                <xsl:apply-templates />
                <xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='doublequote'">
                <xsl:text>&quot;</xsl:text>
                <xsl:apply-templates />
                <xsl:text>&quot;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='bolditalic'">
                <b>
                    <i>
                        <xsl:apply-templates />
                    </i>
                </b>
            </xsl:when>
            <xsl:when test="@render='boldunderline'">
                <b>
                    <u>
                        <xsl:apply-templates />
                    </u>
                </b>
            </xsl:when>
            <xsl:when test="@render='boldquoted'">
                <b>
                    <xsl:text>&apos;</xsl:text>
                    <xsl:apply-templates />
                    <xsl:text>&apos;</xsl:text>
                </b>
            </xsl:when>
            <xsl:when test="@render='bolddoublequote'">
                <b>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:apply-templates />
                    <xsl:text>&quot;</xsl:text>
                </b>
            </xsl:when>
            <!-- @altrender -->
            <xsl:when test="@altrender='bold'">
                <b>
                    <xsl:apply-templates />
                </b>
            </xsl:when>
            <xsl:when test="@altrender='italic'">
                <i>
                    <xsl:apply-templates />
                </i>
            </xsl:when>
            <xsl:when test="@altrender='underline'">
                <u>
                    <xsl:apply-templates />
                </u>
            </xsl:when>
            <xsl:when test="@altrender='quoted'">
                <xsl:text>&apos;</xsl:text>
                <xsl:apply-templates />
                <xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:when test="@altrender='doublequote'">
                <xsl:text>&quot;</xsl:text>
                <xsl:apply-templates />
                <xsl:text>&quot;</xsl:text>
            </xsl:when>
            <xsl:when test="@altrender='bolditalic'">
                <b>
                    <i>
                        <xsl:apply-templates />
                    </i>
                </b>
            </xsl:when>
            <xsl:when test="@altrender='boldunderline'">
                <b>
                    <u>
                        <xsl:apply-templates />
                    </u>
                </b>
            </xsl:when>
            <xsl:when test="@altrender='boldquoted'">
                <b>
                    <xsl:text>&apos;</xsl:text>
                    <xsl:apply-templates />
                    <xsl:text>&apos;</xsl:text>
                </b>
            </xsl:when>
            <xsl:when test="@altrender='bolddoublequote'">
                <b>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:apply-templates />
                    <xsl:text>&quot;</xsl:text>
                </b>
            </xsl:when>
            <xsl:when test="@altrender='italicunderline'">
                <i>
                    <u>
                        <xsl:value-of select="." />
                    </u>
                </i>
            </xsl:when>
            <xsl:when test="@altrender='italicquoted'">
                <i>
                    <xsl:text>&apos;</xsl:text>
                    <xsl:value-of select="." />
                    <xsl:text>&apos;</xsl:text>
                </i>
            </xsl:when>
            <xsl:when test="@altrender='italicdoublequote'">
                <i>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="." />
                    <xsl:text>&quot;</xsl:text>
                </i>
            </xsl:when>
            <xsl:when test="@altrender='queryTerm'">
                <xsl:element name="span">
                    <xsl:attribute name="class">
                        <xsl:text>highlight</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text>This word was a match for your search</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="id">
                        <xsl:value-of select="generate-id(.)" />
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="local-name() = 'title'">
                        <em>
                            <xsl:apply-templates />
                        </em>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template for creating utility bar -->

    <xsl:template name="utilitybar">

        <xsl:param name="unittitle" />
        <xsl:param name="unitid" />
        <xsl:param name="withinCollection" />
        <xsl:param name="digital" />
        <xsl:param name="repcode" />

        <xsl:variable name="data_uri_base">
            <xsl:value-of select="$data_script" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$recid" />
        </xsl:variable>

        <div id="utilitybar" class="bar utility">
            <!-- Switch Version (Level of detail) -->
            <ul class="detail">
                <li>
                    See the
                    <xsl:call-template name="switch-view-link" />
                    of this material
                    <xsl:text> </xsl:text>
                    <a href="http://archiveshub.ac.uk/archivedescriptions/#content"
                        title="Find out about Description" class="helplink tip">
                        <img
                            src="http://archiveshub.ac.uk/images/structure/form_tip.png"
                            alt="[?]" />
                    </a>
                </li>
                <!-- NB to re-activate search within collection, remove the
                    string "false() and " from the following line.
                -->
                <xsl:if test="false() and $withinCollection">
                    <!--  Search within description -->
                    <li class="withinCollection">
                    <xsl:element name="form">
                        <xsl:attribute name="name">
                            <xsl:text>withinsearchform</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="method">
                            <xsl:text>post</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="class">
                            <xsl:text>minisearch</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="action">
                            <xsl:value-of select="$script"/>
                            <xsl:text>/search.html</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="onsubmit">
                            <xsl:text>setCookie('archiveshub_searchform', miniFormToString(this));</xsl:text>
                        </xsl:attribute>
                        <fieldset>
                            <legend>Search within this description</legend>
                            <xsl:element name="input">
                                <xsl:attribute name="type"><xsl:text>hidden</xsl:text></xsl:attribute>
                                <xsl:attribute name="name"><xsl:text>withinCollection</xsl:text></xsl:attribute>
                                <xsl:attribute name="value">
                                    <xsl:choose>
                                        <xsl:when test="substring-after(/c3component/@parent|/c3:component/@c3:parent, '/')">
                                            <xsl:value-of select="substring-after(/c3component/@parent|/c3:component/@c3:parent, '/') "/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$recid" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </xsl:element>
                            <input type="hidden" name="fieldidx1" value="cql.anywhere||dc.description||dc.title"/>
                            <input type="hidden" name="fieldrel1" value="all/relevant/proxinfo"/>
                            <input name="fieldcont1" type="text" size="20"/>
                            <input type="hidden" name="_charset_"/>
                            <input type="hidden" name="numreq" value="20"/>
                            <input type="hidden" name="firstrec" value="1"/>
                            <input type="submit" name="submit" value="Go" class="submit"/>
                        </fieldset>
                    </xsl:element>
                    </li>
                </xsl:if>
                <br />
            </ul>
            <p>Archives described on the Archives Hub are held in repositories across the UK</p>
            <!-- Information -->
            <ul class="info">
                <li>
                    <a class="bgimg contact">
                        <xsl:attribute name="href">
                            <xsl:text>mailto:contributor_</xsl:text>
                            <xsl:value-of select="$repcode" />
                            <xsl:text>@example.com</xsl:text>
                            <xsl:text>?cc=archiveshubqueries@jiscmail.ac.uk</xsl:text>
                            <xsl:text>&amp;subject=Query via the Archives Hub about </xsl:text>
                            <xsl:value-of select="$unitid"/>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>Email the repository for more information [opens your email program]</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>Email</xsl:text>
                    </a>
                    the repository for more information
                </li>
                <li>
                    View the
                    <a class="bgimg location">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$hubmap_url" />
                            <xsl:value-of select="$repcode" />
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>View repository location in Archives Hub contributors map [opens new window]</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:text>location</xsl:text>
                    </a>
                    of the repository
                </li>
                <li>
                    More about
                    <a class="bgimg access">
                        <xsl:attribute name="href">
                            <xsl:text>http://archiveshub.ac.uk/accesstomaterials</xsl:text>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>Help on how to access these materials</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>accessing these materials</xsl:text>
                    </a>
                </li>
                <xsl:if test="$digital">
                    <li>
                        <span class="bgimg digital"
                            title="This description contains links to digital material. This may be further down in the Detailed Description.">
                            <xsl:text>Digital material</xsl:text>
                        </span>
                        <xsl:text> </xsl:text>
                        <a
                            href="http://archiveshub.ac.uk/displayhelp/#digitalmaterial"
                            title="Find out about Digital Material" class="helplink tip">
                            <img
                                src="http://archiveshub.ac.uk/images/structure/form_tip.png"
                                alt="[?]" />
                        </a>
                    </li>
                </xsl:if>
            </ul>

            <!-- Actions -->
            <ul class="actions" id="addright">

                <li>
                    <a class="bgimg tip email">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$script" />
                            <xsl:text>/email.html?recid=</xsl:text>
                            <xsl:value-of select="$recid" />
                            <xsl:text>#rightcol</xsl:text>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>Send detailed description as text in an e-mail</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>Email</xsl:text>
                    </a>
                    this Description
                </li>
                <li>
                    <a class="bgimg tip xml">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$data_uri_base" />
                            <xsl:text>.xml</xsl:text>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>View this description as XML (In EAD Schema)</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>View XML</xsl:text>
                    </a>
                    <xsl:text>   |   </xsl:text>

                    <a class="bgimg tip text" rel="nofollow">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$data_uri_base" />
                            <xsl:text>.pdf</xsl:text>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>View this description as PDF</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>View PDF</xsl:text>
                    </a>
                    <xsl:text>   |   </xsl:text>

                    <a class="bgimg tip text">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$data_uri_base" />
                            <xsl:text>.txt</xsl:text>
                        </xsl:attribute>
<!--                         <xsl:attribute name="title"> -->
<!--                             <xsl:text>View this description as Plain-Text</xsl:text> -->
<!--                         </xsl:attribute> -->
                        <xsl:text>View Text</xsl:text>
                    </a>
                </li>

                <li>
                    <!-- AddThis Button BEGIN -->
                    <div class="addthis_toolbox addthis_default_style ">
                        <xsl:attribute name="addthis:url">
                           <xsl:value-of select="$data_uri_base" />
                       </xsl:attribute>
                        <xsl:if test="$unittitle != '(untitled)'">
                            <xsl:attribute name="addthis:title">
                                <xsl:value-of select="normalize-space($unittitle)" />
                            </xsl:attribute>
                        </xsl:if>
                        <a class="addthis_button_twitter" />
                        <a class="addthis_button_facebook" />
                        <a class="addthis_button_email" />
                        <a class="addthis_button_favorites" />
                        <a class="addthis_button_compact" />
                        <a class="addthis_counter addthis_bubble_style" />
                    </div>
                    <script>
                        var addthis_config = {
                        ui_cobrand: 'archiveshub.ac.uk',
                        ui_header_color: '#24205c',
                        ui_header_background: '#b7e8f5',
                        services_exclude: 'print'
                        }

                        var addthis_share =
                        {
                        templates: {
                        twitter: '{{title}} {{lurl}} via @archiveshub'
                        }
                        }
                    </script>
                    <script type="text/javascript"
                        src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4eb3f45910f0a240" />
                    <!-- AddThis Button END -->
                </li>

            </ul>

        </div>
    </xsl:template>


    <!-- Template for making string cgi link friendly -->
    <xsl:template name="cgiencode">
        <xsl:param name="text" />
        <xsl:call-template name="replace-substring">
            <xsl:with-param name="original">
                <xsl:call-template name="replace-substring">
                    <xsl:with-param name="original">
                        <!-- following line contains a weird invisible character
                            propably a Windows \r\n or something! -->
                        <xsl:value-of
                            select="translate(normalize-space($text),'  ', '++')" />
                    </xsl:with-param>
                    <xsl:with-param name="substring">
                        <xsl:text>THGLHGH</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="replacement">
                        <xsl:text></xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="substring">
                <xsl:text>HGHLGHT</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="replacement">
                <xsl:text></xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Template for making string Wikipedia friendly -->
    <xsl:template name="wikipediacgiencode">
        <xsl:param name="text" />
        <xsl:call-template name="replace-substring">
            <xsl:with-param name="original">
                <xsl:call-template name="replace-substring">
                    <xsl:with-param name="original">
                        <xsl:value-of
                            select="translate(normalize-space($text),' ', '_')" />
                    </xsl:with-param>
                    <xsl:with-param name="substring">
                        <xsl:text>THGLHGH</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="replacement">
                        <xsl:text></xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="substring">
                <xsl:text>HGHLGHT</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="replacement">
                <xsl:text></xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- template to carry out recursive string replacements -->
    <xsl:template name="replace-substring">
        <xsl:param name="original" />
        <xsl:param name="substring" />
        <xsl:param name="replacement" select="''" />
        <xsl:variable name="first">
            <xsl:choose>
                <xsl:when test="contains($original, $substring)">
                    <xsl:value-of select="substring-before($original, $substring)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$original" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="middle">
            <xsl:choose>
                <xsl:when test="contains($original, $substring)">
                    <xsl:value-of select="$replacement" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="last">
            <xsl:choose>
                <xsl:when test="contains($original, $substring)">
                    <xsl:choose>
                        <xsl:when
                            test="contains(substring-after($original, $substring), $substring)">
                            <xsl:call-template name="replace-substring">
                                <xsl:with-param name="original">
                                    <xsl:value-of
                                        select="substring-after($original, $substring)" />
                                </xsl:with-param>
                                <xsl:with-param name="substring">
                                    <xsl:value-of select="$substring" />
                                </xsl:with-param>
                                <xsl:with-param name="replacement">
                                    <xsl:value-of select="$replacement" />
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="substring-after($original, $substring)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text></xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($first, $middle, $last)" />
    </xsl:template>


    <!--
        template for constructing browse links, given the name of the index to
        browse
    -->
    <xsl:template name="browselink">
        <xsl:param name="index" />
        <xsl:param name="indexName" />
        <a>
            <xsl:attribute name="href">
            <xsl:value-of select="$script" />
            <xsl:text>/browse.html</xsl:text>
            <xsl:text>?</xsl:text>
            <xsl:text>&amp;fieldidx1=</xsl:text>
            <xsl:value-of select="$index" />
            <xsl:text>&amp;fieldcont1=</xsl:text>
            <xsl:call-template name="cgiencode">
              <xsl:with-param name="text">
                <xsl:apply-templates select="." />
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text>#leftcol</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:text>Browse </xsl:text>
            <xsl:value-of select="$indexName" />
            <xsl:text> index</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>ajax</xsl:text>
          </xsl:attribute>
            <xsl:apply-templates select="." />
        </a>
    </xsl:template>

    <xsl:template name="amazonlink">
        <a target="_new">
            <xsl:attribute name="href">
                <xsl:value-of select="$amazon_search_url" />
                  <xsl:call-template name="cgiencode">
                  <xsl:with-param name="text">
                    <xsl:apply-templates select="." />
                  </xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Search Amazon</xsl:text>
            </xsl:attribute>
            <img alt="Amazon">
                <xsl:attribute name="src">
                    <xsl:value-of select="$amazon_search_icon" />
                </xsl:attribute>
            </img>
          </a>
    </xsl:template>

    <xsl:template name="copaclink">
          <a target="_new">
              <xsl:attribute name="href">
                <xsl:value-of select="$copac_search_url"/>
                <xsl:text>&amp;ti=</xsl:text>
                <xsl:call-template name="cgiencode">
                    <xsl:with-param name="text">
                        <xsl:choose>
                            <xsl:when test="emph[@altrender='a' or @altrender='title']">
                                <xsl:value-of select="emph[@altrender='a' or @altrender='title']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="emph[@altrender='y']">
                    <xsl:text>&amp;date=</xsl:text>
                    <xsl:call-template name="cgiencode">
                        <xsl:with-param name="text">
                            <xsl:apply-templates select="emph[@altrender='y']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="$copac_search_link_title"/>
            </xsl:attribute>
            <!--
            <xsl:element name="img">
              <xsl:attribute name="alt">
                <xsl:text></xsl:text>
              </xsl:attribute>
              <xsl:attribute name="src">
                  <xsl:value-of select="$copac_search_icon"/>
              </xsl:attribute>
            </xsl:element>
            -->
            <xsl:text>Search for this book on Copac</xsl:text>
          </a>
    </xsl:template>

    <xsl:template name="googlemapslink">
          <a target="_new">
              <xsl:attribute name="href">
                  <xsl:value-of select="$googlemaps_search_url"/>
                  <xsl:call-template name="cgiencode">
                  <xsl:with-param name="text">
                    <xsl:choose>
                      <xsl:when test="./emph[@altrender='a']">
                          <xsl:apply-templates select="./emph[@altrender='a']"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="$googlemaps_search_link_title"/>
            </xsl:attribute>
            <img alt="Google Maps">
                <xsl:attribute name="src">
                    <xsl:value-of select="$googlemaps_search_icon"/>
                </xsl:attribute>
            </img>
          </a>
    </xsl:template>

    <xsl:template name="wikipedialink">
        <a target="_new">
              <xsl:attribute name="href">
                  <xsl:value-of select="$wikipedia_search_url"/>
                  <xsl:call-template name="wikipediacgiencode">
                  <xsl:with-param name="text">
                    <xsl:apply-templates select="." />
                  </xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Search Wikipedia</xsl:text>
            </xsl:attribute>
            <img alt="Wikipedia">
                <xsl:attribute name="src">
                    <xsl:value-of select="$wikipedia_search_icon"/>
                </xsl:attribute>
            </img>
          </a>
    </xsl:template>

      <xsl:template match="eadid" mode="tocFileName">
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:param name="text">
            <xsl:value-of select="."/>
        </xsl:param>
        <xsl:value-of select="translate(translate(normalize-space($text), ' ', ''), $uc, $lc)"/>
    </xsl:template>

    <xsl:template name="normalizeEadid">
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:param name="text"/>
        <xsl:value-of select="translate(translate(normalize-space($text), ' ', ''), $uc, $lc)"/>
    </xsl:template>

</xsl:stylesheet>
