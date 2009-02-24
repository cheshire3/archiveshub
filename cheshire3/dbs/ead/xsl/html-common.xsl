<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
    This file was produced, and released as part of Cheshire for Archives v3.x.
    Copyright &#169; 2005-2009 the University of Liverpool.
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  version="1.0">

	<!-- include configurations from external file - over-rideable locally  (i.e. in this file) -->
	<xsl:include href="./configuration.xsl"/>
    
    <xsl:variable name="script" select="'SCRIPT'"/>
    <xsl:variable name="recid" select="'RECID'"/>
    <xsl:variable name="toc_cache_url" select="'TOC_CACHE_URL'"/>

	<!-- Strip all audience="internal" -->
	<xsl:template match="*[@audience='internal']" priority="100" />

  	<!-- DID -->
	<xsl:template match="did">
        <a>
        	<xsl:attribute name="name">
                <xsl:choose>
                	<xsl:when test="@id">
                        <xsl:value-of select="@id" />
                	</xsl:when>
                	<xsl:when test="unitid/@id">
                        <xsl:value-of select="unitid/@id" />
                	</xsl:when>
                	<xsl:otherwise>
                        <xsl:value-of select="generate-id(.)" />
                	</xsl:otherwise>
                </xsl:choose>
        	</xsl:attribute>
        	<xsl:text> </xsl:text>
        </a>
        
        <h2 class="unittitle">
            <xsl:choose>
                <xsl:when test="unittitle">
                    <xsl:apply-templates select="unittitle[1]"/>
                </xsl:when>
                <xsl:when test="/ead/archdesc/did/unittitle">
                    <xsl:apply-templates select="/ead/archdesc/did/unittitle"/>
                </xsl:when>
                <xsl:when test="/ead/eadheader/filedesc/titlestmt/titleproper">
                    <xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt/titleproper"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(untitled)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </h2>
		
        <xsl:if test="./dao|../dao|./daogrp|../daogrp">
            <div class="daos">
                <div class="daohead">Digital Objects</div>
                <div class="daobody">
                    <xsl:apply-templates select="./dao|../dao|./daogrp|../daogrp"/>
                </div>
            </div>
        </xsl:if>

	    <div class="did">
			<strong>Reference Number</strong><xsl:text>: </xsl:text>
			<xsl:choose>
			  <xsl:when test="unitid">
			    <xsl:apply-templates select="unitid[1]"/>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:text>(none)</xsl:text>
			  </xsl:otherwise>
			</xsl:choose>
			<br/>
	
			<xsl:if test="repository">
		   		<strong>Held at</strong><xsl:text>: </xsl:text>
		   		<xsl:variable name="repcode">
		   			<xsl:choose>
						<xsl:when test="unitid/@repositorycode">
							<xsl:value-of select="unitid/@repositorycode"/>
						</xsl:when>
						<xsl:when test="/ead/eadheader/eadid/@mainagencycode">
							<xsl:value-of select="/ead/eadheader/eadid/@mainagencycode"/>
						</xsl:when>
					</xsl:choose>
		   		</xsl:variable>
	  	 		<xsl:choose>
					<xsl:when test="$link_to_archon and string-length($repcode)">
						<a>
							<xsl:attribute name="href">
								<xsl:value-of select="$archon_url"/>
								<xsl:value-of select="$repcode" />
							</xsl:attribute>
							<xsl:attribute name="title">
								<xsl:text>Search Archon for Repository Contact Details [opens new window]</xsl:text>
							</xsl:attribute>
							<xsl:attribute name="target">
								<xsl:text>_blank</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="repository[1]"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="repository[1]"/>
					</xsl:otherwise>	
				</xsl:choose>
				<br/>
			</xsl:if>
				
			<strong>Dates of Creation</strong><xsl:text>: </xsl:text>
			<xsl:choose>
			  <xsl:when test=".//unitdate">
			    <xsl:apply-templates select=".//unitdate"/>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:text>[undated]</xsl:text>
			  </xsl:otherwise>
			</xsl:choose>
			<br/>
			
			<xsl:if test="physdesc">
			  <strong>Physical Description</strong><xsl:text>: </xsl:text>
			  <xsl:apply-templates select="physdesc"/><br/>
			</xsl:if>
	      
			<xsl:if test="origination">
			  <strong>Name of Creator</strong><xsl:text>: </xsl:text>
			  <xsl:for-each select="origination">
			  	<xsl:apply-templates/>
			  	<xsl:if test="position() &lt; count(../origination)">
				   	<xsl:text>,</xsl:text>
				</xsl:if>
			  </xsl:for-each>
			  <br/>
			</xsl:if>
			
			<xsl:if test="langmaterial">
			  <strong>Language of Material</strong><xsl:text>: </xsl:text>
				<xsl:apply-templates select="langmaterial"/>
			  <br/>
			</xsl:if>
			
			<xsl:if test="processinfo">
			  <xsl:apply-templates select="processinfo"/><br/>
			</xsl:if>
		
		</div>
	</xsl:template>

	<!-- EADHEADER -->
	<xsl:template match="eadheader">
		<strong>Cataloguing Info</strong> <xsl:text> </xsl:text>
		<a href="#eadheader" class="jstoggle-text">[ hide ]</a>
		<div id="eadheader" class="jshide">
			<xsl:apply-templates select="filedesc"/>
			<xsl:apply-templates select="profiledesc"/>
			<xsl:apply-templates select="revisiondesc"/>
		</div>
	</xsl:template>

	<xsl:template match="filedesc">
		<xsl:if test="titlestmt">
			<xsl:apply-templates select="titlestmt"/>
		</xsl:if>
 		<xsl:if test="publicationstmt">
 			<strong>Publication</strong><xsl:text>: </xsl:text>
 			<xsl:apply-templates select="publicationstmt"/><br/>
		</xsl:if>
 		<xsl:if test="editionstmt">
 			<strong>Edition</strong><xsl:text>: </xsl:text>
  			<xsl:apply-templates select="editionstmt"/><br/>
		</xsl:if>
	 	<xsl:if test="seriesstmt">
	 		<strong>Series</strong><xsl:text>: </xsl:text>
		  	<xsl:apply-templates select="seriesstmt"/><br/>
		</xsl:if>
		<xsl:if test="notesstmt">
 			<strong>Notes</strong><xsl:text>: </xsl:text>
		  	<xsl:apply-templates select="notesstmt"/><br/>
		</xsl:if>
	</xsl:template>
 
	<xsl:template match="titlestmt">
		<!-- ignore titleproper, usually the same as title of material (unittitle) -->
		<xsl:if test="titleproper">
			<strong>Title</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="titleproper"/><br/>
		</xsl:if>
		<xsl:if test="subtitle">
			<strong>Sub-title</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="subtitle"/><br/>
		</xsl:if>
		<xsl:for-each select="author">
			<strong>Author</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="."/><br/>
		</xsl:for-each>
		<xsl:if test="sponsor">
			<strong>Sponsor</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="sponsor"/><br/>
		</xsl:if>
	</xsl:template>
 
	<xsl:template match="profiledesc">
		<xsl:if test="creation">
			<strong>Creation</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="./creation"/><br/>
		</xsl:if>
		<xsl:if test="descrules">
			<strong>Descriptive Rules</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="./descrules"/><br/>
		</xsl:if>
		<xsl:if test="langusage">
			<strong>Language Usage</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates select="./langusage"/><br/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="revisiondesc">      
		<xsl:if test="./text()">
			<strong>Revisions</strong><xsl:text>: </xsl:text>
			<xsl:apply-templates/><br/>
		</xsl:if>
	</xsl:template>

	<!--  ARCHDESC -->
	<xsl:template match="archdesc">
		<!--TEMPLATES FOR MAIN BODY-->
		<xsl:apply-templates select="./did/abstract"/>
		<xsl:apply-templates select="./scopecontent"/>
		<xsl:apply-templates select="./bioghist"/>
		<xsl:apply-templates select="./arrangement"/>
		<xsl:apply-templates select="./descgrp" />
	
		<xsl:if test="./admininfo">
			<div class="admininfo">
		  	<xsl:apply-templates select="./admininfo" />
			</div>
		</xsl:if>
		
		<xsl:if test="./add">
			<div class="add">
				<xsl:apply-templates select="./add" />
		 	</div>
		</xsl:if>
		
		<!-- ACCESS + USE RESTRICTIONS -->
		<xsl:apply-templates select="./accessrestrict"/>
		<xsl:apply-templates select="./userestrict"/>
        <xsl:apply-templates select="./phystech"/>
        
		<!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY-->
		<xsl:apply-templates select="./appraisal"/>
		<xsl:apply-templates select="./acqinfo"/>
		<xsl:apply-templates select="./custodhist"/>
		<xsl:apply-templates select="./accruals"/>
		<xsl:apply-templates select="./processinfo"/>
		<!-- USER INFO -->
		<xsl:apply-templates select="./otherfindaid"/>
		<xsl:apply-templates select="./originalsloc"/>
		<xsl:apply-templates select="./altformavail"/>
		<xsl:apply-templates select="./relatedmaterial"/>
		<xsl:apply-templates select="./separatedmaterial"/>
		<!-- BIBLIOGRAPHY / CITATIONS -->
		<xsl:apply-templates select="./bibliography"/>
		<xsl:apply-templates select="./prefercite"/>
		<!-- MISCELLANEOUS -->
		<xsl:apply-templates select="./odd"/>
		<xsl:apply-templates select="./note" mode="own-section"/>
		
		<!-- CONTROLACCESS -->
		<xsl:apply-templates select="./controlaccess"/>
		<xsl:text> </xsl:text> 
	</xsl:template>


	<xsl:template match="langmaterial|langusage">
		<xsl:choose>
			<xsl:when test="not(./text())">
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
	
	<xsl:template match="bioghist">
		<xsl:if test="@id">
			<a name="{@id}"><xsl:text> </xsl:text></a>
		</xsl:if>
		<xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Administrative / Biographical History</xsl:text></xsl:variable>
		 	<xsl:choose>
		 		<xsl:when test="../../archdesc or ../../../c3component">
		 			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
		 		</xsl:when>
				<xsl:otherwise>
					<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="scopecontent">
	  	<xsl:if test="@id">
	  		<a name="{@id}"><xsl:text> </xsl:text></a>
	  	</xsl:if>
        
	    <xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Scope and Content</xsl:text></xsl:variable>
	    	<xsl:choose>
		  		<xsl:when test="../../archdesc or ../../../c3component">
		  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
		  		</xsl:when>
				<xsl:otherwise>
					<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
				</xsl:otherwise>
	    	</xsl:choose>
	    </xsl:if>
    	<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="arrangement">
  		<xsl:if test="@id">
  			<a name="{@id}"><xsl:text> </xsl:text></a>
	  	</xsl:if>
	    <xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Arrangement</xsl:text></xsl:variable>
	    	<xsl:choose>
		  		<xsl:when test="../../archdesc  or ../../../c3component">
		  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
		  		</xsl:when>
		      	<xsl:otherwise>
		      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
		      	</xsl:otherwise>
		    </xsl:choose>
    	</xsl:if>
    	<xsl:apply-templates/>
	</xsl:template>

	<!-- ACCESS + USE RESTRICTIONS -->
  <xsl:template match="accessrestrict">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Conditions Governing Access</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc  or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="userestrict">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Conditions Governing Use</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="phystech">
    <xsl:if test="@id">
        <a name="{@id}"><xsl:text> </xsl:text></a>
    </xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Physical Characteristics and/or Technical Requirements</xsl:text></xsl:variable>
        <xsl:choose>
            <xsl:when test="../../archdesc or ../../../c3component">
                <h3 class="ead"><xsl:value-of select="$headstring"/></h3>
            </xsl:when>
        <xsl:otherwise>
            <h4 class="ead"><xsl:value-of select="$headstring"/></h4>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  
    <!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY-->
    <xsl:template match="admininfo">
        <xsl:if test="@id">
        	<a name="{@id}"><xsl:text> </xsl:text></a>
        </xsl:if>
        <xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Administrative Information</xsl:text></xsl:variable>
            <xsl:choose>
          		<xsl:when test="../../archdesc or ../../../c3component">
          			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
          		</xsl:when>
                <xsl:otherwise>
                	<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
  
  
    <xsl:template match="appraisal">
      	<xsl:if test="@id">
      		<a name="{@id}"><xsl:text> </xsl:text></a>
      	</xsl:if>
        <xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Appraisal Information</xsl:text></xsl:variable>
        	<xsl:choose>
    	  		<xsl:when test="../../archdesc or ../../../c3component">
    	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
    	  		</xsl:when>
          	<xsl:otherwise>
          		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
          	</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
  
  <xsl:template match="acqinfo">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>	  
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Acquisition Information</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="custodhist">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Custodial History</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="accruals">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Accruals</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="processinfo">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Archivist's Note</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  
  <!-- USER INFO -->
	<!--  OTHER FINDING AIDS -->
  <xsl:template match="otherfindaid">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Other Finding Aid</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

	<!-- ORIGINAL + ALTERNATIVE FORMS -->
  <xsl:template match="originalsloc">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Location of Originals</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="altformavail">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Alternative Form Available</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

	<!-- SEPARATED + RELATED MATERIAL -->
    <xsl:template match="relatedmaterial">
      	<xsl:if test="@id">
      		<a name="{@id}"><xsl:text> </xsl:text></a>
      	</xsl:if>
        <xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Related Material</xsl:text></xsl:variable>
        	<xsl:choose>
    	  		<xsl:when test="../../archdesc or ../../../c3component">
    	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
    	  		</xsl:when>
          	<xsl:otherwise>
          		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
          	</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
  
  <xsl:template match="separatedmaterial">
  	<xsl:if test="@id">
  		<a name="{@id}"><xsl:text> </xsl:text></a>
  	</xsl:if>
    <xsl:if test="not(head/text())">
        <xsl:variable name="headstring"><xsl:text>Separated Material</xsl:text></xsl:variable>
    	<xsl:choose>
	  		<xsl:when test="../../archdesc or ../../../c3component">
	  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
	  		</xsl:when>
      	<xsl:otherwise>
      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- BIBLIOGRAPHY / CITATIONS -->	
	<xsl:template match="bibliography">
		<xsl:if test="@id">
		  <a name="{@id}"><xsl:text> </xsl:text></a>
		</xsl:if>
        <xsl:variable name="headstring"><xsl:text>Bibliography</xsl:text></xsl:variable>
		<xsl:choose>
			<xsl:when test="head/text()">
				<xsl:apply-templates select="head" />
			</xsl:when>
			<xsl:when test="../../archdesc or ../../../c3component">
				<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
			</xsl:when>
			<xsl:otherwise>
				<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="bibref">
			  <ol>
			    <xsl:for-each select="bibref">
			      <li><xsl:apply-templates select="." /></li>
			    </xsl:for-each>
			  </ol>
			</xsl:when>
		    <xsl:otherwise>
		      <xsl:apply-templates select="*[local-name()!='head']" />
		    </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="prefercite">
  		<xsl:if test="@id">
  			<a name="{@id}"><xsl:text> </xsl:text></a>
  		</xsl:if>
		<xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Preferred Citation</xsl:text></xsl:variable>
			<xsl:choose>
		  		<xsl:when test="../../archdesc or ../../../c3component">
		  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
		  		</xsl:when>
	      		<xsl:otherwise>
	      			<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
		      	</xsl:otherwise>
      		</xsl:choose>
	  	</xsl:if>
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- 
	<xsl:template match="title">
		<xsl:choose>
			<xsl:when test="./@render or ./@altrender">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<em><xsl:apply-templates/></em>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	-->
	
	<!-- ODD -->
	<xsl:template match="odd">
	  	<xsl:if test="@id">
	  		<a name="{@id}"><xsl:text> </xsl:text></a>
	  	</xsl:if>
		<xsl:if test="not(head/text())">
            <xsl:variable name="headstring"><xsl:text>Other Descriptive Data</xsl:text></xsl:variable>
			<xsl:choose>
		  		<xsl:when test="../../archdesc or ../../../c3component">
		  			<h3 class="ead"><xsl:value-of select="$headstring"/></h3>
		  		</xsl:when>
		      	<xsl:otherwise>
		      		<h4 class="ead"><xsl:value-of select="$headstring"/></h4>
		      	</xsl:otherwise>
			</xsl:choose>	
	  	</xsl:if>
		<xsl:apply-templates />
	</xsl:template>
	

    <!-- CONTROLLED ACCESS TERMS -->
    <xsl:template match="controlaccess">
        <xsl:if test="@id">
    	   <a name="{@id}"><xsl:text> </xsl:text></a>
        </xsl:if>
        <xsl:variable name="headstring"><xsl:text>Access Points</xsl:text></xsl:variable>
        <xsl:choose>
            <xsl:when test="local-name(..) = 'controlaccess'" />
            <xsl:when test="head/text()">
                <xsl:apply-templates select="head"/>
            </xsl:when>
            <xsl:when test="../../archdesc or ../../../c3component">
                <h3 class="ead"><xsl:value-of select="$headstring"/></h3>
            </xsl:when>
            <xsl:otherwise>
                <h4 class="ead"><xsl:value-of select="$headstring"/></h4>  
            </xsl:otherwise>
        </xsl:choose>
		
        <table>
		
            <!-- Subjects -->
            <xsl:if test="subject">
                <xsl:variable name="indexName"><xsl:text>Subjects</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                    <xsl:for-each select="subject">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                              <xsl:with-param name="index">
                                <xsl:text>dc.subject</xsl:text>
                              </xsl:with-param>
                              <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <!-- cross-search links -->
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
            	
            <!-- Personal Names -->
            <xsl:if test="persname">
                <xsl:variable name="indexName"><xsl:text>Personal Names</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="persname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.personalName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink"/>		    	
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
		
            <!-- Family Names -->
            <xsl:if test="famname">
                <xsl:variable name="indexName"><xsl:text>Family Names</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="famname">
                    <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>ead.familyName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink"/>		    	
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
		
            <!-- Corporate Names -->
            <xsl:if test="corpname">
                <xsl:variable name="indexName"><xsl:text>Corporate Names</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="corpname">
                    <tr>
                	  	<td>
                		    <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.corporateName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                		    </xsl:call-template>
                		</td>
                		<td class="cross-search">
                            <xsl:if test="$link_to_wikipedia">
                                <xsl:call-template name="wikipedialink"/>    	
                		    </xsl:if>
                		</td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
		
            <!-- Geographical Names -->
            <xsl:if test="geogname">
                <xsl:variable name="indexName"><xsl:text>Geographical Names</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="geogname">
    	  	        <tr>
                        <td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.geographicName</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
            			<td class="cross-search">
                            <!--  cross search links -->
                            <xsl:if test="$link_to_googlemaps">
                                <xsl:call-template name="googlemapslink"/>
                            </xsl:if>
            			</td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
		
            <xsl:if test="title">
                <xsl:variable name="indexName"><xsl:text>Titles</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="title">
                    <tr>
                		<td><xsl:apply-templates/></td>
                		<!--  cross search links -->
                		<td class="cross-search">
                            <xsl:if test="$link_to_copac">
    				            <xsl:call-template name="copaclink"/>								    	
                            </xsl:if>
                        </td>
                        <td class="cross-search">
                            <xsl:if test="$link_to_amazon">
    				            <xsl:call-template name="amazonlink"/>								    	
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:if>
            
            <xsl:if test="function">
                <xsl:variable name="indexName"><xsl:text>Functions</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="function">
                    <tr>
                        <td><xsl:value-of select = "."/></td>
                    </tr>
                </xsl:for-each>
            </xsl:if> 
            
            <xsl:if test="genreform">
                <xsl:variable name="indexName"><xsl:text>Genre/Form</xsl:text></xsl:variable>
                <tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
                <xsl:for-each select="genreform">
                    <tr>
                  		<td>
                            <xsl:call-template name="browselink">
                                <xsl:with-param name="index">
                                    <xsl:text>bath.genreForm</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="indexName">
                                    <xsl:value-of select="$indexName"/>
                                </xsl:with-param>
                            </xsl:call-template>
                    	</td>
                    </tr>
            	</xsl:for-each>
            </xsl:if>
            
            <xsl:if test="occupation">
                <xsl:variable name="indexName"><xsl:text>Occupation</xsl:text></xsl:variable>
            	<tr><td colspan="2"><strong><xsl:value-of select="$indexName"/></strong></td></tr>
            	<xsl:for-each select="occupation">
                    <tr>
                        <td>
                            <xsl:value-of select = "."/>
                        </td>
                    </tr>
            	</xsl:for-each>
            </xsl:if>
		
        </table>
      
        <xsl:apply-templates select="controlaccess" />

    </xsl:template>
	
	
    <!-- COMPONENT -->
    <xsl:template name="single-component">
        <a>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"/>
                    </xsl:when>
                    <xsl:when test="did/@id">
                        <xsl:value-of select="did/@id"/>
                    </xsl:when>
                    <xsl:when test="did/unitid/@id">
                        <xsl:value-of select="did/unitid/@id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id(did)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </a>
        <h3>
            <xsl:apply-templates select ="did/unittitle"/>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <xsl:when test="did//unitdate">
                    <xsl:value-of select="did//unitdate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>undated</xsl:text>
                </xsl:otherwise>
	    </xsl:choose>
            <xsl:text>)</xsl:text>
            <xsl:if test="did/origination">
                <xsl:text> - </xsl:text>
      		<xsl:apply-templates select="did/origination"/>
    	   </xsl:if>
        </h3>
        
        <xsl:if test="./dao|./did/dao|./daogrp|./did/daogrp">
            <div class="daos">
                <div class="daohead">Digital Objects</div>
                <div class="daobody">
                    <xsl:apply-templates select="./dao|./did/dao|./daogrp|./did/daogrp"/>
                </div>
            </div>
        </xsl:if>
        
        <xsl:if test="did/unitid">
            <strong>Reference Number</strong>:
            <xsl:for-each select="did/unitid">
                <xsl:apply-templates select="."/><br/>
            </xsl:for-each>
        </xsl:if>
        
        <xsl:if test="did/physdesc">
            <strong>Physical Description</strong><xsl:text>: </xsl:text>
            <xsl:apply-templates select="did/physdesc"/><br/>
        </xsl:if>
        
        <xsl:if test="langmaterial|did/langmaterial">
            <strong>Language of Material</strong><xsl:text>: </xsl:text>
            <xsl:choose>
                <xsl:when test="langmaterial">
                    <xsl:apply-templates select="langmaterial"/>
                </xsl:when>
                <xsl:when test="did/langmaterial">
                    <xsl:apply-templates select="did/langmaterial"/>
                </xsl:when>
            </xsl:choose>
          <br/>
        </xsl:if>
	
    	<xsl:if test = "did/physloc">
    	  <xsl:value-of select="did/physloc"/>
    	</xsl:if>
    			
    	<xsl:apply-templates select="did/note" mode="own-section"/>
    	<xsl:apply-templates select="scopecontent"/>
    	<xsl:apply-templates select="bioghist"/>
    	<xsl:apply-templates select="arrangement"/>
     
    	<xsl:if test="admininfo">
    		<xsl:apply-templates select="admininfo" />
    	</xsl:if>
           
    	<!-- ACCESS + USE RESTRICTIONS -->
    	<xsl:apply-templates select="accessrestrict"/>
    	<xsl:apply-templates select="userestrict"/>
        <xsl:apply-templates select="phystech"/>
    	<!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY-->
    	<xsl:apply-templates select="appraisal"/>
    	<xsl:apply-templates select="acqinfo"/>
    	<xsl:apply-templates select="custodhist"/>
    	<xsl:apply-templates select="accruals"/>
    	<xsl:apply-templates select="processinfo"/>
    	<!-- USER INFO -->
    	<xsl:apply-templates select="otherfindaid"/>
    	<xsl:apply-templates select="originalsloc"/>
    	<xsl:apply-templates select="altformavail"/>
    	<xsl:apply-templates select="relatedmaterial"/>
    	<xsl:apply-templates select="separatedmaterial"/>
    	<!-- BIBLIOGRAPHY / CITATIONS -->
    	<xsl:apply-templates select="bibliography"/>
    	<xsl:apply-templates select="prefercite"/>
    	<!-- MISCELLANEOUS -->
    	<xsl:apply-templates select="odd"/>
        <xsl:apply-templates select="note" mode="own-section"/>
    	
    	<!-- CONTROLACCESS -->
    	<xsl:apply-templates select="controlaccess"/>
    			
    	<xsl:apply-templates select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"/>
    </xsl:template>


	<!--HEAD-->
	<xsl:template match="head">
        <xsl:if test="./text()">
    		<xsl:choose>
    			<xsl:when test="../../head or not(../../../archdesc or ../../../../c3component)">
    				<h4 class="ead"><xsl:apply-templates /></h4>
    			</xsl:when>
    			<xsl:otherwise>
    				<h3 class="ead"><xsl:apply-templates /></h3>				
    			</xsl:otherwise>
    		</xsl:choose>
        </xsl:if>
	</xsl:template>
    
    <xsl:template match="head" mode="inline">
        <b><xsl:value-of select="."/></b><xsl:text>: </xsl:text>
    </xsl:template>
	

	<!-- ADDRESS -->
	<xsl:template match="address">
		<address>
			<xsl:apply-templates />
		</address>
	</xsl:template>
	
	<xsl:template match="addressline">
		<xsl:apply-templates />
		<xsl:text>, </xsl:text>
	</xsl:template>
	
	<!-- DATE -->
	<xsl:template match="date">
	  <xsl:apply-templates/>
	</xsl:template>
	
	<!--NOTES-->
	<xsl:template match="bioghist/note">
		<xsl:if test="not(head/text())">	
	  		<br/><b><xsl:text>Bibliographic Sources</xsl:text></b>
  		</xsl:if>
	  <xsl:apply-templates/>
	</xsl:template>
    
    <xsl:template match="note">
        <xsl:text>[ </xsl:text>
        <xsl:if test="not(head/text())">   
            <b><xsl:text>Note</xsl:text></b><xsl:text>: </xsl:text>
        </xsl:if>
            <xsl:apply-templates mode="inline"/>        
        <xsl:text> ]</xsl:text>
    </xsl:template>
    
    <xsl:template match="note" mode="own-section">
        <xsl:if test="not(head/text())">   
            <br/><b><xsl:text>Note</xsl:text></b>
        </xsl:if>
      <xsl:apply-templates/>
    </xsl:template>
    
	
    <!-- Simple Link -->
    <xsl:template name="simplelink">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="./@href"/>
            </xsl:attribute>
            <xsl:if test="./@title">
                <xsl:attribute name="title">
                    <xsl:value-of select="./@title"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="./@show = 'new'">
                        <xsl:text>_new</xsl:text>
                    </xsl:when>
                    <xsl:when test="./@show = 'replace'">
                        <xsl:text>_parent</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>_blank</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
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
        </xsl:element>
    </xsl:template>

	<!-- IMAGES-->
	<xsl:template name="image">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="./@href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="./@title"/>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_new</xsl:text>
            </xsl:attribute>
    		<xsl:element name="img">
    			<xsl:attribute name="src">
    				<xsl:value-of select="./@href"/>
    			</xsl:attribute>
    			<xsl:attribute name="alt">
    				<xsl:choose>
                        <xsl:when test="./@title">
                              <xsl:value-of select="./@title"/>
                        </xsl:when>
    					<xsl:when test="./daodesc">
                            <xsl:variable name="txt">
                                <xsl:value-of select="string(./daodesc)"/>
                            </xsl:variable>
                            <xsl:value-of select="normalize-space($txt)"/>
    					</xsl:when>
    				    <xsl:otherwise>
    						<xsl:value-of select="./@href"/>
    					</xsl:otherwise>
    				</xsl:choose>
    			</xsl:attribute>
    		</xsl:element>
        </xsl:element>
        <!-- caption -->
        <xsl:apply-templates select="./daodesc"/>
	</xsl:template>

	<!--BUILDING REFS AND ANCS-->
	<xsl:template match="ref[@target]">
		<a>
			<xsl:attribute name="href">
				<xsl:text>PAGE#</xsl:text>
				<xsl:value-of select="./@target"/>
			</xsl:attribute>
			<xsl:attribute name="target">
				<xsl:text>_top</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates />
		</a>
	</xsl:template>
    
    <!-- ARCHREF  -->
    <xsl:template match="archref">
        <xsl:element name="a">
            <xsl:if test="./@title">
                <xsl:attribute name="title">
                  <xsl:value-of select="./@title"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="./@show = 'new'">
                        <xsl:text>_new</xsl:text>
                    </xsl:when>
                    <xsl:when test="./@show = 'replace'">
                        <xsl:text>_parent</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>_blank</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:value-of select="$script"/>
                        <xsl:text>?</xsl:text>
                        <xsl:text>operation=full</xsl:text>
                        <xsl:text>&amp;recid=</xsl:text>
                        <xsl:call-template name="normalizeEadid">
                            <xsl:with-param name="text">
                                <xsl:value-of select="@href"/>        
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner HTML -->
            <xsl:value-of select="string(.)"/>
        </xsl:element>
    </xsl:template>
    
    <!--EXTREFS-->
    <xsl:template match="extref">
        <xsl:call-template name="simplelink" />
    </xsl:template>
	
    <!-- extptr -->
    <xsl:template match="extptr">
        <xsl:choose>
            <xsl:when test="./@audience = 'internal'" />
            <xsl:when test="./@href">
                <xsl:choose>
                    <xsl:when test="@show='embed'">
                        <xsl:call-template name="image" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="simplelink" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="title">
                    <xsl:text>Location of Digital Object not provided.</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 	
    <!--DAO - Digital Archival Objects-->  
    <xsl:template match="dao">
        <div class="dao">
            <xsl:choose>
                <xsl:when test="./@audience = 'internal'" />
                <xsl:when test="./@href">
                    <xsl:choose>
                        <xsl:when test="@show='embed'">
                            <xsl:call-template name="image" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="simplelink" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="title">
                        <xsl:text>Location of Digital Object not provided.</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
	
    <!-- DAOGRPs -->
    <xsl:template match="daogrp">
        <xsl:choose>
        	<xsl:when test="./@audience = 'internal'" />
        	<xsl:when test="count(./daoloc) = 2 and ./daoloc/@role='thumb'">
        		<xsl:call-template name="daogrp-thumb"/>
        	</xsl:when>
        	<xsl:otherwise>
        		<xsl:call-template name="daogrp-multi" />
        	</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- DAOGRP - representing thumbnail link to main object -->
    <xsl:template name="daogrp-thumb">
        <div class="dao">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="./daoloc[@role='reference']/@href"/>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:text>View File</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:choose>
                        <xsl:when test="./@show='new'">
                            <xsl:text>_new</xsl:text>
                        </xsl:when>
                        <xsl:when test="./@show='replace'">
                            <xsl:text>_parent</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>_blank</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <!--  inner HTML -->
                <xsl:choose>
                	<xsl:when test="./daoloc/@role='thumb'">
                        <xsl:element name="img">
                            <xsl:attribute name="src">
                                <xsl:value-of select="./daoloc[@role='thumb']/@href"/>
                            </xsl:attribute>
                            <xsl:attribute name="alt">
                                <xsl:choose>
                                    <xsl:when test="./daoloc[@role='thumb']/@title">
                                        <xsl:value-of select="./daoloc[@role='thumb']/@title"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Thumbnail unavailable</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:element>
                        <br/>
                	</xsl:when>
                	<xsl:when test="./@title">
                        <xsl:value-of select="./@title"/>
                    </xsl:when>
                	<xsl:otherwise>
                        <xsl:text>Full file</xsl:text>
                	</xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <!-- caption -->
            <xsl:apply-templates select="./daodesc" />
        </div>
    </xsl:template>
	
    <!-- DAOGRP - representing single, bundled or nested links + description -->
    <xsl:template name="daogrp-multi">
        <xsl:apply-templates select="./daodesc" />
        <xsl:for-each select="daoloc">
            <div class="dao">
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
                                <xsl:call-template name="simplelink" />
