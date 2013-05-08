<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns="http://www.loc.gov/ead"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:c3="http://www.cheshire3.org"
    xsi:schemaLocation="http://www.loc.gov/ead/ead.xsd"
    version="1.0">

    <!--
    XSLT for sending EAD out via SRU
    
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="xml" omit-xml-declaration="yes"/>
    
    <!--
    include configurations from external file over-rideable locally
    (i.e. in this file)
    -->

    <xsl:include href="./configuration.xsl" />

    <xsl:variable name="script" select="'/OAI/2.0/ead'" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- Strip all audience=internal -->
    <!-- this isn't reliable - it returns flat text
    <xsl:template match='*[@audience="internal"]' priority="100" />
    -->

    <xsl:template match="*">
        <xsl:variable name="tagname" select="local-name(.)" />
        <xsl:choose>
            <xsl:when test="$tagname='ead' or $tagname='eadheader' or $tagname='eadid'">
                <xsl:copy>
                    <xsl:copy-of select="@*" />
                    <xsl:apply-templates />
                </xsl:copy>
            </xsl:when>
            <xsl:when test="./@audience='internal'" />
            <!-- namespacify cheshire3 component wrapper -->
            <xsl:when test="name(.)='c3:component' or $tagname='c3component'">
                <c3:component>
                    <xsl:if test="./@parent">
                        <xsl:attribute name="c3:parent">
                                <xsl:value-of select="./@parent" />
                            </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@xpath">
                        <xsl:attribute name="c3:xpath">
                                <xsl:value-of select="./@xpath" />
                            </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@event">
                        <xsl:attribute name="c3:event">
                                <xsl:value-of select="./@event" />
                            </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates />
                </c3:component>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*" />
                    <xsl:apply-templates />
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ARCHREF -->

    <xsl:template match="archref">
        <xsl:copy>
            <xsl:copy-of select="@title" />
            <xsl:copy-of select="@target" />
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:text>http://</xsl:text>
                        <xsl:value-of select="$host" />
                        <xsl:value-of select="$script" />
                        <xsl:text>?</xsl:text>
                        <xsl:text>verb=GetRecord</xsl:text>
                        <xsl:text>&amp;metadataPrefix=ead</xsl:text>
                        <xsl:text>&amp;identifier=</xsl:text>
                        <xsl:value-of select="@href" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner HTML -->
            <xsl:apply-templates />
        </xsl:copy>

    </xsl:template>

</xsl:stylesheet>