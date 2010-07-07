<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &#169; 2005-2008 the University of Liverpool
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  version="1.0">
  
	<!-- import common HTML templates and ToC templates -->
	<xsl:import href="html-common.xsl"/>
	<xsl:import href="contents.xsl"/>
  
	<!--	<xsl:output method="xml" omit-xml-declaration="yes"/>-->
<!--	<xsl:preserve-space elements="*"/>-->
        <xsl:output method="html"/>

    <xsl:template match="/">
        <div id="padder">
		    <div id="rightcol" class="ead">
		      <xsl:apply-templates/>
		    </div>
			</div>
			<div id="leftcol" class="toc">
				<xsl:comment>
				    <xsl:text>#config errmsg="[ Table of Contents unavailable ]"</xsl:text>
				</xsl:comment>
                <xsl:comment>
					<xsl:text>#include virtual="</xsl:text>
					<xsl:value-of select="$toc_cache_url"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$recid"/>
					<xsl:text>.inc"</xsl:text>
                </xsl:comment>
                <br/>
            </div>
			<xsl:if test="/ead/archdesc/dsc">
			   <exsl:document
			   	href="file:///home/cheshire/install/htdocs/ead/tocs/foo.bar"
			method="xml"
			     	omit-xml-declaration="yes"
			     	indent="yes">
			     <!-- content for this document should go here -->
			    <xsl:call-template name="toc"/>
			  </exsl:document>
			</xsl:if>
	</xsl:template>


	<xsl:template match="/ead">
            <div id="record-head">
            	<!-- Core information about described material from <did> -->
            	<xsl:apply-templates select="./archdesc/did"/>
            	<!-- finding aid metadata from <eadheader> - creator, revisions etc -->
            	<xsl:if test="$finding_aid_metadata">
            	  <xsl:apply-templates select="./eadheader"/>
            	</xsl:if>
            </div>
            <div class="archdesc">
            	<xsl:apply-templates select="./archdesc" />
            </div>
            <!-- DSC -->
            <div class="dsc">
            	<xsl:apply-templates select="./archdesc/dsc"/>
            </div>
	</xsl:template>


        <!-- for component records -->
	<xsl:template match="/c3component">
		<!-- link to collection level -->
		<xsl:text>LINKTOPARENT</xsl:text>
		<div id="record-head">
		    <!-- Core information about described material from <did> -->
		    <xsl:apply-templates select="./*/did[1]"/>
		</div>
		<!-- TEMPLATES FOR MAIN BODY -->
		<div class="archdesc">
			<xsl:apply-templates select="./*/did[1]/abstract"/>
			<xsl:apply-templates select="./*/scopecontent|./*/descgrp/scopecontent"/>
			<xsl:apply-templates select="./*/bioghist|./*/descgrp/bioghist"/>
			<xsl:apply-templates select="./*/arrangement|./*/descgrp/arrangement"/>
			<!-- ACCESS + USE RESTRICTIONS -->
			<xsl:apply-templates select="./*/accessrestrict|./*/descgrp/accessrestrict"/>
			<xsl:apply-templates select="./*/userestrict|./*/descgrp/userestrict"/>
            <xsl:apply-templates select="./*/phystech|./*/descgrp/phystech"/>
			<!-- ADMINISTRATIVE INFORMATION / ARCHIVAL HISTORY-->
			<xsl:apply-templates select="./*/appraisal|./*/descgrp/appraisal"/>
			<xsl:apply-templates select="./*/acqinfo|./*/descgrp/acqinfo"/>
			<xsl:apply-templates select="./*/custodhist|./*/descgrp/custodhist"/>
			<xsl:apply-templates select="./*/accruals|./*/descgrp/accruals"/>
			<xsl:apply-templates select="./*/processinfo|./*/descgrp/processinfo"/>
			<!-- USER INFO -->
			<xsl:apply-templates select="./*/otherfindaid|./*/descgrp/otherfindaid"/>
			<xsl:apply-templates select="./*/originalsloc|./*/descgrp/originalsloc"/>
			<xsl:apply-templates select="./*/altformavail|./*/descgrp/altformavail"/>
			<xsl:apply-templates select="./*/relatedmaterial|./*/descgrp/relatedmaterial"/>
			<xsl:apply-templates select="./*/separatedmaterial|./*/descgrp/separatedmaterial"/>
			<!--  BIBLIOGRAPHY / CITATIONS -->
			<xsl:apply-templates select="./*/bibliography|./*/descgrp/bibliography"/>
			<xsl:apply-templates select="./*/prefercite|./*/descgrp/prefercite"/>
			<!-- MISCELLANEOUS -->
			<xsl:apply-templates select="./*/odd|./*/descgrp/odd"/>
			<xsl:apply-templates select="./*/note|./*/descgrp/note"/>
			
			<!-- CONTROLACCESS -->
			<xsl:apply-templates select="./*/controlaccess|./*/descgrp/controlaccess"/> 
		</div>
		<div class="dsc">
		    <!-- match all sub-levels -->
		    <xsl:apply-templates select="./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12"/>
		</div>
	</xsl:template>


	<!-- SUBORDINATE COMPONENTS (DSC)-->
	<xsl:template name="all-component" match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
		<xsl:if test="not(@audience and @audience = 'internal')">
			<xsl:if test="$horizontal_rule_between_units">
				<hr/>    
			</xsl:if>
			<div class="component">
				<xsl:call-template name="single-component" />
			</div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>


