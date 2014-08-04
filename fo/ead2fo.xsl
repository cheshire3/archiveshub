<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">
  
    <xsl:output method="xml"/>

	<!-- include configurations from external file -->
    <xsl:include href="./configuration.xsl"/>
    
    <!-- Set up the XSL-FO output -->
    
    <xsl:template match="/">
    
        <fo:root>
            <fo:layout-master-set>
            
                <!-- TODO: country and langusage -->

                <fo:simple-page-master 
                    master-name="A4"
                    page-height="29.7cm"
                    page-width="21cm"
                    margin-top="1cm"
                    margin-bottom="2cm"
                    margin-left="2.5cm"
                    margin-right="2.5cm"
                    font-family="Utopia">
                    <fo:region-body
                        region-name="xsl-region-body"
                        margin-top="0cm"
                        padding="0pt">
                    </fo:region-body>
                    <fo:region-before
                        region-name="xsl-region-before"
                        extent="0cm">
                    </fo:region-before>
                    <fo:region-after
                        region-name="xsl-region-after"
                        extent="0cm">
                    </fo:region-after>
                </fo:simple-page-master>
                            
                <fo:simple-page-master 
                    master-name="A4-title"
                    page-height="29.7cm"
                    page-width="21cm"
                    margin-top="1cm"
                    margin-bottom="2cm"
                    margin-left="2.5cm"
                    margin-right="2.5cm"
                    font-family="Utopia">
                    <fo:region-body
                        region-name="xsl-region-body"
                        margin-top="5cm"
                        padding="0pt">
                    </fo:region-body>
                    <fo:region-before
                        region-name="xsl-region-before"
                        extent="3cm">
                    </fo:region-before>
                    <fo:region-after
                        region-name="xsl-region-after"
                        extent="3cm">
                    </fo:region-after>
                </fo:simple-page-master>
                
                <fo:simple-page-master 
                    master-name="A4-toc"
                    page-height="29.7cm"
                    page-width="21cm"
                    margin-top="1cm"
                    margin-bottom="2cm"
                    margin-left="2.5cm"
                    margin-right="2.5cm"
                    font-family="Utopia">
                    <fo:region-body
                        region-name="xsl-region-body"
                        margin-top="1cm"
                        padding="0pt">
                    </fo:region-body>
                    <fo:region-before
                        region-name="xsl-region-before"
                        extent="1cm">
                    </fo:region-before>
                    <fo:region-after
                        region-name="xsl-region-after"
                        extent="1cm">
                    </fo:region-after>
                </fo:simple-page-master>
                
                <fo:simple-page-master 
                    master-name="A4-main"
                    page-height="29.7cm"
                    page-width="21cm"
                    margin-top="1cm"
                    margin-bottom="2cm"
                    margin-left="2.5cm"
                    margin-right="2.5cm"
                    font-family="Utopia">
                    <fo:region-body
                        region-name="xsl-region-body"
                        margin-top="2cm"
                        padding="0pt">
                    </fo:region-body>
                    <fo:region-before
                        region-name="xsl-region-before"
                        extent="3cm">
                    </fo:region-before>
                    <fo:region-after
                        region-name="xsl-region-after"
                        extent="1cm">
                    </fo:region-after>
                </fo:simple-page-master>
            
                <fo:page-sequence-master
                    master-name="title-sequence">
                    <fo:single-page-master-reference
                        master-reference="A4-title"/>
                </fo:page-sequence-master>
                
                <fo:page-sequence-master
                    master-name="frontmatter-sequence">
                    <fo:repeatable-page-master-reference
                        master-reference="A4"/>
                </fo:page-sequence-master>
                
                <fo:page-sequence-master
                    master-name="toc-sequence">
                    <fo:repeatable-page-master-reference
                        master-reference="A4-toc"/>
                </fo:page-sequence-master>
                
                <fo:page-sequence-master
                    master-name="archdesc-sequence">
                    <fo:repeatable-page-master-reference
                        master-reference="A4-main"/>
                </fo:page-sequence-master>
                
            </fo:layout-master-set>
            
            <!-- front page -->
            <fo:page-sequence master-reference="title-sequence" format="i">
                <xsl:call-template name="fo-country"/>
                <xsl:call-template name="fo-language"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block 
                        text-align="center"
                        font-size="16pt"
                        font-weight="bold">
                        <xsl:choose>
							<xsl:when test="/ead/archdesc/did/unittitle">
								<xsl:apply-templates select="/ead/archdesc/did/unittitle"/>
							</xsl:when>
							<xsl:when test="/ead/eadheader/filedesc/titlestmt/titleproper">
								<xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt/titleproper"/>
							</xsl:when>
							<xsl:otherwise>
							    <xsl:text>Untitled</xsl:text>
							</xsl:otherwise>
			            </xsl:choose>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
            
            <!-- front-matter pages -->
            <fo:page-sequence master-reference="frontmatter-sequence" format="i">
                <xsl:call-template name="fo-country"/>
                <xsl:call-template name="fo-language"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block>
                        <xsl:apply-templates select="/ead/eadheader"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
            
            <xsl:if test="/ead/archdesc/dsc">
	            <fo:page-sequence master-reference="toc-sequence" format="i">
	                <xsl:call-template name="fo-country"/>
	                <xsl:call-template name="fo-language"/>
	                <fo:title>
	                    <xsl:value-of select="$contents-title"/>
	                </fo:title>
	                <fo:static-content flow-name="xsl-region-before">
	                    <fo:block border-bottom="1px solid black">
	                        <fo:block>
	                            <xsl:value-of select="$contents-title"/>
	                        </fo:block>
	                    </fo:block>
	                </fo:static-content>
	                <fo:flow flow-name="xsl-region-body">
	                    <fo:block
				            font-size="14pt"
				            font-weight="bold"
				            space-after="10pt">
				            <xsl:value-of select="$contents-title"/>
				        </fo:block>
				        <xsl:call-template name="toc-line">
				          <xsl:with-param name="node" select="/ead/archdesc"/>
				        </xsl:call-template>
				        <fo:block margin-left="10pt">
				            <xsl:apply-templates select="/ead/archdesc/dsc" mode="toc"/>
				        </fo:block>
	                </fo:flow>
	            </fo:page-sequence>
          	</xsl:if>
            
            <!-- Actual content pages -->
            
            <!-- Collection Level -->
	        <fo:page-sequence 
                master-reference="archdesc-sequence"
                initial-page-number="1">
                <xsl:call-template name="fo-country"/>
                <xsl:call-template name="fo-language"/>
	            <xsl:variable name="title">
	                <xsl:value-of select="/ead/archdesc/did/unittitle"/>
	            </xsl:variable>
	            <fo:title>
	                <xsl:value-of select="$title"/>
	            </fo:title>
	            <fo:static-content flow-name="xsl-region-before">
	                <fo:block 
	                    border-bottom="1pt solid black">
	                    <fo:block text-align-last="justify">
	                        <xsl:value-of select="/ead/archdesc/did/unitid"/>
	                        <xsl:text>: </xsl:text>
	                        <xsl:value-of select="$title"/>
	                        <fo:leader leader-pattern="space"/>
	                        <fo:page-number/>
	                    </fo:block>
	                </fo:block>
	            </fo:static-content>
	            <fo:static-content flow-name="xsl-region-after">
	                <fo:block/>
	            </fo:static-content>
	            <fo:flow flow-name="xsl-region-body">
	                <xsl:call-template name="single-unit">
	                   <xsl:with-param name="node" select="/ead/archdesc"/>
	                </xsl:call-template>
	            </fo:flow>
	        </fo:page-sequence>
	        
            <xsl:apply-templates select="/ead/archdesc/dsc" mode="body"/>
            
        </fo:root>
        
    </xsl:template>
    
    <!-- utility templates -->
    
    <xsl:template name="fo-country">
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:param name="text">
            <xsl:choose>
                <xsl:when test="/ead/eadheader/eadid/@countrycode">
                    <xsl:value-of select="/ead/eadheader/eadid/@countrycode"/>
                </xsl:when>
                <xsl:when test="/ead/archdesc/did/unitid/@countrycode">
                    <xsl:value-of select="/ead/archdesc/did/unitid/@countrycode"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>gb</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:attribute name="country">
		    <xsl:value-of select="translate(translate(normalize-space($text), ' ', ''), $uc, $lc)"/>
		</xsl:attribute>
    </xsl:template>
    
    <xsl:template name="fo-language">
        <xsl:attribute name="language">
            <xsl:choose>
                <xsl:when test="/ead/eadheader/profiledesc/langusage">
                    <xsl:choose>
                        <xsl:when test="/ead/eadheader/profiledesc/langusage/language[@langcode='eng']">
                            <xsl:text>en</xsl:text>
                        </xsl:when>
                        <xsl:when test="/ead/eadheader/profiledesc/langusage/language[@langcode='fra'] or 
                                        /ead/eadheader/profiledesc/langusage/language[@langcode='fre']">
                            <xsl:text>fr</xsl:text>
                        </xsl:when>
                        <xsl:when test="/ead/eadheader/profiledesc/langusage/language[@langcode='esl'] or 
                                        /ead/eadheader/profiledesc/langusage/language[@langcode='spa']">
                            <xsl:text>es</xsl:text>
                        </xsl:when>
                        <xsl:when test="/ead/eadheader/profiledesc/langusage/language[@langcode='deu'] or 
                                        /ead/eadheader/profiledesc/langusage/language[@langcode='ger']">
                            <xsl:text>de</xsl:text>
                        </xsl:when>
                        <!-- fallback to English -->
                        <xsl:otherwise>
                            <xsl:text>en</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>en</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="section-header">
        <xsl:param name="text"/>
        <fo:block
            font-weight="bold"
            space-before="6pt"
            space-after="6pt"
            keep-with-next="always">
            <xsl:value-of select="$text"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="subsection-header">
        <xsl:param name="text"/>
        <fo:block
            font-weight="bold"
            space-before="3pt"
            space-after="3pt"
            keep-with-next="always">
            <xsl:value-of select="$text"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="fo-link">
        <xsl:param name="url"/>
        <xsl:param name="content"/>
        <fo:basic-link
            color="#000099">
            <xsl:attribute name="external-destination">
                <xsl:value-of select="$url"/>
            </xsl:attribute>
            <fo:inline>
                <xsl:value-of select="$content"/>
            </fo:inline>
        </fo:basic-link>
    </xsl:template>
    
    <!-- Simple Link -->
    <xsl:template name="simple-link">
        <xsl:call-template name="fo-link">
            <xsl:with-param name="url">
                <xsl:value-of select="./@href"/>
            </xsl:with-param>
            <xsl:with-param name="content">
                <!-- inner HTML -->
	            <xsl:variable name="txt">
	                <xsl:value-of select="string(.)"/>
	            </xsl:variable>
	            <xsl:choose>
	                <xsl:when test="string(.)">
	                    <xsl:value-of select="normalize-space($txt)"/>
	                </xsl:when>
	                <xsl:when test="./@title">
	                    <xsl:value-of select="./@title"/>
	                </xsl:when>
	                <xsl:when test="./@label">
	                    <xsl:value-of select="./@label"/>
	                </xsl:when>
	                <xsl:otherwise>
	                    <xsl:value-of select="./@href"/>
	                </xsl:otherwise>
	            </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- IMAGES-->
    <xsl:template name="image">
        <fo:basic-link>
            <xsl:attribute name="external-destination">
                <xsl:value-of select="./@href"/>
            </xsl:attribute>
            <!-- inner HTML -->
            <fo:external-graphic
                background-color="#ffffff">
		        <xsl:attribute name="src">
		            <xsl:text>url(</xsl:text>
		            <xsl:value-of select="./@href"/>
		            <xsl:text>)</xsl:text>
		        </xsl:attribute>
		    </fo:external-graphic>
        </fo:basic-link>
        <!-- caption -->
        <xsl:apply-templates select="./daodesc"/>
    </xsl:template>
    
    <!-- templates for individual EAD elements follows -->
    
    <!-- templates for front-matter -->
    
    <xsl:template match="eadheader">
        <fo:block
            width="100%"
            border="1px solid black"
            padding="10pt" 
            space-before="10pt"
            space-after="16pt">
            <fo:block
                text-align="center"
                font-size="14pt"
                font-weight="bold"
                space-after="10pt">
                <xsl:text>Cataloguing Information</xsl:text>
            </fo:block>
            <fo:block
                font-size="12pt">
                <fo:inline font-weight="bold">Note: </fo:inline>This page describes the Finding Aid or Catalogue Entry, rather than the material itself.
            </fo:block>
        </fo:block>
	        
        <fo:block
            text-align="center" 
            font-size="14pt"
            font-weight="bold"
            space-before="10pt"
            space-after="10pt">
            <xsl:apply-templates select="eadid"/>
        </fo:block>
        <fo:block
            space-before="10pt"
            space-after="10pt">
            <xsl:apply-templates select="filedesc"/>
        </fo:block>        
        <fo:block
            space-before="10pt"
            space-after="10pt">
            <xsl:apply-templates select="profiledesc"/>
        </fo:block>
        <fo:block
            space-before="10pt"
            space-after="10pt">
            <xsl:apply-templates select="revisiondesc"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="filedesc">
        <xsl:apply-templates select="titlestmt"/>
        <xsl:if test="publicationstmt">
            <fo:block>
                <fo:block 
                    font-weight="bold"
                    space-before="5pt"
                    space-after="5pt">Publication</fo:block>
                <xsl:apply-templates select="publicationstmt"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="editionstmt">
            <fo:block>
                <fo:block>Edition</fo:block>
                <xsl:apply-templates select="editionstmt"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="seriesstmt">
            <fo:block>
                <fo:block>Series</fo:block>
                <xsl:apply-templates select="seriesstmt"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="notesstmt">
            <fo:block>
                <fo:block>Notes</fo:block>
                <xsl:apply-templates select="notesstmt"/>
            </fo:block>
        </xsl:if>
    </xsl:template>
 
    <xsl:template match="titlestmt">
        <!-- ignore titleproper, usually the same as title of material (unittitle) -->
        <xsl:if test="titleproper">
            <fo:block
                text-align="center" 
                font-size="16pt"
                font-weight="bold"
                space-after="12pt">
                <xsl:apply-templates select="titleproper"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="subtitle">
            <fo:block
                text-align="center" 
                font-size="14pt"
                font-weight="bold"
                space-after="10pt">
                <xsl:apply-templates select="subtitle"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="author">
            <fo:block
                text-align="center"
                font-size="12pt"
                font-weight="bold"
                space-after="10pt">
                <xsl:for-each select="author">
		            <xsl:apply-templates/>
		            <xsl:if test="position() &lt; count(../author)">
                        <xsl:text>, </xsl:text>
                    </xsl:if>    
		        </xsl:for-each>
            </fo:block>
        </xsl:if>
        
        <xsl:if test="sponsor">
            <fo:block>
                <fo:block
                    font-weight="bold"
                    space-before="5pt"
                    space-after="5pt">
                    Sponsor
                </fo:block>
                <xsl:apply-templates select="sponsor"/>
            </fo:block>
        </xsl:if>
    </xsl:template>
 
    <xsl:template match="profiledesc">
        <fo:block>
            <fo:block
                font-weight="bold"
                space-before="5pt"
                space-after="5pt">
                Creation
            </fo:block>
            <xsl:apply-templates select="./creation"/>
            <fo:block
                space-before="5pt"
                space-after="5pt">
                Print formatted copy created from the EAD by XSLT and XSL-FO Stylesheets by 
                <xsl:call-template name="fo-link">
                    <xsl:with-param name="url" select="'mailto:john.harrison@liv.ac.uk'"/>
                    <xsl:with-param name="content" select="'John Harrison'"/>
                </xsl:call-template>
                of 
                <xsl:call-template name="fo-link">
                    <xsl:with-param name="url" select="'http://www.liv.ac.uk'"/>
                    <xsl:with-param name="content" select="'the University of Liverpool'"/>
                </xsl:call-template>
                .
            </fo:block>
        </fo:block>
        <xsl:if test="descrules">
            <fo:block>
                <fo:block
                    font-weight="bold"
                    space-before="5pt"
                    space-after="5pt">
                    Descriptive Rules
                </fo:block>
                <xsl:apply-templates select="./descrules"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="langusage">
            <fo:block>
                <fo:block
                    font-weight="bold"
                    space-before="5pt"
                    space-after="5pt">
                    Language Usage
                </fo:block>
                <xsl:apply-templates select="./langusage"/>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="revisiondesc">      
        <fo:block>
            <fo:block
                font-weight="bold"
                space-before="5pt"
                space-after="5pt">
                Revisions
            </fo:block>
            <xsl:apply-templates select="list"/>
            <xsl:if test="change">
                <fo:list-block>
                <xsl:for-each select="change">
                    <fo:list-item>
                        <fo:list-item-label>
                            <fo:block>
                                <xsl:value-of select="date"/>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body>
                            <fo:block
                                margin-left="25%">
                                <xsl:value-of select="item"/>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </xsl:for-each>
                </fo:list-block>
            </xsl:if>
	            
        </fo:block>
    </xsl:template>
    
    <!-- templates for Table of Contents (toc) -->
    
    <xsl:template match="dsc" mode="toc">
        <xsl:for-each select="c|c01">
            <xsl:if test="not(./@audience and ./@audience = 'internal')">
                <xsl:call-template name="toc-c"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="toc-c">
        <xsl:call-template name="toc-line">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
        <xsl:if test="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">      
            <fo:block margin-left="10pt">
                <xsl:for-each select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		            <xsl:if test="not(./@audience and ./@audience = 'internal')">
	                    <xsl:call-template name="toc-c"/>
		            </xsl:if>
		        </xsl:for-each>
            </fo:block>
        </xsl:if>
    </xsl:template>

	<xsl:template name="toc-line">
        <xsl:param name="node"/>
        <fo:block
            text-align-last="justify"
            font-size="10pt">
            <!-- treat c01 specially, space before and bold text -->
            <xsl:if test="local-name($node) = 'c01'">
            	<xsl:attribute name="font-weight">
            		<xsl:text>bold</xsl:text>
            	</xsl:attribute>
            	<xsl:attribute name="padding-top">
            		<xsl:text>0.5em</xsl:text>
            	</xsl:attribute>
            </xsl:if>
            <xsl:if test="$node/did/unitid">
	            <xsl:value-of select="$node/did/unitid"/>
	            <xsl:text>: </xsl:text>
	        </xsl:if>
            <xsl:choose>
	          <xsl:when test="$node/did/unittitle">
	                <xsl:value-of select="$node/did/unittitle"/>
	            </xsl:when>
	            <xsl:otherwise>
	              <xsl:text>(untitled)</xsl:text>
	            </xsl:otherwise>
	        </xsl:choose>
            <fo:leader leader-pattern="dots"/>
            <fo:page-number-citation>
                <xsl:attribute name="ref-id">
                    <xsl:value-of select="generate-id($node)"/>
                </xsl:attribute>
            </fo:page-number-citation>
      </fo:block>
	</xsl:template>
	
	<!-- templates for display of body of description -->
    
    <xsl:template match="dsc" mode="body">
        <!-- Components -->
        <xsl:for-each select="c01|c">
            <xsl:variable name="title">
                <xsl:value-of select="./did/unittitle"/>
            </xsl:variable>
            <fo:page-sequence master-reference="archdesc-sequence">
                <xsl:call-template name="fo-country"/>
                <xsl:call-template name="fo-language"/>
                <fo:title>
                    <xsl:value-of select="$title"/>
                </fo:title>
                    <fo:static-content flow-name="xsl-region-before">
                        <fo:block 
                            border-bottom="1pt solid black"
                            text-align-last="justify">
                            <fo:block>
                                <xsl:value-of select="./did/unitid"/>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="$title"/>
                                <fo:leader leader-pattern="space"/>
                                <fo:page-number/>
                            </fo:block>
                        </fo:block>
                    </fo:static-content>
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block/>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
	                <xsl:call-template name="all-component"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:for-each>
    </xsl:template>
    
	<xsl:template name="all-component" 
		match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
        <xsl:if test="not(@audience and @audience = 'internal')">
            <xsl:call-template name="single-unit">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="single-unit">
        <xsl:param name="node"/>
        <fo:block
            border-bottom="1pt solid black">
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id($node)"/>
            </xsl:attribute>
            <!-- unit title -->
            <fo:block
	            font-weight="bold"
	            space-before="10pt"
	            space-after="10pt">
	            <xsl:apply-templates select ="$node/did/unittitle"/>
	            <xsl:if test="$node/did/unitdate">
	                <xsl:text>, </xsl:text>
	                <xsl:value-of select="$node/did/unitdate"/>
	            </xsl:if>
	        </fo:block>
            <!-- did for this component -->
            
             <fo:table table-layout="fixed"
                  inline-progression-dimension="100%"
                  keep-with-previous="always">
	            <fo:table-column column-number="1" 
	                             column-width="proportional-column-width(1)"/>
	            <fo:table-column column-number="2" 
	                                   column-width="proportional-column-width(4)"/>
	            <fo:table-body>
                
                <xsl:apply-templates select="$node/did"/>
                
                    <!-- I would like to use float for DAOs but they are not supported by Apache FOP
                        have to put them in the table instead :(
                    -->    
                    <xsl:if test="$node/dao|$node/did/dao|$node/daogrp|$node/did/daogrp">
	                    <fo:table-row>
		                    <fo:table-cell>
                                <fo:block>Digital Objects</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
			                   <fo:block>
			                       <xsl:apply-templates select="$node/dao|$node/did/dao|$node/daogrp|$node/did/daogrp"/>
			                   </fo:block>
		                    </fo:table-cell>
		                </fo:table-row>
                    </xsl:if>
                </fo:table-body>
            </fo:table>
            
	        <xsl:apply-templates select="$node/did/note" mode="own-section"/>
	        <xsl:apply-templates select="$node/scopecontent"/>
	        <xsl:apply-templates select="$node/bioghist"/>
	        <xsl:apply-templates select="$node/arrangement"/>
	     
	        <xsl:if test="admininfo">
	            <xsl:apply-templates select="$node/admininfo" />
	        </xsl:if>
	           
	        <!-- ACCESS + USE RESTRICTIONS -->
	        <xsl:apply-templates select="$node/accessrestrict|$node/descgrp/accessrestrict"/>
	        <xsl:apply-templates select="$node/userestrict|$node/descgrp/userestrict"/>
	        <xsl:apply-templates select="$node/phystech|$node/descgrp/phystech"/>
	        <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY-->
	        <xsl:apply-templates select="$node/appraisal|$node/descgrp/appraisal"/>
	        <xsl:apply-templates select="$node/acqinfo|$node/descgrp/acqinfo"/>
	        <xsl:apply-templates select="$node/custodhist|$node/descgrp/custodhist"/>
	        <xsl:apply-templates select="$node/accruals|$node/descgrp/accruals"/>
	        <xsl:apply-templates select="$node/processinfo|$node/descgrp/processinfo"/>
	        <!-- USER INFO -->
	        <xsl:apply-templates select="$node/otherfindaid|$node/descgrp/otherfindaid"/>
	        <xsl:apply-templates select="$node/originalsloc|$node/descgrp/originalsloc"/>
	        <xsl:apply-templates select="$node/altformavail|$node/descgrp/altformavail"/>
	        <xsl:apply-templates select="$node/relatedmaterial|$node/descgrp/relatedmaterial"/>
	        <xsl:apply-templates select="$node/separatedmaterial|$node/descgrp/separatedmaterial"/>
	        <!-- BIBLIOGRAPHY / CITATIONS -->
	        <xsl:apply-templates select="$node/bibliography|$node/descgrp/bibliography"/>
	        <xsl:apply-templates select="$node/prefercite|$node/descgrp/prefercite"/>
	        <!-- MISCELLANEOUS -->
	        <xsl:apply-templates select="$node/odd"/>
	        <xsl:apply-templates select="$node/note" mode="own-section"/>
	        
	        <!-- CONTROLACCESS -->
	        <xsl:apply-templates select="$node/controlaccess|$node/descgrp/controlaccess"/>
	        
	        <xsl:apply-templates select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="did">
      
        <fo:table-row>
            <fo:table-cell>
                <fo:block>Reference</fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block>
                    <xsl:for-each select="unitid">
                     <fo:block><xsl:apply-templates select="."/></fo:block>
                 </xsl:for-each>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
        
        <xsl:if test="origination">
            <fo:table-row>
             <fo:table-cell>
                 <fo:block>Creator</fo:block>
             </fo:table-cell>
             <fo:table-cell>
		        <fo:block 
		            font-weight="italic"
		            space-before="10pt"
		            space-after="10pt">
		            <xsl:apply-templates select="origination"/>
		        </fo:block>
		       </fo:table-cell>
		      </fo:table-row>
		  </xsl:if>
      
        <xsl:if test="physdesc">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>Physical Description</fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                        <xsl:apply-templates select="physdesc"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </xsl:if>
                    
        <xsl:if test="langmaterial|../langmaterial">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>Language of Material</fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                     <xsl:choose>
                         <xsl:when test="langmaterial">
                             <xsl:apply-templates select="langmaterial"/>
                         </xsl:when>
                         <xsl:when test="../langmaterial">
                             <xsl:apply-templates select="../langmaterial"/>
                         </xsl:when>
                     </xsl:choose>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </xsl:if>
        
        <xsl:if test = "physloc">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>Location</fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                        <xsl:value-of select="physloc"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </xsl:if>
    </xsl:template>
    
    <!--DAO - Digital Archival Objects-->  
    <xsl:template match="dao">
        <fo:block keep-with-previous="always">
            <xsl:choose>
                <xsl:when test="./@audience = 'internal'" />
                <xsl:when test="./@href">
                    <xsl:choose>
                        <xsl:when test="@show='embed'">
                            <xsl:call-template name="image" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="simple-link"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Location of Digital Object not provided.</xsl:text>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <!-- DAOGRPs -->
    <xsl:template match="daogrp">
        <xsl:choose>
            <xsl:when test="./@audience = 'internal'" />
            <xsl:when test="count(./daoloc) = 2 and ./daoloc[@role='thumb']">
                <xsl:call-template name="daogrp-thumb"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="daogrp-multi" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- DAOGRP - representing thumbnail link to main object -->
    <xsl:template name="daogrp-thumb">
        <fo:block keep-with-previous="always"> 
            <fo:basic-link>
                <xsl:attribute name="external-destination">
	                <xsl:value-of select="./daoloc[@role='reference']/@href"/>
	            </xsl:attribute>
	            <!--  inner HTML -->
                <xsl:choose>
                    <xsl:when test="./daoloc/@role='thumb'">
                        <fo:external-graphic
                            background-color="#ffffff">
                            <xsl:attribute name="src">
                                <xsl:text>url(</xsl:text>
                                <xsl:value-of select="./daoloc[@role='thumb']/@href"/>
                                <xsl:text>)</xsl:text>
                            </xsl:attribute>
                        </fo:external-graphic>
                    </xsl:when>
                    <xsl:when test="./@title">
                        <fo:inline>
                            <xsl:value-of select="./@title"/>
                        </fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:inline>Full file</fo:inline>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:basic-link>
            <!-- caption -->
            <xsl:apply-templates select="./daodesc" />
        </fo:block>
    </xsl:template>
    
    <!-- DAOGRP - representing single, bundled or nested links + description -->
    <xsl:template name="daogrp-multi">
        <xsl:apply-templates select="./daodesc" />
        <xsl:for-each select="daoloc">
            <fo:block>
                <xsl:choose>
                    <xsl:when test="./@audience = 'internal'" />
                    <xsl:when test="./@href">
                        <xsl:choose>
                            <xsl:when test="../@show='embed'">
                                <xsl:call-template name="image" />
                            </xsl:when>
                            <xsl:when test="./@role='thumb'">
                                <xsl:call-template name="image" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="simple-link" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </fo:block>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="langmaterial|langusage">
    	<xsl:choose>
    		<xsl:when test="not(normalize-space(./text()))">
    			<xsl:for-each select="language">
    				<xsl:apply-templates />
    				<xsl:if test="position() &lt; count(../language)">
    					<xsl:text>, </xsl:text>
    				</xsl:if>
    			</xsl:for-each>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:apply-templates />
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="head">
        <xsl:if test="./text()">
            <xsl:call-template name="section-header">
                <xsl:with-param name="text">
                    <xsl:value-of select="."/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="bioghist">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
		            <xsl:with-param name="text">Administrative / Biographical History</xsl:with-param>
		        </xsl:call-template>
	        </xsl:if>
	        <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="scopecontent">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Scope and Content</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="arrangement">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Arrangement</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="accessrestrict">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Conditions Governing Access</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="userestrict">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Conditions Governing Use</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="phystech">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Physical Characteristics and/or Technical Requirements</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
  
    <xsl:template match="admininfo">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Administrative Information</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="appraisal">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Appraisal Information</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="acqinfo">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Acquisition Information</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="custodhist">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Custodial History</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="accruals">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Accruals</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="processinfo">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Archivist's Note</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="otherfindaid">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Other Finding Aid</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="originalsloc">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Location of Originals</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="altformavail">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Alternative Form Available</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="relatedmaterial">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Related Material</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="separatedmaterial">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Separated Material</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- BIBLIOGRAPHY / CITATIONS --> 
    
    <xsl:template match="bibliography">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="head/text()">
	                <xsl:apply-templates select="head" />
	            </xsl:when>
	            <xsl:otherwise>
                    <xsl:call-template name="section-header">
	                    <xsl:with-param name="text">
	                        <xsl:text>Bibliography</xsl:text>
	                    </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
	            <xsl:when test="bibref">
                    <fo:list-block>
                        <xsl:for-each select="bibref">
                            <fo:list-item>
                                <fo:list-item-label>
                                    <fo:block>
                                        <xsl:value-of select="position()"/>
                                    </fo:block>
                                </fo:list-item-label>
                                <fo:list-item-body>
                                    <fo:block>
                                        <xsl:apply-templates select="." />
                                    </fo:block>
                                </fo:list-item-body>
                            </fo:list-item>
                        </xsl:for-each>
                    </fo:list-block>
	            </xsl:when>
	            <xsl:otherwise>
	              <xsl:apply-templates select="*[local-name()!='head']" />
	            </xsl:otherwise>
	        </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="prefercite">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                        <xsl:text>Preferred Citation</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="odd">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(head/text())">
                <xsl:call-template name="section-header">
                    <xsl:with-param name="text">
                    <xsl:text>Other Descriptive Data</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- CONTROLLED ACCESS TERMS -->
    <xsl:template match="controlaccess">
        <fo:block
            space-before="6pt"
            space-after="6pt">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'controlaccess'" />
                <xsl:when test="head/text()">
	                <xsl:apply-templates select="head"/>
	            </xsl:when>
	            <xsl:otherwise>
                    <xsl:call-template name="section-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Access Points</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        
            <!-- Subjects -->
            <xsl:if test="subject">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Subjects</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="subject">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
                
            <!-- Personal Names -->
            <xsl:if test="persname">
                <fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Personal Names</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="persname">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <!-- Family Names -->
            <xsl:if test="famname">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Family Names</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="famname">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <!-- Corporate Names -->
            <xsl:if test="corpname">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Corporate Names</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="corpname">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <!-- Geographical Names -->
            <xsl:if test="geogname">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Geographical Names</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="geogname">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <xsl:if test="title">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Titles</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="title">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <xsl:if test="function">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Functions</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="function">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <xsl:if test="genreform">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Genre/Form</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="genreform">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <xsl:if test="occupation">
            	<fo:block
	            space-before="3pt"
	            space-after="3pt">
		            <xsl:if test="@id">
		                <xsl:attribute name="id">
		                    <xsl:value-of select="@id"/>
		                </xsl:attribute>
		            </xsl:if>
		            <xsl:call-template name="subsection-header">
	                    <xsl:with-param name="text">
		                    <xsl:text>Occupations</xsl:text>
	                    </xsl:with-param>
	                </xsl:call-template>
	                <fo:list-block>
	                    <xsl:for-each select="occupation">
	                        <fo:list-item>
	                            <fo:list-item-label><fo:block/></fo:list-item-label>
	                            <fo:list-item-body>
	                                <fo:block><xsl:apply-templates/></fo:block>
	                            </fo:list-item-body>
	                        </fo:list-item>
	                    </xsl:for-each>
	                </fo:list-block>
                </fo:block>
            </xsl:if>
            
            <xsl:apply-templates select="controlaccess" />

        </fo:block>
        
    </xsl:template>
    
    <xsl:template match="blockquote">
        <fo:block
            margin-left="24pt"
            margin-right="12pt"
            font-style="italic">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="p">
        <fo:block
            text-align="justify"
            space-before="5pt"
            space-after="5pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!--LISTS-->
    <xsl:template match="list">
        <fo:list-block>
            <xsl:for-each select="item">
                <fo:list-item>
                    <fo:list-item-label>
                        <xsl:choose>
                            <xsl:when test="../@type='ordered'">
                                <fo:block>
                                    <xsl:value-of select="position()"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="../@type='unordered'">
                                <fo:block>*</fo:block>
                            </xsl:when>
                            <xsl:when test="../@type='marked'">
                                <fo:block>*</fo:block>
                            </xsl:when>
                            <xsl:when test="../@type='simple'">
                                <fo:block>*</fo:block>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:block>*</fo:block>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:list-item-label>
                    <fo:list-item-body>
                        <fo:block margin-left="10pt">
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </xsl:for-each>
        </fo:list-block>
    </xsl:template>
    
    <!--CHRON LISTS-->
    <xsl:template match="chronlist">
      <ul>
        <xsl:for-each select="chronitem">
          <xsl:value-of select ="."/><br/>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    <!-- rendering/altrendering for all elements -->    
    <xsl:template match="*">
        <xsl:choose>
            <!--  @render -->
            <xsl:when test="@render='bold' or @altrender='bold'">
                <fo:inline font-weight="bold"><xsl:apply-templates /></fo:inline>
            </xsl:when>
            <xsl:when test="@render='italic' or @altrender='italic'">
                <fo:inline font-style="italic"><xsl:apply-templates /></fo:inline>
            </xsl:when>
            <xsl:when test="@render='underline' or @altrender='underline'">
                <fo:inline text-decoration="underline"><xsl:apply-templates /></fo:inline>
            </xsl:when>
            <xsl:when test="@render='quoted' or @altrender='quoted'">
                <xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='singlequote'">
                <xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='doublequote' or @altrender='doublequote'">
                <xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text>
            </xsl:when>
            <xsl:when test="@render='bolditalic' or @altrender='bolditalic'">
                <fo:inline 
                    font-weight="bold" 
                    font-style="italic">
                        <xsl:apply-templates />
                 </fo:inline>
            </xsl:when>
            <xsl:when test="@render='boldunderline' or @altrender='boldunderline'">
                <fo:inline 
                    font-weight="bold" 
                    text-decoration="underline">
                        <xsl:apply-templates />
                 </fo:inline>
            </xsl:when>
            <xsl:when test="@render='boldquoted' or @altrender='boldquoted'">
                <fo:inline font-weight="bold"><xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text></fo:inline>
            </xsl:when>
            <xsl:when test="@render='bolddoublequote' or @altrender='bolddoublequote'">
                <fo:inline font-weight="bold"><xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text></fo:inline>
            </xsl:when>
            <xsl:when test="@altrender='italicunderline'">
                <fo:inline 
                    font-style="italic"
                    text-decoration="undeline">
                        <xsl:apply-templates />
                 </fo:inline>
                <i><u><xsl:value-of select="."/></u></i>
            </xsl:when>
            <xsl:when test="@altrender='italicquoted'">
                <fo:inline font-style="italic"><xsl:text>&apos;</xsl:text><xsl:value-of select="."/><xsl:text>&apos;</xsl:text></fo:inline>
            </xsl:when>
            <xsl:when test="@altrender='italicdoublequote'">
                <fo:inline font-style="italic"><xsl:text>&quot;</xsl:text><xsl:value-of select="."/><xsl:text>&quot;</xsl:text></fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="local-name() = 'title'">
                        <fo:inline font-style="italic"><xsl:apply-templates /></fo:inline>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
</xsl:stylesheet>
