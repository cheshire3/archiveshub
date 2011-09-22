<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
    This file was produced, and released as part of Cheshire for Archives v3.x.
    Copyright &#169; 2005-2008 the University of Liverpool, all rights reserved.
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:c3="http://www.cheshire3.org"
  xmlns="http://www.loc.gov/ead"
  xsi:schemaLocation="http://www.loc.gov/ead/ead.xsd"
  version="1.0">

    <xsl:output method="xml" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
       <xsl:apply-templates />
    </xsl:template>
    
    <xsl:param name="script" select="'/data/'"/>
    
    <!-- Strip all audience=internal -->
    
    <!-- this isn't reliable - it returns flat text
    <xsl:template match='*[@audience="internal"]' priority="100" />
    -->
    
    <xsl:template match="*">
        <xsl:variable name="tagname" select="local-name(.)"/>
        <xsl:choose>
            <xsl:when test="$tagname='ead' or $tagname='eadheader' or $tagname='eadid'">
                <xsl:element namespace="http://www.loc.gov/ead" name="{$tagname}">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates />
                </xsl:element>
            </xsl:when>
            <xsl:when test="./@audience='internal'"/>
            <!-- namespacify cheshire3 component wrapper -->
            <xsl:when test="name(.)='c3:component' or local-name(.)='c3component'">
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
            <xsl:when test="$tagname = 'persname' or
                            $tagname = 'famname' or 
                            $tagname = 'corpname' or 
                            $tagname = 'geogname' or
                            $tagname = 'subject' or 
                            $tagname = 'title'">
                <!-- namespacify EAD elements -->
                <xsl:element namespace="http://www.loc.gov/ead" name="{$tagname}">
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- namespacify EAD elements -->
                <xsl:element namespace="http://www.loc.gov/ead" name="{$tagname}">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ARCHREF  -->
    <xsl:template match="archref">
        <xsl:copy>
            <xsl:copy-of select="@title"/>
            <xsl:copy-of select="@target"/>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:value-of select="$script"/>
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner XML -->
            <xsl:apply-templates />
        </xsl:copy>
        
    </xsl:template>
  
</xsl:stylesheet>