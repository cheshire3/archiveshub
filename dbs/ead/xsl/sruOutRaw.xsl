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
    XSLT for sending Archives Hub flavoured EAD out via SRU
    
    This file was produced for the Cheshire3 for Archives and the Archives Hub.
    Copyright &#169; 2005-2013 the University of Liverpool
    -->

    <xsl:output method="xml" omit-xml-declaration="yes" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:param name="script" select="'/api/sru/hub'" />
	
	<!-- Strip all audience=internal -->
	
	<!-- this isn't reliable - it returns flat text
	<xsl:template match='*[@audience="internal"]' priority="100" />
	-->

    <xsl:template match="*">
        <xsl:variable name="tagname" select="local-name(.)" />
        <xsl:choose>
            <xsl:when
                test="$tagname='ead' or $tagname='eadheader' or $tagname='eadid'">
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
    
    <!-- do nothing - allow the Archives Hub to resolve as it likes -->

</xsl:stylesheet>