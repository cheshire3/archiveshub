<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"
	version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
	

	<xsl:template match="/">
		<ead>
			<xsl:copy-of select="/ead/eadheader" />
			<xsl:apply-templates select="/ead/archdesc" />
		</ead>
	</xsl:template>

	<xsl:template match="/ead/archdesc|dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:element name="{name()}">
			<xsl:copy-of select="@*" />
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="not(name() = 'dsc') and not(name() = 'controlaccess') and not(name() = 'c') and not(starts-with(name(), 'c0')) and not(starts-with(name(), 'c1'))">
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

</xsl:stylesheet>