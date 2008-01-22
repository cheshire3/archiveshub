<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [ 
    <!ENTITY nbsp "&#160;">   <!-- white space in XSL -->
    <!ENTITY copy "&#169;">   <!-- copyright symbol in XSL -->
    ]>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &copy; 2005-2007 the University of Liverpool
-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/> 
	<xsl:preserve-space elements="*"/>

  <xsl:template match="/">
  	<xsl:call-template name="toc"/>
  </xsl:template>

  <!-- templates for Table of Contents (toc) -->
  <xsl:template name="toc">
  	<script type="text/javascript" src="/javascript/collapsibleLists.js"></script>
  	<script type="text/javascript" src="/javascript/cookies.js"></script> 	
    <b>
	    <xsl:call-template name="toc-link">
	      <xsl:with-param name="node" select="/ead/archdesc"/>
	      <xsl:with-param name="level" select="'collectionLevel'"/>
	    </xsl:call-template>
	</b>
    <ul id="someId" class="hierarchy">    
		<xsl:apply-templates select="/ead/archdesc/dsc" mode="toc"/>		
    </ul>
    <br/>
    <br/>
  </xsl:template>


	<xsl:template match="dsc" mode="toc">
		<xsl:for-each select="c|c01">
			<xsl:if test="not(./@audience and ./@audience = 'internal')">
				<li><xsl:call-template name="toc-c"/></li>
			</xsl:if>
        </xsl:for-each>
	</xsl:template>


	<xsl:template name="toc-c" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:call-template name="toc-link">
			  <xsl:with-param name="node" select="."/>
		</xsl:call-template>
	    <xsl:if test="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"> 
	      <ul class="hierarchy">
	        <xsl:for-each select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
	        	<xsl:if test="not(./@audience and ./@audience = 'internal')">
		          <li>
		            <xsl:call-template name="toc-c"/>
		          </li>
	            </xsl:if>
	        </xsl:for-each>
	      </ul>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="toc-c1" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:param name="parent"/>
		<xsl:call-template name="toc-link">
			  <xsl:with-param name="node" select="."/>
			  <xsl:with-param name="level" select="count(./ancestor::*[starts-with(name(), 'c')]) + 1"/>
			  <xsl:with-param name="pos" select="count(./preceding-sibling::*[starts-with(name(), 'c')]) + 1"/>
			  <xsl:with-param name="parent" select="$parent"/>
		</xsl:call-template>
	    <xsl:if test="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"> 
	      <xsl:variable name="parent_pos">
	      	<xsl:number value="count(./preceding-sibling::*[starts-with(name(), 'c')]) + 1"/>
	      	<xsl:text>-</xsl:text>
	      	<xsl:value-of select="$parent"/>
	      </xsl:variable>
	      <ul class="hierarchy">
	        <xsl:for-each select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
	        	<xsl:if test="not(./@audience and ./@audience = 'internal')">
		          <li>
		            <xsl:call-template name="toc-c">
		            	<xsl:with-param name="parent" select="$parent_pos"/>
		            </xsl:call-template>
		          </li>
	            </xsl:if>
	        </xsl:for-each>
	      </ul>
		</xsl:if>
	</xsl:template>


  <xsl:template name="toc-link">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <a>
      <xsl:attribute name="name">
      	<xsl:text>link</xsl:text>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$level = 'collectionLevel'">
          <xsl:attribute name="id">
        	<xsl:text>collectionLevel</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="href">
        	<xsl:text>javascript: displayForm('collectionLevel')</xsl:text>
	  	  </xsl:attribute>
	  	  <xsl:attribute name="class">
	  	  	<xsl:text>selected</xsl:text>
	  	  </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="id">
        	<xsl:value-of select="$node/@id"/>
      	  </xsl:attribute>
      	  <xsl:attribute name="href">
        	<xsl:text>javascript: displayForm('</xsl:text>
        	<xsl:value-of select="$node/@id"/>       
        	<xsl:text>')</xsl:text>
	  	  </xsl:attribute>
	  	  <xsl:attribute name="onclick">
        	<xsl:text>setCookie('RECID-tocstate', stateToString('someId'))</xsl:text>
      	  </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
	  <xsl:if test="$node/did/unitid">
	      <xsl:value-of select="$node/did/unitid"/>
	      <xsl:text> - </xsl:text>
      </xsl:if>
      <xsl:choose>
      	<xsl:when test="$node/did/unittitle">
		      <xsl:value-of select="$node/did/unittitle"/>
	      </xsl:when>
	      <xsl:when test="$node/../eadheader/filedesc/titlestmt/titleproper">
	      	<xsl:value-of select="$node/../eadheader/filedesc/titlestmt/titleproper"/>
	      </xsl:when>
 	      <xsl:otherwise>
 	      	<xsl:text>(untitled)</xsl:text>
	      </xsl:otherwise>
      </xsl:choose>
    </a>    
  </xsl:template>


  <xsl:template name="toc-link1">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <xsl:param name="pos"/>
    <xsl:param name="parent"/>
    <a>
      <xsl:attribute name="id">
        <xsl:text>link-C</xsl:text>
        <xsl:value-of select="$level"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$pos"/>
        <xsl:if test="$parent">
        	<xsl:text>-</xsl:text>
        	<xsl:value-of select="substring($parent, 0, string-length($parent))"/>
        </xsl:if>        
      </xsl:attribute>
      <xsl:attribute name="href">
        <xsl:text>javascript: displayForm('link-C</xsl:text>
        <xsl:value-of select="$level"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$pos"/>
        <xsl:if test="$parent">
        	<xsl:text>-</xsl:text>
        	<xsl:value-of select="substring($parent, 0, string-length($parent))"/>
        </xsl:if>        
        <xsl:text>')</xsl:text>
	  </xsl:attribute>
	  
	  <xsl:if test="$node/did/unitid">
	      <xsl:value-of select="$node/did/unitid"/>
	      <xsl:text> - </xsl:text>
      </xsl:if>
      <xsl:choose>
      	<xsl:when test="$node/did/unittitle">
		      <xsl:value-of select="$node/did/unittitle"/>
	      </xsl:when>
	      <xsl:when test="$node/../eadheader/filedesc/titlestmt/titleproper">
	      	<xsl:value-of select="$node/../eadheader/filedesc/titlestmt/titleproper"/>
	      </xsl:when>
 	      <xsl:otherwise>
 	      	<xsl:text>(untitled)</xsl:text>
	      </xsl:otherwise>
      </xsl:choose>
    </a>
    
  </xsl:template>

</xsl:stylesheet>
