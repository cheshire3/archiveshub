<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:cs="http://copper.ist.psu.edu/oai/oai_citeseer/"
  version="1.0">

  <xsl:template match="/">
    <html>
      <body>
        <table>
          <xsl:apply-templates select="//cs:oai_citeseer"/>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="cs:oai_citeseer">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dc:title">
    <tr><td>Title</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>

  <xsl:template match="cs:author">
    <tr><td>Author</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>


  <xsl:template match="dc:subject">
    <tr><td>Subject</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>

  <xsl:template match="dc:description">
    <tr><td>Abstract</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>

  <xsl:template match="dc:date">
    <tr><td>Date</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>

  <xsl:template match="dc:identifier">
    <tr><td>Identifier</td><td>
      <xsl:value-of select="."/>
    </td></tr>
  </xsl:template>

  <!-- ignore everything else -->
  <xsl:template match="*"/>

</xsl:stylesheet>
