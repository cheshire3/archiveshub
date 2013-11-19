<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c3="http://www.cheshire3.org"
    version="1.0">

    <!--
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="text" media-type="text/plain"
        encoding="utf-8" />

    <!--
    A default catchall template to ignore anything not specifically included
    -->
    <xsl:template match="*"/>

    <xsl:template match="/ead">
        <xsl:apply-templates select="/ead/archdesc/did" />
    </xsl:template>

    <xsl:template match="/c3component|/c3:component">

        <xsl:param name="parent-identifier">
            <xsl:choose>
                <xsl:when test="local-name() = 'component' and starts-with(/*/@c3:parent, 'LxmlRecord-')">
                    <xsl:value-of select="substring-after(/*/@c3:parent, 'LxmlRecord-')" />
                </xsl:when>
                <xsl:when test="local-name() = 'component'">
                    <xsl:value-of select="substring-after(/*/@c3:parent, '/')" />
                </xsl:when>
                <xsl:when test="local-name() = 'c3component' and starts-with(/*/@parent, 'LxmlRecord-')">
                    <xsl:value-of select="substring-after(/*/@parent, 'LxmlRecord-')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after(/*/@parent, '/')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <xsl:param name="component-identifier">
            <xsl:apply-templates select="/*/*/did" />
        </xsl:param>

        <!-- normalize the whole thing -->
        <xsl:call-template name="normalize">
            <xsl:with-param name="text">
                <xsl:value-of
                    select="concat($parent-identifier, '/', $component-identifier)" />
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="did">
        <xsl:choose>
            <!-- look for a unitid with @type="persistent" -->
            <xsl:when test="unitid[@type='persistent']">
                <xsl:apply-templates select="unitid[@type='persistent'][1]" />
            </xsl:when>
            <xsl:when test="unitid[@label='Former Reference']">
                <!-- we don't want to use Former Reference... -->
                <xsl:choose>
                    <xsl:when
                        test="unitid[@label != 'Former Reference'][@countrycode and @repositorycode and @identifier]">
                        <!-- when all 3 attributes are present -->
                        <xsl:apply-templates
                            select="unitid[@label != 'Former Reference'][@countrycode and @repositorycode and @identifier][1]" />
                    </xsl:when>
                    <xsl:when
                        test="unitid[@label != 'Former Reference'][@countrycode and @repositorycode]">
                        <!-- when code attributes are present are present -->
                        <xsl:apply-templates
                            select="unitid[@label != 'Former Reference'][@countrycode and @repositorycode][1]" />
                    </xsl:when>
                    <xsl:when test="unitid[@label != 'Former Reference']">
                        <!-- take the first that isn't Former Reference -->
                        <xsl:apply-templates
                            select="unitid[@label != 'Former Reference'][1]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- ... but sometimes we have no choice but to use the Former Reference -->
                        <!-- take the first unitid period -->
                        <xsl:apply-templates select="unitid[1]" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="unitid[@countrycode and @repositorycode and @identifier]">
                        <!-- when all 3 attributes are present -->
                        <xsl:apply-templates
                            select="unitid[@countrycode and @repositorycode and @identifier][1]" />
                    </xsl:when>
                    <xsl:when test="unitid[@countrycode and @repositorycode]">
                        <!-- when code attributes are present -->
                        <xsl:apply-templates
                            select="unitid[@countrycode and @repositorycode][1]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- take the first that's there -->
                        <xsl:apply-templates select="unitid[1]" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="unitid">
        <!-- parameters to use for lowercasing and stripping space -->
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '" />
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />

        <xsl:param name="prefix">
            <xsl:choose>
                <xsl:when test="@countrycode">
                    <xsl:value-of select="@countrycode" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- Assume GB -->
                    <xsl:text>GB</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <!--
            if @repositorycode is not here, we have a real problems;
            can't reliably pattern match in XSLT
            -->
            <xsl:choose>
                <xsl:when test="string(number(@repositorycode)) = 'NaN'">
                    <xsl:value-of select="@repositorycode" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(number(@repositorycode), '#')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <xsl:param name="constructed-identifier">
            <xsl:choose>
                <xsl:when test="@identifier">
                    <!-- can simply use it -->
                    <xsl:value-of select="@identifier" />
                </xsl:when>
                <xsl:when test="starts-with(
	                               translate(
	                                   normalize-space(./text()), 
	                                   $uc, 
	                                   $lc), 
	                               translate(
	                                   normalize-space($prefix), 
	                                   $uc, 
	                                   $lc)
	                            )">
                    <!-- the value starts with countrycode repositorycode 
                        so we need to strip them -->
                    <xsl:value-of select="substring-after(
	                                           translate(
                                                   normalize-space(./text()), 
                                                   $uc, 
                                                   $lc), 
                                               translate(
                                                   normalize-space($prefix),
                                                   $uc,
                                                   $lc)
                                          )" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="normalize">
                        <xsl:with-param name="text" select="./text()" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <!-- normalize the whole thing -->
        <xsl:call-template name="normalize">
            <xsl:with-param name="text">
                <xsl:choose>
                    <xsl:when
                        test="name(./../../..) = 'c3component' or name(./../../..) = 'c3:component'">
                        <!-- use only the constructed part for components -->
                        <xsl:value-of select="$constructed-identifier" />
                    </xsl:when>
                    <xsl:when test="string-length($prefix)">
                        <xsl:value-of
                            select="concat($prefix, '-', $constructed-identifier)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- have to use only the constructed identifier 
                            and hope for the best ... :( -->
                        <xsl:value-of select="$constructed-identifier" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="normalize">
        <!--
        Template to call to do normalization. Does not handle character
        entities
        -->
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '" />
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:param name="text" />
        <xsl:value-of select="translate(normalize-space($text), $uc, $lc)" />
    </xsl:template>

</xsl:stylesheet>
