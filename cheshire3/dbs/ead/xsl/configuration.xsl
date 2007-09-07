<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
    
<!-- 
	This file was produced, and released as part of Cheshire for Archives v3.x.
	Copyright &copy; 2005, 2006, 2007 the University of Liverpool
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Administrator configurable 'switches'
       for each option, you may set the 'select' attribute to:
       "true()"
       "false()"
  -->

  <xsl:variable name="finding_aid_metadata" select="true()"/>
  <xsl:variable name="horizontal_rule_between_units" select="true()"/>
  <xsl:variable name="link_to_archon" select="true()"/>
  <xsl:variable name="count_subordinates_in_summary" select="true()"/>

  <!-- end of switches -->

  <!-- other configuration parameters -->

  <xsl:param name="archon_url">
    <xsl:text>http://www.archon.nationalarchives.gov.uk/archon/searches/locresult_details.asp?LR=</xsl:text>
  </xsl:param>
  
  <!-- the following parameters should NOT be reconfigured by users-->
  <xsl:param name="script" select="'SCRIPT'"/>
  <xsl:param name="recid" select="'RECID'"/>
	<xsl:param name="toc_cache_url" select="'TOC_CACHE_URL'"/>

</xsl:stylesheet>
