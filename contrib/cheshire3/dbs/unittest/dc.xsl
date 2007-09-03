<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:cs="http://copper.ist.psu.edu/oai/oai_citeseer/"
  version="1.0">

  <xsl:template match="/">
    <oai_dc:dc>
      <xsl:apply-templates select="//cs:oai_citeseer"/>
    </oai_dc:dc>
  </xsl:template>

  <xsl:template match="cs:oai_citeseer">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dc:title">
    <dc:title>
      <xsl:value-of select="."/>
    </dc:title>
  </xsl:template>

  <xsl:template match="cs:author">
    <dc:creator>
      <xsl:value-of select="./@name"/>
    </dc:creator>
  </xsl:template>


  <xsl:template match="dc:subject">
    <dc:subject>
      <xsl:value-of select="."/>
    </dc:subject>
  </xsl:template>

  <xsl:template match="dc:description">
    <dc:description>
      <xsl:value-of select="."/>
    </dc:description>
  </xsl:template>

  <xsl:template match="dc:date">
    <dc:date>
      <xsl:value-of select="."/>
    </dc:date>
  </xsl:template>

  <xsl:template match="dc:identifier">
    <dc:identifier>
      <xsl:value-of select="."/>
    </dc:identifier>
  </xsl:template>

  <!-- ignore everything else -->
  <xsl:template match="*"/>

</xsl:stylesheet>
