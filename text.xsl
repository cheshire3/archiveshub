<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>

<!-- 
	This file was produced for the Archives Hub v3.
	Copyright &#169; 2005-2008 the University of Liverpool
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">  
  
	<!-- import configuration from external file - over-rideable locally (i.e. in this file) -->
	<xsl:import href="./configuration.xsl"/>

	<xsl:output method="text"/>
	  	
  	<xsl:variable name="newline">
    	<xsl:text>
</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="tab"><xsl:text>    </xsl:text></xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:param name="script" select="'/data/'"/>

  <!-- Strip internal -->
  <xsl:template match='//*[@audience="internal"]' priority="100"/>

  <xsl:template match="/ead">
    <!-- Core information about described material from <did> -->
    <xsl:apply-templates select="/ead/archdesc/did"/>

    <xsl:value-of select="$newline"/>

    <!-- finding aid metadata from <eadheader> - creator, revisions etc -->
    <xsl:if test="$finding_aid_metadata">
      <xsl:apply-templates select="/ead/eadheader"/>
    </xsl:if>

    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$newline"/>

    <!--TEMPLATES FOR MAIN BODY-->

    <xsl:apply-templates select="/ead/archdesc/did/abstract"/>
    <xsl:apply-templates select="/ead/archdesc/bioghist"/>
    <xsl:apply-templates select="/ead/archdesc/scopecontent"/>
    <xsl:apply-templates select="/ead/archdesc/arrangement"/>
       
    <xsl:if test="/ead/archdesc/admininfo">
       <xsl:apply-templates select="/ead/archdesc/admininfo/head"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/acqinfo"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/accruals"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/processinfo"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/accessrestrict"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/userestrict"/>
       <xsl:apply-templates select="/ead/archdesc/admininfo/altformavail"/>
    </xsl:if>

    <xsl:if test="/ead/archdesc/add">
       <xsl:apply-templates select="/ead/archdesc/add"/>
    </xsl:if>

    <xsl:if test= "/ead/archdesc/descgrp">
      <xsl:apply-templates select="/ead/archdesc/descgrp/head"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/accessrestrict"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/accruals"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/acqinfo"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/address"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/altformavail"/>  
      <xsl:apply-templates select="/ead/archdesc/descgrp/appraisal"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/blockquote"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/custodhist"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/note"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/prefercite"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/processinfo"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/userestrict"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/bibliography"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/fileplan"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/index"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/otherfindaid"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/relatedmaterial"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/originalsloc"/>
      <xsl:apply-templates select="/ead/archdesc/descgrp/separatedmaterial"/>
    </xsl:if>     
    
    <xsl:apply-templates select="/ead/archdesc/acqinfo"/>
    <xsl:apply-templates select="/ead/archdesc/accruals"/>
    <xsl:apply-templates select="/ead/archdesc/processinfo"/>
    <xsl:apply-templates select="/ead/archdesc/accessrestrict"/>
    <xsl:apply-templates select="/ead/archdesc/userestrict"/>
    <xsl:apply-templates select="/ead/archdesc/appraisal"/>
    <xsl:apply-templates select="/ead/archdesc/custodhist"/>
    <xsl:apply-templates select="/ead/archdesc/altformavail"/>
    <xsl:apply-templates select="/ead/archdesc/otherfindaid"/>
    <xsl:apply-templates select="/ead/archdesc/relatedmaterial"/>
    <xsl:apply-templates select="/ead/archdesc/originalsloc"/>
    <xsl:apply-templates select="/ead/archdesc/separatedmaterial"/>
    <xsl:apply-templates select="/ead/archdesc/bibliography"/>
    <xsl:apply-templates select="/ead/archdesc/odd"/>
    <xsl:apply-templates select="/ead/archdesc/controlaccess"/> 

    <xsl:apply-templates select="/ead/archdesc/dsc"/>

  </xsl:template>


  <!-- for component records -->
  <xsl:template match="/c3component">
    <!-- Core information about described material from <did> -->
    <xsl:apply-templates select="./*/did[1]"/>

    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$newline"/>

    <!-- TEMPLATES FOR MAIN BODY -->
    <xsl:apply-templates select="./*/did[1]/abstract"/>
    <xsl:apply-templates select="./*/bioghist"/>
    <xsl:apply-templates select="./*/scopecontent"/>
    <xsl:apply-templates select="./*/arrangement"/>
       
    <xsl:apply-templates select="./*/acqinfo"/>
    <xsl:apply-templates select="./*/accruals"/>
    <xsl:apply-templates select="./*/processinfo"/>
    <xsl:apply-templates select="./*/accessrestrict"/>
    <xsl:apply-templates select="./*/userestrict"/>
    <xsl:apply-templates select="./*/appraisal"/>
    <xsl:apply-templates select="./*/custodhist"/>
    <xsl:apply-templates select="./*/altformavail"/>
    <xsl:apply-templates select="./*/otherfindaid"/>
    <xsl:apply-templates select="./*/relatedmaterial"/>
    <xsl:apply-templates select="./*/originalsloc"/>
    <xsl:apply-templates select="./*/separatedmaterial"/>
    <xsl:apply-templates select="./*/bibliography"/>
    <xsl:apply-templates select="./*/odd"/>
    <xsl:apply-templates select="./*/controlaccess"/> 

    <xsl:value-of select="$newline"/>

		<!-- somehow match all sub-levels -->
    <xsl:apply-templates select="./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12"/>
    
  </xsl:template>


  <!-- did section -->
  <xsl:template match="did">
    <xsl:text>--- </xsl:text>
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
    <xsl:text> ---</xsl:text>

    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$newline"/>

    <xsl:text>Reference Number: </xsl:text>
      <xsl:choose>
        <xsl:when test="unitid">
          <xsl:apply-templates select="unitid[1]"/>
        </xsl:when>
        <xsl:when test="unitid/@id">
          <xsl:apply-templates select="unitid/@id[1]"/>
        </xsl:when>
        <xsl:when test="@id">
          <xsl:apply-templates select="@id[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>(none)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:value-of select="$newline"/>

      <xsl:text>Dates of Creation: </xsl:text>
      <xsl:choose>
        <xsl:when test="unitdate">
          <xsl:apply-templates select="unitdate"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>(undated)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:value-of select="$newline"/>
    
      <xsl:if test="repository">
        <xsl:text>Held At: </xsl:text>
        <xsl:apply-templates select="repository[1]"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>

      <xsl:if test="physdesc">
        <xsl:text>Physical Extent: </xsl:text>
        <xsl:apply-templates select="physdesc"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>
      
      <xsl:if test="origination">
        <xsl:text>Name of Creator: </xsl:text>
        <xsl:apply-templates select="origination[1]"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>

      <xsl:if test="langmaterial">
        <xsl:text>Language of Material: </xsl:text>
        <xsl:apply-templates select="langmaterial[1]"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>
    
      <xsl:if test="processinfo">
        <xsl:apply-templates select="processinfo"/>
        <xsl:value-of select="$newline"/>
      </xsl:if>

  </xsl:template>


  <!-- eadheader section -->
  <xsl:template match="eadheader">
 	 	<xsl:apply-templates select="filedesc"/>
  	<xsl:apply-templates select="profiledesc"/>
  	<xsl:apply-templates select="revisiondesc"/>		
  </xsl:template>
  
  <xsl:template match="filedesc">
  	<xsl:if test="publicationstmt">
  		<xsl:text>Publication: </xsl:text>
  		<xsl:apply-templates select="publicationstmt"/>
			<xsl:value-of select="$newline"/>
 		</xsl:if>
  	<xsl:if test="editionstmt">
  		<xsl:text>Edition: </xsl:text>
	  	<xsl:apply-templates select="editionstmt"/>
			<xsl:value-of select="$newline"/>
	  </xsl:if>
  	<xsl:if test="seriesstmt">
  		<xsl:text>Series: </xsl:text>
	  	<xsl:apply-templates select="seriesstmt"/>
			<xsl:value-of select="$newline"/>
	  </xsl:if>
	  <xsl:if test="notesstmt">
  		<xsl:text>Notes: </xsl:text>
	  	<xsl:apply-templates select="notesstmt"/>
	  	<xsl:value-of select="$newline"/>
	  </xsl:if>
  	<!-- ignore titlestmt, most of this is already covered elsewhere -->
  </xsl:template>

  <xsl:template match="profiledesc">
    <xsl:if test="descrules/text()">
      <xsl:text>Creation: </xsl:text>
      <xsl:apply-templates select="./descrules"/>
			<xsl:value-of select="$newline"/>
    </xsl:if>
	</xsl:template>
	
  <xsl:template match="revisiondesc">      
    <xsl:if test="./text()">
      <xsl:text>Revisions: </xsl:text>
      <xsl:apply-templates/>
			<xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>


  <!--PARAGRAPHS AND FORMATTING-->
  <xsl:template match="//p">
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="//head">
    <xsl:value-of select="$newline"/>
    <xsl:text>-    </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>    -</xsl:text>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="//title">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>


  <!--CHRON LISTS-->
  <xsl:template match="chronlist">
    <xsl:for-each select="chronitem">
      <xsl:value-of select ="."/>
      <xsl:value-of select="$newline"/>
    </xsl:for-each>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <!-- CHANGES e.g. in revisiondesc -->
  <xsl:template match="change">
    <xsl:apply-templates select="date"/>
    <xsl:value-of select="$newline"/>
    <xsl:for-each select="item">
      <xsl:text>-</xsl:text><xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>


  <!--LISTS-->
  <xsl:template match="list">
    <xsl:choose>
      <xsl:when test="@type='ordered'">
        <xsl:for-each select="item">
          <xsl:value-of select="position()"/>
          <xsl:text>. </xsl:text>
          <xsl:apply-templates/>
          <xsl:value-of select="$newline"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="@type='unordered'">
        <xsl:for-each select="item">
          <xsl:apply-templates/>
          <xsl:value-of select="$newline"/>
        </xsl:for-each>        
      </xsl:when>
      <xsl:when test="@type='marked'">
        <xsl:for-each select="item">
					<xsl:text>* </xsl:text>
          <xsl:apply-templates/>
          <xsl:value-of select="$newline"/>
        </xsl:for-each>       
      </xsl:when>
      <xsl:when test="@type='simple'">
        <xsl:for-each select="item">
          <xsl:apply-templates/>
          <xsl:value-of select="$newline"/>
        </xsl:for-each>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="item">
          <xsl:apply-templates/>
          <xsl:value-of select="$newline"/>
        </xsl:for-each>
      </xsl:otherwise> 
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="//defitem">
    <xsl:apply-templates/>
    <xsl:text>; </xsl:text>
  </xsl:template>
 

	<!--DSC SECTION-->
 
	<xsl:template name="all-component" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
	  <xsl:value-of select="$newline"/>
  	<xsl:text>--------------------</xsl:text>
  	<xsl:value-of select="$newline"/>
  	<xsl:text>--   </xsl:text>
  	<xsl:if test="did/unitid">
  	  <xsl:apply-templates select ="did/unitid"/>    
  	  <xsl:text>  -  </xsl:text>
  	</xsl:if>
  	<xsl:apply-templates select ="did/unittitle"/>
  	<xsl:if test = "did/unitdate/text()">
  	  <xsl:text> (</xsl:text>
  	  <xsl:value-of select="did/unitdate"/>
  	  <xsl:text>)</xsl:text>
  	</xsl:if>
  	<xsl:if test = "did/origination">
  	  <xsl:text>, </xsl:text>
  	  <xsl:apply-templates select ="did/origination"/>
  	</xsl:if>
  	<xsl:text>   --</xsl:text>  
  	<xsl:value-of select="$newline"/>
  	<xsl:if test = "did/physloc">
  	  <xsl:value-of select = "did/physloc"/>
  	</xsl:if>
  	<xsl:apply-templates select ="did/physdesc"/>
  	<xsl:apply-templates select ="did/note"/>
  	<xsl:apply-templates select ="bioghist"/>
  	<xsl:apply-templates select ="scopecontent"/>
  	<xsl:apply-templates select ="arrangement"/>
  	<xsl:if test="admininfo">
  		<xsl:apply-templates select ="admininfo/head"/>
    	<xsl:apply-templates select ="admininfo/acqinfo"/>
    	<xsl:apply-templates select ="admininfo/accruals"/>
    	<xsl:apply-templates select ="admininfo/processinfo"/>
    	<xsl:apply-templates select ="admininfo/accessrestrict"/>
    	<xsl:apply-templates select ="admininfo/userestrict"/>
  	</xsl:if>
  	<xsl:apply-templates select ="acqinfo"/>
  	<xsl:apply-templates select ="accruals"/>
  	<xsl:apply-templates select ="processinfo"/>
  	<xsl:apply-templates select ="accessrestrict"/>
  	<xsl:apply-templates select ="userestrict"/>
  	<xsl:apply-templates select ="appraisal"/>
  	<xsl:apply-templates select ="custodhist"/>
  	<xsl:apply-templates select ="altformavail"/>
  	<xsl:apply-templates select ="otherfindaid"/>
  	<xsl:apply-templates select ="relatedmaterial"/>
  	<xsl:apply-templates select ="originalsloc"/>
  	<xsl:apply-templates select ="separatedmaterial"/>
  	<xsl:apply-templates select ="bibliography"/>
  	<xsl:apply-templates select ="odd"/>
  	
		<xsl:apply-templates select="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"/>

	</xsl:template>


	<xsl:template match="bioghist">
	  <xsl:if test="not(head)">
      <xsl:text>-    Biographical History     -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>


  <xsl:template match="scopecontent"> 
    <xsl:if test="not(head)">
      <xsl:text>-    Scope and Content    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template match="arrangement">
    <xsl:if test="not(head)">
      <xsl:text>-    Arrangement    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>


  <xsl:template match="acqinfo">
    <xsl:if test="not(head)">
      <xsl:text>-    Acquisition Information    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
	<xsl:template match="bibliography">
	  <xsl:apply-templates select="head"/>
  	<xsl:for-each select="bibref">  
    	<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
  	</xsl:for-each>
	  <xsl:for-each select="p/bibref">  
  	  <xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
  	</xsl:for-each>
	</xsl:template>

	<xsl:template match="accessrestrict">
	  <xsl:if test="not(head)">
  		<xsl:text>-    Conditions Governing Access    -</xsl:text>
  		<xsl:value-of select="$newline"/>
  	</xsl:if>
  	<xsl:apply-templates/>
  	<xsl:value-of select="$newline"/>
	</xsl:template>

  <xsl:template match="custodhist">
    <xsl:if test="not(head)">
      <xsl:text>-    Custodial History</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="appraisal">
    <xsl:if test="not(head)">
      <xsl:text>-    Appraisal Information    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="accruals">
    <xsl:if test="not(head)">
      <xsl:text>-    Accruals    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="processinfo">
    <xsl:if test="not(head)">
      <xsl:text>-    Archivist's Note    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template match="accessrestrict">
    <xsl:if test="not(head)">
      <xsl:text>-    Conditions Governing Access    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="admininfo">
    <xsl:if test="not(head)">
      <xsl:text>-    Administrative Information    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
  </xsl:template>


  <xsl:template match="userestrict">
    <xsl:if test="not(head)">
      <xsl:text>-    Conditions Governing Use    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="otherfindaid">
    <xsl:if test="not(head)">
      <xsl:text>-    Other Finding Aid    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="relatedmaterial">
    <xsl:if test="not(head)">
      <xsl:text>-    Related Material    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template match="separatedmaterial">
    <xsl:if test="not(head)">
      <xsl:text>-    Separated Material    -</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
	</xsl:template>
  
  <xsl:template match="originalsloc">
    <xsl:if test="not(head)">
      <xsl:text>-    Location of Originals</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <!--  controlaccess -->
	<xsl:template match="//controlaccess">
		<xsl:text>-   </xsl:text>
		<xsl:choose>
			<xsl:when test="head">
				<xsl:value-of select="head"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Access Points</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>   -</xsl:text>
		<xsl:value-of select="$newline"/>
 
  	<!-- Subjects -->
  	<xsl:if test="subject">
