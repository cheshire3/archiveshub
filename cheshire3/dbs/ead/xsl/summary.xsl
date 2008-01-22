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
    
    <!-- import common HTML templates -->
    <xsl:import href="html-common.xsl"/>
    
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:preserve-space elements="*"/>
    
    <!-- Strip all subordinate levels of description -->
    <xsl:template match="dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" priority="99"/>
    
    <xsl:template match="/">
    	<xsl:apply-templates/>
    	<br/>
    </xsl:template>

    <!-- for complete EAD instances -->
    <xsl:template match="/ead">
        <div id="full-link">
            <xsl:text>See the </xsl:text>
            <xsl:call-template name="full-record-link"/>
        </div>
        <div id="record-head">
            <!-- Core information about described material from <did> -->
            <xsl:apply-templates select="./archdesc/did"/>
            <!-- finding aid metadata from <eadheader> - creator, revisions etc -->
            <xsl:if test="$finding_aid_metadata">
              <xsl:apply-templates select="./eadheader"/>
            </xsl:if>
        </div>
        <div class="archdesc">
            <!-- TEMPLATES FOR MAIN BODY -->
            	    <xsl:apply-templates select="./archdesc/scopecontent"/>
            	    <xsl:apply-templates select="./archdesc/bioghist"/>
            <!--	    <xsl:apply-templates select="./archdesc/*/acqinfo"/>-->
            	    <xsl:apply-templates select="./archdesc/*/accessrestrict"/>
            <!--	    <xsl:apply-templates select="./archdesc/*/otherfindaid"/>-->
            <!--	    <xsl:apply-templates select="./archdesc/*/relatedmaterial"/>-->
            <xsl:apply-templates select="./archdesc/controlaccess"/>
        </div>
        <xsl:if test="$count_subordinates_in_summary">
            <xsl:variable name="sub_count" select="count(./archdesc/dsc/c|./archdesc/dsc/c01)"/>
            <xsl:variable name="all_count" select="count(//c|//c01|//c02|//c03|//c04|//c05|//c06|//c07|//c08|//c09|//c10|//c11|//c12)"/>	
            <div class="dsc">
	       <xsl:if test="$sub_count &gt; 0">
                    <xsl:call-template name="count-subcomponents">
                        <xsl:with-param name="sub_count">
                            <xsl:value-of select="$sub_count"/>
                        </xsl:with-param>
                        <xsl:with-param name="all_count">
                            <xsl:value-of select="$all_count"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- for component records -->
    <xsl:template match="/c3component">
    	<!-- links to higher levels -->
    	<xsl:text>LINKTOPARENT</xsl:text>
    	<div id="full-link">
            <xsl:text>See the </xsl:text>
            <xsl:call-template name="full-record-link"/>
	</div>
	<div id="record-head">
		<!-- Core information about described material from <did> -->
		<xsl:apply-templates select="./*/did[1]"/>
	</div>
	<br/>
        <!-- TEMPLATES FOR MAIN BODY -->
        <xsl:apply-templates select="./*/scopecontent"/>
        <xsl:apply-templates select="./*/bioghist"/>
        <xsl:apply-templates select="./*/acqinfo"/>
        <xsl:apply-templates select="./*/accessrestrict"/>
        <xsl:apply-templates select="./*/userestrict"/>
        <xsl:apply-templates select="./*/otherfindaid"/>
        <xsl:apply-templates select="./*/relatedmaterial"/>
        <xsl:apply-templates select="./*/controlaccess"/>
	
        <xsl:if test="$count_subordinates_in_summary">
            <xsl:variable name="sub_count" select="count(./c/c|./c01/c02|./c02/c03|./c03/c04|./c04/c05|./c05/c06|./c06/c07|./c07/c08|./c08/c09|./c09/c10|./c10/c11|./c11/c12)"/>
            <xsl:variable name="all_count" select="count(.//c|.//c01|.//c02|.//c03|.//c04|.//c05|.//c06|.//c07|.//c08|.//c09|.//c10|.//c11|.//c12)"/>	
            <div class="dsc">
	       <xsl:if test="$sub_count &gt; 0">
                    <xsl:call-template name="count-subcomponents">
                        <xsl:with-param name="sub_count">
                            <xsl:value-of select="$sub_count"/>
                        </xsl:with-param>
                        <xsl:with-param name="all_count">
                            <xsl:value-of select="$all_count"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template name="count-subcomponents">
        <xsl:param name="sub_count"/>
        <xsl:param name="all_count"/>
        <h3 class="redheading">Additional Information About Your Chosen Collection</h3>
        <p>
            <xsl:text>This record has </xsl:text>
            <xsl:value-of select="$sub_count"/>
            <xsl:choose>
                <xsl:when test="$sub_count &gt; 1">
                    <xsl:text> further sections</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> further section</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>, containing a total of </xsl:text>
            <xsl:value-of select="$all_count"/>
            <xsl:text> described items.</xsl:text>
        </p>
        <p>
            <xsl:text>See the </xsl:text>
            <xsl:call-template name="full-record-link"/>
            <xsl:choose>
                <xsl:when test="$sub_count &gt; 1">
                    <xsl:text> to view them.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> to view it.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </p>
        <!--
        <p>
            <xsl:element name="a">
                <xsl:attribute name="href">
                      <xsl:text>SCRIPT?operation=search&amp;withinCollection=RECID&amp;cqlquery=QSTRING</xsl:text>
                      <xsl:value-of select="./@target"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_top</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:text>Repeat your search within this collection only.</xsl:text>
                </xsl:attribute>
                <xsl:text>Search within this collection</xsl:text>
            </xsl:element>
        </p>
        -->
    </xsl:template>
    
    
    <!--BUILDING REFS AND ANCS-->
    <xsl:template name="full-record-link">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:text>SCRIPT?operation=full&amp;RSID</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Go to full record.</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="onclick">
                <xsl:text>SPLASH</xsl:text>
            </xsl:attribute>
            <img src="/images/v3_full.gif" alt="'Full text'"/>
        </xsl:element>
    </xsl:template>
    
    
    <!--  we can't assume that this will work in Summary view so overwrite it here -->
    <xsl:template match="ref[@target]">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:text>SCRIPT/?operation=full&amp;recid=PARENTID#</xsl:text>
                <xsl:value-of select="./@target"/>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:text>_top</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
	       <xsl:text>Go to referenced section in the full-text version [some sections unavailable in 'Summary' view.]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="onclick">
                <xsl:text>SPLASH</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