<!--                				<xsl:element name="a">-->
<!--                                    <xsl:attribute name="href">-->
<!--                                    	<xsl:value-of select="./@href"/>-->
<!--                                    </xsl:attribute>-->
<!--                                    <xsl:attribute name="target">-->
<!--                                        <xsl:choose>-->
<!--                                            <xsl:when test="../@show='new'">-->
<!--                                                <xsl:text>_new</xsl:text>-->
<!--                                            </xsl:when>-->
<!--                                            <xsl:when test="../@show='replace'">-->
<!--                                                <xsl:text>_parent</xsl:text>-->
<!--                                            </xsl:when>-->
<!--                                            <xsl:otherwise>-->
<!--                                                <xsl:text>_blank</xsl:text>-->
<!--                                            </xsl:otherwise>-->
<!--                                        </xsl:choose>-->
<!--                                    </xsl:attribute>-->
<!--                                    <xsl:choose>-->
<!--                                        <xsl:when test="./daodesc">-->
<!--                                            <xsl:apply-templates select="string(./daodesc)"/>-->
<!--                                        </xsl:when>-->
<!--                                        <xsl:when test="./@title">-->
<!--                                            <xsl:value-of select="./@title"/>-->
<!--                                        </xsl:when>-->
<!--                                        <xsl:when test="../@title">-->
<!--                                            <xsl:value-of select="../@title"/>-->
<!--                                        </xsl:when>-->
<!--                                        <xsl:when test="./@label">-->
<!--                                            <xsl:value-of select="./@label"/>-->
<!--                                        </xsl:when>-->
<!--                                        <xsl:otherwise>-->
<!--                                            <xsl:value-of select="./@href"/>-->
<!--                                        </xsl:otherwise>-->
<!--                                    </xsl:choose>-->
<!--                                </xsl:element>-->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:for-each>
    </xsl:template>
		
	<!--LINE BREAKS-->
	<xsl:template match="lb">
	  <br/>
	</xsl:template>

	<!-- CHANGES e.g. in revisiondesc -->
	<xsl:template match="change">
		<div>
			<xsl:apply-templates select="date"/>
		  	<ul>
		    	<xsl:for-each select="item">
		      	<li><xsl:apply-templates select="."/></li>
		      </xsl:for-each>
		    </ul>
		</div>
	</xsl:template>
	
	<!--LISTS-->
	<xsl:template match="list">
	  <xsl:choose>
	    <xsl:when test="@type='ordered'">
	      <ol>
	        <xsl:for-each select="item">
	          <li><xsl:apply-templates/></li>
	        </xsl:for-each>
	      </ol>
	    </xsl:when>
	    <xsl:when test="@type='unordered'">
	      <ul>
	        <xsl:for-each select="item">
	          <li><xsl:apply-templates/></li>
	        </xsl:for-each>        
	      </ul>
	    </xsl:when>
	    <xsl:when test="@type='marked'">
	      <ul>
	        <xsl:for-each select="item">
	          <li><xsl:apply-templates/></li>
	        </xsl:for-each>       
	      </ul>
	    </xsl:when>
	    <xsl:when test="@type='simple'">
	      <ul type="none">
	        <xsl:for-each select="item">
	          <li><xsl:apply-templates/></li>
	        </xsl:for-each>        
	      </ul>
	    </xsl:when>
	    <xsl:otherwise>
	      <ul>
	        <xsl:for-each select="item">
	          <li><xsl:apply-templates/></li>
	        </xsl:for-each>
	      </ul>
	    </xsl:otherwise> 
	  </xsl:choose>
	</xsl:template>
	
	<!--CHRON LISTS-->
	<xsl:template match="chronlist">
	  <ul>
	    <xsl:for-each select="chronitem">
	      <xsl:value-of select ="."/><br/>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	
	<!-- MISCELLANEOUS -->
	<xsl:template match="p">
      	<xsl:if test="@id">
            <a name="{@id}"><xsl:text> </xsl:text></a>
        </xsl:if>
      	<p>
      		<xsl:apply-templates />
      	</p>
	</xsl:template>
    
    <xsl:template match="p" mode="inline">
        <xsl:if test="@id">
            <a name="{@id}"><xsl:text> </xsl:text></a>
        </xsl:if>
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="blockquote">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>

	<xsl:template match="defitem">
		<xsl:apply-templates/>
		<xsl:text>; </xsl:text>
	</xsl:template>
	
	<!-- rendering/altrendering for all elements -->	
	<xsl:template match="*">
		<xsl:choose>
			<!--  @render -->
			<xsl:when test="@render='bold'">
				<b><xsl:apply-templates /></b>
			</xsl:when>
			<xsl:when test="@render='italic'">
				<i><xsl:apply-templates /></i>
			</xsl:when>
			<xsl:when test="@render='underline'">
				<u><xsl:apply-templates /></u>
			</xsl:when>
			<xsl:when test="@render='quoted'">
				<xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text>
			</xsl:when>
			<xsl:when test="@render='singlequote'">
				<xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text>
			</xsl:when>
			<xsl:when test="@render='doublequote'">
				<xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="@render='bolditalic'">
				<b><i><xsl:apply-templates /></i></b>
			</xsl:when>
			<xsl:when test="@render='boldunderline'">
				<b><u><xsl:apply-templates /></u></b>
			</xsl:when>
			<xsl:when test="@render='boldquoted'">
				<b><xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text></b>
			</xsl:when>
			<xsl:when test="@render='bolddoublequote'">
				<b><xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text></b>
			</xsl:when>
			<!--  @altrender -->
	   		<xsl:when test="@altrender='bold'">
	       		<b><xsl:apply-templates /></b>
			</xsl:when>
			<xsl:when test="@altrender='italic'">
				<i><xsl:apply-templates /></i>
			</xsl:when>
			<xsl:when test="@altrender='underline'">
			   <u><xsl:apply-templates /></u>
			</xsl:when>
			<xsl:when test="@altrender='quoted'">
			   <xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text>
			</xsl:when>
			<xsl:when test="@altrender='doublequote'">
			   <xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text>
			</xsl:when>
			<xsl:when test="@altrender='bolditalic'">
			   <b><i><xsl:apply-templates /></i></b>
			</xsl:when>
			<xsl:when test="@altrender='boldunderline'">
			   <b><u><xsl:apply-templates /></u></b>
			</xsl:when>
			<xsl:when test="@altrender='boldquoted'">
			   <b><xsl:text>&apos;</xsl:text><xsl:apply-templates /><xsl:text>&apos;</xsl:text></b>
			</xsl:when>
			<xsl:when test="@altrender='bolddoublequote'">
			   <b><xsl:text>&quot;</xsl:text><xsl:apply-templates /><xsl:text>&quot;</xsl:text></b>
			 </xsl:when>
			<xsl:when test="@altrender='italicunderline'">
			 	<i><u><xsl:value-of select="."/></u></i>
			</xsl:when>
			<xsl:when test="@altrender='italicquoted'">
			 	<i><xsl:text>&apos;</xsl:text><xsl:value-of select="."/><xsl:text>&apos;</xsl:text></i>
			</xsl:when>
			<xsl:when test="@altrender='italicdoublequote'">
			 	<i><xsl:text>&quot;</xsl:text><xsl:value-of select="."/><xsl:text>&quot;</xsl:text></i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="local-name() = 'title'">
						<em><xsl:apply-templates /></em>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
	    </xsl:choose>
	</xsl:template>
	
	
	<!-- Template for making string cgi link friendly -->
	<xsl:template name="cgiencode">
	    <xsl:param name="text"/>
	    <xsl:call-template name="replace-substring">
		    <xsl:with-param name="original">
			    <xsl:call-template name="replace-substring">
		  		  <xsl:with-param name="original">
			    		<xsl:value-of select="translate(normalize-space($text),' ', '+')"/>
	    			</xsl:with-param>
			    	<xsl:with-param name="substring"><xsl:text>THGLHGH</xsl:text></xsl:with-param>
	    			<xsl:with-param name="replacement"><xsl:text></xsl:text></xsl:with-param>
	   			</xsl:call-template>
	    	</xsl:with-param>
	    	<xsl:with-param name="substring"><xsl:text>HGHLGHT</xsl:text></xsl:with-param>
	    	<xsl:with-param name="replacement"><xsl:text></xsl:text></xsl:with-param>
	   	</xsl:call-template>
	</xsl:template>
	
	<!-- Template for making string Wikipedia friendly -->
	<xsl:template name="wikipediacgiencode">
	    <xsl:param name="text"/>
	    <xsl:call-template name="replace-substring">
		    <xsl:with-param name="original">
			    <xsl:call-template name="replace-substring">
		  		  <xsl:with-param name="original">
			    		<xsl:value-of select="translate(normalize-space($text),' ', '_')"/>
	    			</xsl:with-param>
			    	<xsl:with-param name="substring"><xsl:text>THGLHGH</xsl:text></xsl:with-param>
	    			<xsl:with-param name="replacement"><xsl:text></xsl:text></xsl:with-param>
	   			</xsl:call-template>
	    	</xsl:with-param>
	    	<xsl:with-param name="substring"><xsl:text>HGHLGHT</xsl:text></xsl:with-param>
	    	<xsl:with-param name="replacement"><xsl:text></xsl:text></xsl:with-param>
	   	</xsl:call-template>
	</xsl:template>
  
  
	<!--  template to carry out recursive string replacements -->
  <xsl:template name="replace-substring">
  	<xsl:param name="original"/>
  	<xsl:param name="substring"/>
  	<xsl:param name="replacement" select="''"/>
		<xsl:variable name="first">
			<xsl:choose>
				<xsl:when test="contains($original, $substring)">
					<xsl:value-of select="substring-before($original, $substring)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$original"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="middle">
			<xsl:choose>
				<xsl:when test="contains($original, $substring)">
					<xsl:value-of select="$replacement"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="last">
			<xsl:choose>
				<xsl:when test="contains($original, $substring)">
					<xsl:choose>
						<xsl:when test="contains(substring-after($original, $substring), $substring)">
							<xsl:call-template name="replace-substring">
								<xsl:with-param name="original">
									<xsl:value-of select="substring-after($original, $substring)"/>
								</xsl:with-param>
								<xsl:with-param name="substring"><xsl:value-of select="$substring"/></xsl:with-param>
								<xsl:with-param name="replacement"><xsl:value-of select="$replacement"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after($original, $substring)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat($first, $middle, $last)"/>
  </xsl:template>
  
  
	<!-- template for constructing browse links, given the name of the index to browse -->
	<xsl:template name="browselink">
    	<xsl:param name="index"/>
        <xsl:param name="indexName"/>
	    <a>
	      <xsl:attribute name="href">
	        <xsl:value-of select="$script"/>
	        <xsl:text>?</xsl:text>
	        <xsl:text>operation=browse</xsl:text>
	        <xsl:text>&amp;fieldidx1=</xsl:text>
	        <xsl:value-of select="$index"/>
	        <xsl:text>&amp;fieldcont1=</xsl:text>
	        <xsl:call-template name="cgiencode">
	          <xsl:with-param name="text">
	            <xsl:apply-templates select="."/>
	          </xsl:with-param>
	        </xsl:call-template>
            <xsl:text>#leftcol</xsl:text>
	      </xsl:attribute>
	      <xsl:attribute name="title">
	        <xsl:text>Browse </xsl:text>
	        <xsl:value-of select="$indexName"/>
	        <xsl:text> index for this term</xsl:text>
	      </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>ajax</xsl:text>
          </xsl:attribute>
	      <xsl:apply-templates select="."/>
	    </a>
	</xsl:template>
  
	<xsl:template name="amazonlink">
	  	<a target="_new">
	  		<xsl:attribute name="href">
	  			<xsl:value-of select="$amazon_search_url"/>
	  			<xsl:call-template name="cgiencode">
		          <xsl:with-param name="text">
		            <xsl:apply-templates select="."/>
		          </xsl:with-param>
		        </xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="title">
		        <xsl:text>Search Amazon</xsl:text>
		    </xsl:attribute>
		    <img alt="Amazon">
		    	<xsl:attribute name="src">
		    		<xsl:value-of select="$amazon_search_icon"/>
		    	</xsl:attribute>
		    </img>
	  	</a>
	</xsl:template>
	
	<xsl:template name="copaclink">
	  	<a target="_new">
	  		<xsl:attribute name="href">
	  			<xsl:value-of select="$copac_search_url"/>
                <xsl:text>&amp;ti=</xsl:text>
	  			<xsl:call-template name="cgiencode">
		          <xsl:with-param name="text">
		            <xsl:apply-templates select="emph[@altrender='a' or @altrender='title']"/>
		          </xsl:with-param>
		        </xsl:call-template>
                <xsl:if test="emph[@altrender='y']">
                    <xsl:text>&amp;date=</xsl:text>
                    <xsl:call-template name="cgiencode">
                        <xsl:with-param name="text">
                            <xsl:apply-templates select="emph[@altrender='y']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
			</xsl:attribute>
			<xsl:attribute name="title">
		        <xsl:text>Search Copac</xsl:text>
		    </xsl:attribute>
		    <img alt="Amazon">
		    	<xsl:attribute name="src">
		    		<xsl:value-of select="$copac_search_icon"/>
		    	</xsl:attribute>
		    </img>
	  	</a>
	</xsl:template>
  
	<xsl:template name="googlemapslink">
	  	<a target="_new">
	  		<xsl:attribute name="href">
	  			<xsl:value-of select="$googlemaps_search_url"/>
	  			<xsl:call-template name="cgiencode">
		          <xsl:with-param name="text">
                    <xsl:choose>
                        <xsl:when test="emph">
                            <xsl:value-of select="emph[@altrender='a' or @altrender='location']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
		            
		          </xsl:with-param>
		        </xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="title">
		        <xsl:text>Plot in Google Maps</xsl:text>
		    </xsl:attribute>
		    <img alt="Google Maps">
		    	<xsl:attribute name="src">
		    		<xsl:value-of select="$googlemaps_search_icon"/>
		    	</xsl:attribute>
		    </img>
	  	</a>
	</xsl:template>
  
	<xsl:template name="wikipedialink">
		<a target="_new">
	  		<xsl:attribute name="href">
	  			<xsl:value-of select="$wikipedia_search_url"/>
	  			<xsl:call-template name="wikipediacgiencode">
		          <xsl:with-param name="text">
		            <xsl:apply-templates select="."/>
		          </xsl:with-param>
		        </xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="title">
		        <xsl:text>Search Wikipedia</xsl:text>
		    </xsl:attribute>
		    <img alt="Wikipedia">
		    	<xsl:attribute name="src">
		    		<xsl:value-of select="$wikipedia_search_icon"/>
		    	</xsl:attribute>
		    </img>
	  	</a>
	</xsl:template>
  
  	<xsl:template match="eadid" mode="tocFileName">
		<xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:param name="text">
			<xsl:value-of select="."/>
		</xsl:param>
		<xsl:value-of select="translate(translate(translate(translate($text, '/', '-'), ' ', ''), '\n', ''), $uc, $lc)"/>
	</xsl:template>
    
    <xsl:template name="normalizeEadid">
        <xsl:param name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
        <xsl:param name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:param name="text"/>
        <xsl:value-of select="translate(translate(translate(translate($text, '/', '-'), ' ', ''), '\n', ''), $uc, $lc)"/>
    </xsl:template>
    
</xsl:stylesheet>
