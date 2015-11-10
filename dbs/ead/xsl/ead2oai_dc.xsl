<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    xmlns:c3="http://www.cheshire3.org"
    version="1.0">

    <!--
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="xml" />

    <!-- Strip all audience=internal -->
    <xsl:template match='//*[@audience="internal"]'
        priority="100" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="/ead">
        <oai_dc:dc>
            <!-- always insert identifier -->
            <dc:identifier>
                <xsl:apply-templates select="." mode="persistent" />
            </dc:identifier>
            <xsl:apply-templates select="archdesc/did" />
            <xsl:apply-templates select="archdesc/controlaccess/subject" />
            <xsl:apply-templates select="archdesc/scopecontent" />
            <xsl:apply-templates select="archdesc/langmaterial" />
        </oai_dc:dc>
    </xsl:template>

    <xsl:template match="/c3:component|c3component">
        <oai_dc:dc>
            <!-- always insert identifier -->
            <dc:identifier>
                <xsl:apply-templates select="." mode="comp_id" />
            </dc:identifier>
            <xsl:apply-templates select="./*/did" />
            <xsl:apply-templates select="./*/controlaccess/subject" />
            <xsl:apply-templates select="./*/scopecontent" />
            <xsl:apply-templates select="./*/langmaterial" />
        </oai_dc:dc>
    </xsl:template>

    <xsl:template match="did">
        <!-- Already been inserted ? -->
        <!--xsl:apply-templates select="./unitid"/-->
        <dc:title>
            <xsl:choose>
                <xsl:when test="./unittitle">
                    <xsl:apply-templates select="./unittitle[1]"/>
                </xsl:when>
                <xsl:when test="/ead/archdesc/did/unittitle">
                    <xsl:apply-templates select="/ead/archdesc/did/unittitle"/>
                </xsl:when>
                <xsl:when test="/ead/eadheader/filedesc/titlestmt/titleproper">
                    <xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt/titleproper"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(untitled)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </dc:title>
        <xsl:apply-templates select="./unitdate"/>
        <xsl:apply-templates select="./origination"/>
    </xsl:template>

    <!-- strip head tags - they're meaningless in Dublin Core -->
    <xsl:template match="head" />

    <xsl:template match="origination">
        <dc:creator>
            <xsl:apply-templates />
        </dc:creator>
    </xsl:template>

    <xsl:template match="unitdate">
        <dc:date>
            <xsl:apply-templates />
        </dc:date>
    </xsl:template>

    <xsl:template match="subject">
        <dc:subject>
            <xsl:apply-templates />
        </dc:subject>
    </xsl:template>

    <xsl:template match="scopecontent">
        <dc:description>
            <xsl:apply-templates />
        </dc:description>
    </xsl:template>

    <xsl:template match="langmaterial">
        <xsl:for-each select="language">
            <dc:language>
                <xsl:value-of select="." />
            </dc:language>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="normalize">
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '" />
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:param name="text" />
        <xsl:value-of select="translate(normalize-space($text), $uc, $lc)" />
    </xsl:template>

   <xsl:template match="ead" mode="persistent">
       <xsl:apply-templates select="/ead/archdesc/did" mode="persistent" />
   </xsl:template>


    <xsl:template match="did" mode="persistent">
        <xsl:choose>
            <!-- look for a unitid with @type="persistent" -->
            <xsl:when test="unitid[@type='persistent']">
                <xsl:apply-templates select="unitid[@type='persistent'][1]" mode="persistent" />
            </xsl:when>
            <xsl:when test="unitid[@label]">
                <!-- we don't want to use any Former Reference... -->
                <xsl:choose>
                    <xsl:when
                        test="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))][@countrycode and @repositorycode and @identifier]">
                        <!-- when all 3 attributes are present -->
                        <xsl:apply-templates
                            select="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))][@countrycode and @repositorycode and @identifier][1]" mode="persistent" />
                    </xsl:when>
                    <xsl:when
                        test="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))][@countrycode and @repositorycode]">
                        <!-- when code attributes are present are present -->
                        <xsl:apply-templates
                            select="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))][@countrycode and @repositorycode][1]" mode="persistent" />
                    </xsl:when>
                    <xsl:when test="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))]">
                        <!-- take the first that isn't Former Reference -->
                        <xsl:apply-templates
                            select="unitid[not(starts-with(@label, 'Former')) and not(starts-with(@label, 'former'))][1]" mode="persistent" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- ... but sometimes we have no choice but to use the Former Reference -->
                        <!-- take the first unitid period -->
                        <xsl:apply-templates select="unitid[1]" mode="persistent" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="unitid[@countrycode and @repositorycode and @identifier]">
                        <!-- when all 3 attributes are present -->
                        <xsl:apply-templates
                            select="unitid[@countrycode and @repositorycode and @identifier][1]" mode="persistent" />
                    </xsl:when>
                    <xsl:when test="unitid[@countrycode and @repositorycode]">
                        <!-- when code attributes are present -->
                        <xsl:apply-templates
                            select="unitid[@countrycode and @repositorycode][1]" mode="persistent" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- take the first that's there -->
                        <xsl:apply-templates select="unitid[1]" mode="persistent" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="unitid" mode="persistent">
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
  
    <xsl:template match="/c3component|/c3:component" mode="comp_id">

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
            <xsl:apply-templates select="/*/*/did" mode="persistent" />
        </xsl:param>

        <!-- normalize the whole thing -->
        <xsl:call-template name="normalize">
            <xsl:with-param name="text">
                <xsl:value-of
                    select="concat($parent-identifier, '/', $component-identifier)" />
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates />
    </xsl:template>


</xsl:stylesheet>
