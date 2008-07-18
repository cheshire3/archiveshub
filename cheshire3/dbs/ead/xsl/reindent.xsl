<?xml version="1.0"?>
<!--
  reindent.xsl: a poor-man's Tidy
  (produces nicely indented XML from poorly indented XML)

  Author: Mike J. Brown <mike at skew.org>
  Version: 2006-10-25
  License: None; use freely.

  This variation of the identity transform reindents the source document
  by relying on the XSLT processor to remove whitespace-only text nodes,
  then the stylesheet adds its own back in. The result is serialized
  as XML with output indenting turned off.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--Output without indenting because we're doing it ourselves-->
  <xsl:output method="xml" version="1.0" indent="no" encoding="iso-8859-1"/>

  <!--Accept an external parameter specifying whether to delete comments-->
  <xsl:param name="delete_comments" select="false()"/>

  <!--Accept an external parameter specifying the indent string (2 spaces is the default)-->
  <xsl:param name="indent_string" select="'  '"/>

  <!--Remove whitespace-only text nodes from all elements-->
  <xsl:strip-space elements="*"/>

  <!--Preserve whitespace-only text nodes in xsl:text elements-->
  <xsl:preserve-space elements="xsl:text"/>

  <!--
    Identity transform, but omit comments if $delete_comments was set,
    and add whitespace where appropriate.
  -->
  <xsl:template name="whitespace-before">
    <xsl:if test="ancestor::*">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:for-each select="ancestor::*">
      <xsl:value-of select="$indent_string"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="whitespace-after">
    <xsl:if test="not(following-sibling::node())">
      <xsl:text>&#10;</xsl:text>
      <xsl:for-each select="../ancestor::*">
        <xsl:value-of select="$indent_string"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*">
    <xsl:call-template name="whitespace-before"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:call-template name="whitespace-after"/>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:call-template name="whitespace-before"/>
    <xsl:copy/>
    <xsl:call-template name="whitespace-after"/>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:if test="not($delete_comments)">
      <xsl:call-template name="whitespace-before"/>
      <xsl:copy/>
      <xsl:call-template name="whitespace-after"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