<!--		  <xsl:text>Subjects</xsl:text>-->
<!--			<xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="subject">
	   	    <xsl:value-of select="$tab"/>
	      	<xsl:text>- </xsl:text>
	      	<xsl:apply-templates select="."/>
	      	<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<!-- Personal Names -->
	<xsl:if test="persname">
<!--    <xsl:text>Personal Names</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="persname">
    		<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<!-- Family Names -->
	<xsl:if test="famname">
<!--    <xsl:text>Family Names</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="famname">
			<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
	    </xsl:for-each>
	</xsl:if>

	<!-- Corporate Names -->
	<xsl:if test="corpname">
<!--    <xsl:text>Corporate Names</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="corpname">
    		<xsl:value-of select="$tab"/>
      		<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<!-- Geographical Names -->
	<xsl:if test="geogname">
<!--    <xsl:text>Geographical Names</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="geogname">
    		<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<xsl:if test="title">
<!--    <xsl:text>Titles</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="title">
    		<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<xsl:if test="function">
<!--    <xsl:text>Functions</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="function">
    		<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if> 

	<xsl:if test="genreform">
<!--    <xsl:text>Genre/Form</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
		<xsl:for-each select="genreform">
			<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if>

	<xsl:if test="occupation">
<!--    <xsl:text>Occupation</xsl:text>-->
<!--    <xsl:value-of select="$newline"/>-->
    	<xsl:for-each select="occupation">
    		<xsl:value-of select="$tab"/>
			<xsl:apply-templates select="."/>
			<xsl:value-of select="$newline"/>
    	</xsl:for-each>
	</xsl:if> 
  
  </xsl:template>

    <!-- ARCHREF  -->
    <xsl:template match="archref">
        <xsl:copy>
            <xsl:copy-of select="@title"/>
            <xsl:copy-of select="@target"/>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@role = 'http://www.archiveshub.ac.uk/apps/linkroles/related' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/extended' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/child' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/parent' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/descendant' or
                                    @role = 'http://www.archiveshub.ac.uk/apps/linkroles/ancestor'">
                        <xsl:value-of select="$script"/>
                        <xsl:value-of select="@href"/>
                        <xsl:text>.txt</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- inner XML -->
            <xsl:apply-templates />
        </xsl:copy>
        
    </xsl:template>

  <xsl:template match="extref[@href]">
	<xsl:apply-templates/>
	<xsl:text> &lt;</xsl:text>
	<xsl:value-of select="./@href"/>
	<xsl:text>&gt; </xsl:text>
  </xsl:template>
 
  <!--LINE BREAKS-->
  <xsl:template match="//lb">
	<xsl:value-of select="$newline"/>
  </xsl:template> 

<!-- 
 <xsl:template match="*">
   <xsl:text> </xsl:text>
   <xsl:apply-templates/>
 </xsl:template>
 -->
 
</xsl:stylesheet>
