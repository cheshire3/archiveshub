<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    version="1.0">
    
  <xsl:output method="xml" omit-xml-declaration="yes"/>
	 <xsl:preserve-space elements="*"/>
	 
	 
	 <xsl:template match="/">
	 <ead>
	 	<xsl:copy-of select="/ead/eadheader"/>
	 	<xsl:apply-templates select="/ead/archdesc"/> 	
	 </ead>
	 </xsl:template>
	 
	 <xsl:template match="/ead/archdesc|dsc|c|c01|c02|c03|c04"> 
	 	<xsl:element name="{name()}">	
	 	   <xsl:for-each select="node()">
	 		<xsl:choose>
	 		<xsl:when test="controlaccess|dsc|c|c01|c02|c03|c04">
	 		   <!-- pass --> 
	 		</xsl:when>
	 		<xsl:otherwise>
	 			 <xsl:copy-of select="."/>
	 		</xsl:otherwise>
	 		</xsl:choose>
	 		</xsl:for-each>
	 		<xsl:copy-of select="controlaccess"/>
	 		<xsl:if test="dsc|c|c01|c02|c03|c04">
	 			<xsl:apply-templates select="dsc|c|c01|c02|c03|c04"/>	
	 		</xsl:if> 	
	 	</xsl:element>
	 </xsl:template>
	 	
<!-- <xsl:template match="dsc|c|c01|c02|c03">
	   <xsl:element name="{name()}">
	   
	 	<xsl:for-each select="node()">
	 		<xsl:choose>
	 		<xsl:when test="not(name() = 'dsc') and not(name() = 'controlaccess') and not(name() = 'c') and not(name() = 'c01') and not(name() = 'c02') and not(name() = 'c03')">
	 		    <xsl:copy-of select="."/>
	 		</xsl:when>
	 		</xsl:choose>
	 		</xsl:for-each>
	 		<xsl:copy-of select="controlaccess"/>
	 		<xsl:if test="dsc|c|c01|c02|c03">
	 		  <xsl:apply-templates select="dsc|c|c01|c02|c03"/>
	 		</xsl:if> 	
	 	</xsl:element>
	 </xsl:template>  -->	
	 
	 
	 <xsl:template match="*">      
        <xsl:apply-templates/>       
  	 </xsl:template> 
	 
</xsl:stylesheet>