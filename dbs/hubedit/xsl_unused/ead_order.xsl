<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"
	version="1.0">

	<xsl:output 
	   method="xml" 
	   omit-xml-declaration="yes" 
	   indent="yes" 
	   encoding="ascii"
	   doctype-public="-//Society of American Archivists//DTD ead.dtd (Encoded Archival Description (EAD) Version 1.0)//EN"
	   />
	

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ead">
		<xsl:element name="ead">
			<xsl:copy-of select="@*" />		
			<xsl:copy-of select="/ead/eadheader" />
			<xsl:apply-templates select="/ead/archdesc" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="/ead/archdesc|dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:element name="{name()}">			
			<xsl:copy-of select="@*[not(name()='c3id')]"/>
			<xsl:apply-templates select="did"/>
			
			<xsl:copy-of select="dao"/>
			<xsl:apply-templates select="daogrp"/>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="not(name() = 'did') and not(name() = 'dsc') and not(name() = 'controlaccess') and not(name() = 'c') and not(starts-with(name(), 'c0')) and not(starts-with(name(), 'c1')) and not(starts-with(name(), 'dao'))">
						<xsl:copy-of select="." />
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:copy-of select="controlaccess" />
			<xsl:if test="dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
				<xsl:apply-templates select="dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" />
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="did">
		<xsl:element name="{name()}">
			<xsl:copy-of select="@*"/>
			<!-- group unitX together -->
			<!-- put all unitids together at the start -->
			<xsl:copy-of select="unitid"/>
			<xsl:copy-of select="unittitle"/>
			<xsl:copy-of select="unitdate"/>
			<xsl:for-each select="node()">
				<xsl:choose>
				    <xsl:when test="starts-with(name(), 'unit')"/>
				    <xsl:when test="starts-with(name(), 'dao')"/>
				    <xsl:otherwise>
				        <xsl:copy-of select="."/>
				    </xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<!-- Put Digital Archival Objects last -->
			<xsl:copy-of select="dao"/>
			<xsl:apply-templates select="daogrp"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="daogrp">
		<xsl:element name="{name()}">
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="daodesc"/>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="not(name() = 'daodesc')">
						<xsl:copy-of select="."/>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>