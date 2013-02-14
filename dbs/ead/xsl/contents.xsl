<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all #default xhtml c3"
    version="1.0">

    <!--
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="xml" omit-xml-declaration="yes" />
    <xsl:preserve-space elements="*" />
    <!-- <xsl:output method="html" indent="yes"/> -->

    <!-- templates for Table of Contents (toc) -->
    <xsl:template name="toc" xsl:exclude-result-prefixes="#all #default xhtml c3">
        <div class="toclist" >
            <h2>
                <xsl:text>Contents&#160;</xsl:text>
                <span class="printlink">
                    <a href="SCRIPT/toc.html?recid=RECID">
                        <xsl:text>[ printable ]</xsl:text>
                    </a>
                </span>
            </h2>
            <strong>
                <xsl:call-template name="toc-link">
                    <xsl:with-param name="node"
                        select="/ead/archdesc/did" />
                </xsl:call-template>
            </strong>
            <ul id="someId" class="hierarchy">
                <xsl:apply-templates select="/ead/archdesc/dsc"
                    mode="toc" />
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="dsc" mode="toc">
        <xsl:for-each select="c|c01">
            <xsl:if test="not(./@audience and ./@audience = 'internal')">
                <li>
                    <xsl:call-template name="toc-c" />
                </li>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="toc-c"
        match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
        <xsl:call-template name="toc-link">
            <xsl:with-param name="node" select="./did" />
        </xsl:call-template>
        <xsl:if test="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
            <ul class="hierarchy">
                <xsl:for-each
                    select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
                    <xsl:if
                        test="not(./@audience and ./@audience = 'internal')">
                        <li>
                            <xsl:call-template name="toc-c" />
                        </li>
                    </xsl:if>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template name="toc-link">
        <xsl:param name="node" />
        <a>
            <xsl:attribute name="href">
                <xsl:text>PAGE#</xsl:text>
                <xsl:choose>
                    <xsl:when test="$node/../@id">
                        <xsl:value-of select="$node/../@id" />
                    </xsl:when>
                    <xsl:when test="$node/@id">
                        <xsl:value-of select="$node/@id" />
                    </xsl:when>
                    <xsl:when test="$node/unitid/@id">
                        <xsl:value-of select="$node/unitid/@id" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id($node)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="onclick">
                <xsl:text>setCookie('RECID-tocstate', stateToString('someId'))</xsl:text>
            </xsl:attribute>
            <xsl:if test="$node/unitid">
                <xsl:choose>
                    <xsl:when test="$node/unitid[@type='persistent']">
                        <xsl:value-of select="$node/unitid[@type='persistent']" />
                    </xsl:when>
                    <xsl:when test="$node/unitid[@label='Former Reference']">
                        <xsl:value-of
                            select="$node/unitid[@label != 'Former Reference']" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$node/unitid[1]" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$node/unittitle">
                    <xsl:value-of select="$node/unittitle" />
                </xsl:when>
                <xsl:when
                    test="$node/../../eadheader/filedesc/titlestmt/titleproper">
                    <xsl:value-of
                        select="$node/../../eadheader/filedesc/titlestmt/titleproper" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(untitled)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>

</xsl:stylesheet>
