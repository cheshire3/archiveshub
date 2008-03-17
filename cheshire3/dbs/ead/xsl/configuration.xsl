<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &#169; 2005-2008 the University of Liverpool
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Administrator configurable 'switches'
       for each option, you may set the 'select' attribute to:
       "true()"
       "false()"
  -->

  <xsl:variable name="link_to_archon" select="true()"/>
  <xsl:variable name="finding_aid_metadata" select="true()"/>
  <xsl:variable name="count_subordinates_in_summary" select="true()"/>
  <xsl:variable name="horizontal_rule_between_units" select="true()"/>
  <!-- external resource link switches -->
  <xsl:variable name="link_to_amazon" select="true()" />
  <xsl:variable name="link_to_copac" select="true()"/>
  <xsl:variable name="link_to_googlemaps" select="true()"/>
  <xsl:variable name="link_to_wikipedia" select="false()"/>
  

  <!-- end of switches -->

  <!-- other configuration parameters -->

  <xsl:param name="archon_url">
    <xsl:text>http://www.archon.nationalarchives.gov.uk/archon/searches/locresult_details.asp?LR=</xsl:text>
  </xsl:param>
  
  <!-- Amazon -->
  <xsl:param name="amazon_base_url">
  	<xsl:text>http://www.amazon.co.uk</xsl:text>
  </xsl:param>
  <xsl:param name="amazon_search_url">
  	<xsl:value-of select="$amazon_base_url"/>
  	<xsl:text>/s/?initialSearch=1&amp;url=search-alias%3Daps&amp;field-keywords=</xsl:text>
  </xsl:param>
  <xsl:param name="amazon_search_icon">
  	<xsl:value-of select="$amazon_base_url"/>
  	<xsl:text>/favicon.ico</xsl:text>
  </xsl:param>
  
  <!-- Copac -->
  <xsl:param name="copac_base_url">
  	<xsl:text>http://www.copac.ac.uk</xsl:text>
  </xsl:param>
  <xsl:param name="copac_search_url">
  	<xsl:value-of select="$copac_base_url"/>
  	<xsl:text>/wzgw?form=qs&amp;fs=Search&amp;ti=</xsl:text>
  </xsl:param>
  <xsl:param name="copac_search_icon">
  	<xsl:value-of select="$copac_base_url"/>
  	<xsl:text>/favicon.ico</xsl:text>
  </xsl:param>
  
  <!-- Google -->
  <xsl:param name="googlemaps_base_url">
  	<xsl:text>http://maps.google.co.uk</xsl:text>
  </xsl:param>
  <xsl:param name="googlemaps_search_url">
  	<xsl:value-of select="$googlemaps_base_url"/>
  	<xsl:text>/maps?ie=UTF8&amp;hl=en&amp;q=</xsl:text>
  </xsl:param>
  <xsl:param name="googlemaps_search_icon">
  	<xsl:value-of select="$googlemaps_base_url"/>
  	<xsl:text>/favicon.ico</xsl:text>
  </xsl:param>
  
  <!-- Wikipedia -->
  <xsl:param name="wikipedia_base_url">
  	<xsl:text>http://en.wikipedia.org</xsl:text>
  </xsl:param>
  <xsl:param name="wikipedia_search_url">
  	<xsl:value-of select="$wikipedia_base_url"/>
  	<xsl:text>/wiki/Special:Search/</xsl:text>
  </xsl:param>
  <xsl:param name="wikipedia_search_icon">
  	<xsl:value-of select="$wikipedia_base_url"/>
  	<xsl:text>/favicon.ico</xsl:text>
  </xsl:param>
  
  <!-- the following parameters should NOT be reconfigured by users-->
  <xsl:param name="script" select="'SCRIPT'"/>
  <xsl:param name="recid" select="'RECID'"/>
  <xsl:param name="toc_cache_url" select="'TOC_CACHE_URL'"/>

</xsl:stylesheet>
