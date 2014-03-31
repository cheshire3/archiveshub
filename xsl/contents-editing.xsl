<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [ 
    <!ENTITY nbsp "&#160;">   <!-- white space in XSL -->
    <!ENTITY copy "&#169;">   <!-- copyright symbol in XSL -->
    ]>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &copy; 2005-2009 the University of Liverpool
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
    <b>
	    <xsl:call-template name="toc-link">
	      <xsl:with-param name="node" select="/ead/archdesc"/>
	      <xsl:with-param name="level" select="'collectionLevel'"/>
	    </xsl:call-template>
	</b>
        
		<xsl:apply-templates select="/ead/archdesc/dsc" mode="toc"/>		
    
  </xsl:template>


	<xsl:template match="dsc" mode="toc">
		<ul id="someId" class="hierarchy" name="1">
		<xsl:for-each select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
			<xsl:if test="not(./@audience and ./@audience = 'internal')">
				<li>
					<xsl:call-template name="toc-c"/>
				</li>			
			</xsl:if>
        </xsl:for-each>
        </ul>
	</xsl:template>


	<xsl:template name="toc-c" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:call-template name="toc-link">
			  <xsl:with-param name="node" select="."/>
		</xsl:call-template>
		<xsl:choose>
		    <xsl:when test="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"> 
		      <ul class="hierarchy">
		      <xsl:attribute name="name">
		      	 <xsl:value-of select="count(ancestor::*)-1"/>
		      </xsl:attribute>
		        <xsl:for-each select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		        	<xsl:if test="not(./@audience and ./@audience = 'internal')">
			          <li>
			            <xsl:call-template name="toc-c"/>
			          </li>
		            </xsl:if>
		        </xsl:for-each>
		      </ul>
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="id">
						<xsl:text>delete_</xsl:text><xsl:value-of select="./@c3id"/>
					</xsl:attribute>
					<xsl:attribute name="onclick">
			        	<xsl:text>javascript: deleteComponent('</xsl:text>
			        	<xsl:value-of select="./@c3id"/>       
			        	<xsl:text>')</xsl:text>
				  	</xsl:attribute>
				  	<xsl:attribute name="class">
                        <xsl:text>delete delete-sprite</xsl:text>
				  	</xsl:attribute>
                    <xsl:text>[X]</xsl:text>					
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

  <xsl:template name="toc-link">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <a>
      <xsl:attribute name="name">
      	<xsl:text>link</xsl:text>
      </xsl:attribute>
      <!-- check if all required xpaths are present or not -->
      <xsl:choose>
      	<xsl:when test="$level = 'collectionLevel'">
	      <xsl:choose>
		      <xsl:when test="$node/did/unitid and $node/did/unittitle and $node/did/unitdate and $node/did/unitdate/@normal and $node/did/repository and $node/did/origination and $node/did/physdesc/extent and $node/did/langmaterial/language and $node/scopecontent and $node/accessrestrict">
		      	<xsl:attribute name="class"><xsl:text>valid</xsl:text></xsl:attribute>
		      </xsl:when>
		      <xsl:otherwise>
		      	<xsl:attribute name="class"><xsl:text>invalid</xsl:text></xsl:attribute>
		      </xsl:otherwise>
		      </xsl:choose>
		  </xsl:when>
	     <xsl:otherwise>
	     	 <xsl:choose>
	     	 	<xsl:when test="$node/did/unitid and $node/did/unittitle and $node/did/unitdate">
			      	<xsl:attribute name="class"><xsl:text>valid</xsl:text></xsl:attribute>
			      </xsl:when>
			      <xsl:otherwise>
			      	<xsl:attribute name="class"><xsl:text>invalid</xsl:text></xsl:attribute>
			      </xsl:otherwise>
	      </xsl:choose>
	     </xsl:otherwise>
	  </xsl:choose>
      <xsl:choose>
        <xsl:when test="$level = 'collectionLevel'">
          <xsl:attribute name="id">
        	<xsl:text>collectionLevel</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="onclick">
        	<xsl:text>javascript: displayForm('collectionLevel')</xsl:text>
	  	  </xsl:attribute>
	  	  <xsl:attribute name="style"><xsl:text>background:yellow</xsl:text></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="id">
        	<xsl:value-of select="$node/@c3id"/>
      	  </xsl:attribute>
      	  <xsl:attribute name="onclick">
        	<xsl:text>javascript: displayForm('</xsl:text>
        	<xsl:value-of select="$node/@c3id"/>       
        	<xsl:text>')</xsl:text>
	  	  </xsl:attribute>
	 <!--  	  <xsl:attribute name="onclick">
        	<xsl:text>setCookie('RECID-tocstate', stateToString('someId'))</xsl:text>
      	  </xsl:attribute>-->
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
          <xsl:when test="$node/did/unitid[@type='persistent']">
            <xsl:value-of select="$node/did/unitid[@type='persistent']"/>
          </xsl:when>
          <xsl:when test="$node/did/unitid[@label='Former Reference']">
              <xsl:value-of select="$node/did/unitid[@label != 'Former Reference']"/>
          </xsl:when>
          <xsl:when test="$node/did/unitid[1]">
              <xsl:value-of select="$node/did/unitid[1]"/>
          </xsl:when>
          <xsl:otherwise/>
      </xsl:choose>
      <xsl:text> - </xsl:text>
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
