<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    version="1.0">
  
    <xsl:import href="contents-editing.xsl"/>
  
 <!--   <xsl:output method="html" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>     -->
  <xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8"/>
	 <xsl:preserve-space elements="*"/>


  <xsl:variable name="eadidstring">
  	<xsl:value-of select="/ead/eadheader/eadid/text()"/>
  </xsl:variable>
  
  <xsl:variable name="leveltype">
  	<xsl:choose>
  		<xsl:when test="/ead/eadheader">
  			<xsl:text>collection</xsl:text>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:text>component</xsl:text>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="level">
  	<xsl:choose>
  		<xsl:when test="/*/@level">
  			<xsl:value-of select="/*/@level"/>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:text></xsl:text>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:variable>
    
  <xsl:template match="/">
  <div id="formDiv" name="form" class="formDiv" onscroll="hideAllMenus()">
    <form id="eadForm" name="eadForm"  action="#" >
    <div class="float"> <input type="button" class="formbutton" id="addC" onclick="javascript: addComponent()" value="Add Component"></input></div>
    <div class="float"> <input type="button" class="formbutton" id="reset" onclick="javascript: resetForm()" value="Reset"></input> </div>
    
    	<div class="pui">
    		<strong><xsl:text>Persistent Unique Identifier: </xsl:text></strong>				
    		%PUI%
    	</div>
    
    <br/>
      <div class="section">
    	<xsl:choose>
    		<xsl:when test="/ead/eadheader">	
    			<h3>Collection Level Description</h3>
    			%RECID%   			
    			<xsl:apply-templates select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc"/>
    		</xsl:when>
    		<xsl:otherwise>
    			<h3>Component Level Description</h3>
    			<xsl:apply-templates select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc"/>
    		</xsl:otherwise>
    	</xsl:choose>	
     </div> 	  
	</form>
  </div>
  </xsl:template>
    
  
  <xsl:template match="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc">
  <xsl:if test="not(name() = 'archdesc')">
  	<p>
    	<!--<strong>Component Label: </strong>-->
   		<input type="hidden" name="ctype" id="ctype" maxlength="3" size="4">
   			<xsl:attribute name="value">
   				<xsl:value-of select="name()"/>   					
 			</xsl:attribute>
   		</input>
    </p>
  </xsl:if>
  	<div id="sec-3-1" class="section">
      <span class="isadg"><h3>3.1: Identity Statement Area</h3></span>
      <p id="unitidparent">
	  <strong><span class="isadg">3.1.1: </span><a href="arch/refcode.shtml" title="Reference Code help - opens in new window" target="_new">Reference Code</a></strong> 
	  Comprising of <a href="http://www.iso.org/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html" target="_new" title="Further information on ISO Country Codes">ISO Country Code</a>, 
	  NCA Repository Code,
	  and a unique identifier for this record or component.
	  <xsl:if test="$leveltype = 'collection'">
	  [<strong>all fields required</strong>]
	  </xsl:if>
	  <br/>
	  <xsl:choose>
	  	<xsl:when test="did/unitid">
	  	   <xsl:apply-templates select="did/unitid"/>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<input type="text" name="did/unitid/@countrycode" id="countrycode" maxlength="2" size="3" value="GB" onblur="checkId('recordStore')"></input>
			<input type="text" onfocus="setCurrent(this);" name="did/unitid/@repositorycode" id="repositorycode" maxlength="4" size="5" onblur="checkId('recordStore')"></input>
			<input type="text" onfocus="setCurrent(this);" name="did/unitid" id="unitid" size="50" onblur="checkId('recordStore')"></input>	
	  	</xsl:otherwise>
	  </xsl:choose>  		
  	</p>
  	<p>
		<strong><span class="isadg">3.1.2: </span><a href="arch/title.shtml" title="Title help - opens in new window" target="_new">Title</a></strong><br/>
		<xsl:choose>
			<xsl:when test="did/unittitle">
				<xsl:apply-templates select="did/unittitle"/>
			</xsl:when>
			<xsl:otherwise>
				<input class="menuField" type="text" onfocus="setCurrent(this);" name="did/unittitle" id="cab" size="80" onchange="updateTitle(this)"></input>
			</xsl:otherwise>
		</xsl:choose>		
    </p>
    <div class="float">
    	<p><strong><span class="isadg">3.1.3: </span><a href="arch/dates1.shtml" title="Dates of Creation help - opens in new window" target="_new">Dates of Creation</a></strong><br/>
		<xsl:choose>
			<xsl:when test="did/unitdate">
				<xsl:apply-templates select="did/unitdate"/>
			</xsl:when>
			<xsl:otherwise>
				<input class="menuField" type="text" onfocus="setCurrent(this);" onchange="validateField(this, 'true');" name="did/unitdate" id="cac" size="39"></input>
			</xsl:otherwise>
		</xsl:choose>      
		</p>
	</div>
	<div class="float">
		<p>
		<strong><a href="arch/dates2.shtml" title="Normalised Date help - opens in new window" target="_new">Normalised Date</a></strong><br/>
	    	<xsl:choose>
	    		<xsl:when test="did/unitdate/@normal">
	    			<xsl:apply-templates select="did/unitdate/@normal"/>
	    		</xsl:when>
	    		<xsl:otherwise>
	    			<input type="text" onfocus="setCurrent(this);" name="did/unitdate/@normal" id="can" size="39" maxlength="10"></input>
	    		</xsl:otherwise>
	    	</xsl:choose>      	            
		</p>
	</div>
  	<br/>
  	<p>
  		<xsl:if test="$leveltype = 'component'">
  			<strong><span class="isadg">3.1.4: </span>Level of Description</strong><br/>
  			<select name="@level">
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="''"/>
	  				<xsl:with-param name="label" select="'none'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'fonds'"/>
	  				<xsl:with-param name="label" select="'fonds'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'class'"/>
	  				<xsl:with-param name="label" select="'class'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'series'"/>
	  				<xsl:with-param name="label" select="'series'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'subfonds'"/>
	  				<xsl:with-param name="label" select="'subfonds'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'subseries'"/>
	  				<xsl:with-param name="label" select="'subseries'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'file'"/>
	  				<xsl:with-param name="label" select="'file'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'item'"/>
	  				<xsl:with-param name="label" select="'item'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
	  			<xsl:call-template name="option">
	  				<xsl:with-param name="value" select="'otherlevel'"/>
	  				<xsl:with-param name="label" select="'otherlevel'"/>
	  				<xsl:with-param name="select" select="$level"/>
	  			</xsl:call-template>
  			</select>
		</xsl:if>
  	</p>
 	<p>
		<strong><span class="isadg">3.1.5: </span><a href="arch/extent.shtml" title="Extent help - opens in new window" target="_new">Extent of Unit of Description</a></strong><br/>
		<xsl:choose>
			<xsl:when test="did/physdesc/extent">
				<xsl:apply-templates select="did/physdesc/extent"/>
			</xsl:when>
			<xsl:otherwise>
				<input class="menuField" type="text" onfocus="setCurrent(this);" onchange="validateField(this, 'true');" name="did/physdesc/extent" id="cae" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>		
    </p>
    <xsl:if test="$leveltype = 'collection'">
	    <p>
	  		<strong><span class="isadg"></span>Repository</strong><br/>
	  		<xsl:choose>
				<xsl:when test="did/repository">
					<xsl:apply-templates select="did/repository"/>
				</xsl:when>
				<xsl:otherwise>
					<input class="menuField" type="text" onfocus="setCurrent(this);" onchange="validateField(this, 'true');" name="did/repository" id="rep" size="80"></input>
				</xsl:otherwise>
			</xsl:choose>
	  	</p>
	  	<p>  		
	  		<xsl:choose>
				<xsl:when test="filedesc/titlestmt/sponsor">				
					<xsl:apply-templates select="filedesc/titlestmt/sponsor"/>
				</xsl:when>
				<xsl:otherwise>
					<strong><span class="isadg"></span>Sponsor </strong> <a class="smalllink" id="linkspo" title="add sponsor" onclick="addElement('spo')">add</a> [optional]<br/>
					<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="filedesc/titlestmt/sponsor" id="spo" size="80" style="display:none"></input>
				</xsl:otherwise>
			</xsl:choose>
	  	</p>
  	</xsl:if>
   </div>
<!--  -->
<!-- CONTEXT -->  
<!--  --> 
   <div class="section">
		<span class="isadg"><h3>3.2: Context Area</h3></span> 
		<p>
		<strong><span class="isadg">3.2.1: </span><a href="arch/name.shtml" title="Name of Creator help - opens in new window" target="_new">Name of Creator</a></strong>  [<strong>also add manually as <a href="#accesspoints" title="Add Access Point manually">Access Point</a></strong>]<br/>
		<xsl:choose>
			<xsl:when test="did/origination">
				<xsl:apply-templates select="did/origination"/>
			</xsl:when>
			<xsl:otherwise>
				<input class="menuField" type="text" onfocus="setCurrent(this);" onchange="validateField(this, 'true');" name="did/origination" id="cba" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>		
    	</p>
<!-- bioghist -->
    <p>	  	
    	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="bioghist">
				<xsl:text>true</xsl:text>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>  
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="bioghist">
					<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('bioghist[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('cbb', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'false'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.2.2: '"/>
						<xsl:with-param name="title" select="'Administrative/Biographical History'"/>
						<xsl:with-param name="help" select="www.archiveshub.ac.uk/arch/bioghist.shtml"/>
					</xsl:call-template>
			   </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('bioghist[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cbb', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'false'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.2.2: '"/>
					<xsl:with-param name="title" select="'Administrative/Biographical History'"/>
					<xsl:with-param name="help" select="www.archiveshub.ac.uk/arch/bioghist.shtml"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	   </p>
	   
<!-- custodhist -->
	   <p>
	   <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="custodhist">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="custodhist">
					<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('custodhist[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('cbc', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'true'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.2.3: '"/>
						<xsl:with-param name="title" select="'Archival History'"/>
						<xsl:with-param name="help" select="''"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('custodhist[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cbc', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.2.3: '"/>
					<xsl:with-param name="title" select="'Archival History'"/>
					<xsl:with-param name="help" select="''"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	   </p>
<!-- acqinfo -->
	   <p>
	   <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="acqinfo">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="acqinfo">
			      	<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('acqinfo[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('cbd', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'true'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.2.4: '"/>
						<xsl:with-param name="title" select="'Immediate Source of Acquisition'"/>
						<xsl:with-param name="help" select="''"/>
					</xsl:call-template>	
				</xsl:for-each>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('acqinfo[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cbd', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.2.4: '"/>
					<xsl:with-param name="title" select="'Immediate Source of Acquisition'"/>
					<xsl:with-param name="help" select="''"/>
				</xsl:call-template>	
			</xsl:otherwise>
		</xsl:choose>
      	</p>       
    </div>	    
 <!--  -->   
 <!-- CONTENT AND STRUCTURE -->   
 <!--  -->
    <div class="section">
	<span class="isadg"><h3>3.3: Content and Structure Area</h3></span> 
<!-- scopecontent -->
	 <p>
	 <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="scopecontent">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="scopecontent">
			      	<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('scopecontent[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('cca', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'false'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.3.1: '"/>
						<xsl:with-param name="title" select="'Scope and Content'"/>
						<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/scope.shtml'"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('scopecontent[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cca', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'false'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.3.1: '"/>
					<xsl:with-param name="title" select="'Scope and Content'"/>
					<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/scope.shtml'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
      </p> 
<!-- appraisal -->     
      <p>
      <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="appraisal">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="appraisal">
			      	<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('appraisal[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('ccb', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'true'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.3.2: '"/>
						<xsl:with-param name="title" select="'Appraisal'"/>
						<xsl:with-param name="help" select="''"/>
					</xsl:call-template>	
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('appraisal[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('ccb', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.3.2: '"/>
					<xsl:with-param name="title" select="'Appraisal'"/>
					<xsl:with-param name="help" select="''"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
      </p>
<!-- accruals -->
      <p>
      <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="accruals">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="accruals">
			      	<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('accruals[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('ccc', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'true'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.3.3: '"/>
						<xsl:with-param name="title" select="'Accruals'"/>
						<xsl:with-param name="help" select="''"/>
					</xsl:call-template>
				</xsl:for-each>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('accruals[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('ccc', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.3.3: '"/>
					<xsl:with-param name="title" select="'Accruals'"/>
					<xsl:with-param name="help" select="''"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
      </p>
<!-- arrangement -->
      <p>
      <xsl:variable name="content">
			<xsl:choose>
				<xsl:when test="arrangement">
					<xsl:text>true</xsl:text>				
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>			
			</xsl:choose>
		</xsl:variable>  
		<xsl:choose>
			<xsl:when test="$content = 'true'">
				<xsl:for-each select="arrangement">
			      	<xsl:call-template name="textarea">
						<xsl:with-param name="name" select="concat('arrangement[', position(), ']')"/>
						<xsl:with-param name="id" select="concat('ccd', position())"/>
						<xsl:with-param name="class" select="'menuField'"/>
						<xsl:with-param name="optional" select="'true'"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="isadg" select="'3.3.4: '"/>
						<xsl:with-param name="title" select="'System of Arrangement'"/>
						<xsl:with-param name="help" select="''"/>
					</xsl:call-template>	
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('arrangement[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('ccd', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.3.4: '"/>
					<xsl:with-param name="title" select="'System of Arrangement'"/>
					<xsl:with-param name="help" select="''"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
      </p>
    </div>
<!--  -->
<!-- ACCESS -->
<!--  -->
    <div class="section">
	<span class="isadg"><h3>3.4: Conditions of Access and Use Area</h3></span>
<!-- accessrestrict -->  
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="accessrestrict">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="accessrestrict">
			    <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('accessrestrict[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cda', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'false'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.4.1: '"/>
					<xsl:with-param name="title" select="'Conditions Governing Access'"/>
					<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/restrict.shtml'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('accessrestrict[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cda', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'false'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.4.1: '"/>
				<xsl:with-param name="title" select="'Conditions Governing Access'"/>
				<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/restrict.shtml'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>  
<!-- userestrict --> 
 	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="userestrict">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="userestrict">
			    <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('userestrict[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cdb', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.4.2: '"/>
					<xsl:with-param name="title" select="'Conditions Governing Reproduction'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('userestrict[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cdb', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.4.2: '"/>
				<xsl:with-param name="title" select="'Conditions Governing Reproduction'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p> 
<!-- langmaterial -->
     <p>
     	<strong><span class="isadg">3.4.3: </span><a href="/arch/lang.shtml" title="Language of Material help - opens in new window" target="_new">Language of Material</a></strong> [Must include <a href="http://www.loc.gov/standards/iso639-2/englangn.html" title="ISO 639-2 codes - opens new window" target="_new">ISO 639-2 3-letter code</a>]
     	<xsl:for-each select="did/langmaterial/@*">
     		<input type="hidden">
     			<xsl:attribute name="name">
     				<xsl:text>did/langmaterial/@</xsl:text><xsl:value-of select="name()"/>
     			</xsl:attribute>
     			<xsl:attribute name="value">
     				<xsl:value-of select="."/>
     			</xsl:attribute>
     		</input>
		</xsl:for-each>    	
     	<div id="language" class="langcontainer">
     	<xsl:choose>
     		<xsl:when test="did/langmaterial/language">
     			<xsl:apply-templates select="did/langmaterial"/>
     		</xsl:when>
     		<xsl:otherwise>		     			
				<div id="addedlanguages" style="display:none" class="added"><xsl:text> </xsl:text></div>		
     		</xsl:otherwise>
     	</xsl:choose>
     		<div id="languagetable" class="tablecontainer">
  				<table>
  					<tbody>
      					<tr><td> 3-letter ISO code:</td><td> <input type="text" id="lang_code" onfocus="setCurrent(this);" maxlength="3" size="5"></input></td></tr>
						<tr><td> Language:</td><td> <input type="text" id="lang_name" onfocus="setCurrent(this);" size="30"></input></td></tr>
  					</tbody>
  				</table>
			</div>
  			<div id="languagebuttons" class="buttoncontainer">
      			<input class="apbutton" type="button" onclick="addLanguage();" value="Add to Record" ></input><br/>
  				<input class="apbutton" type="button" onclick="resetAccessPoint('language');" value="Reset" ></input>
  			</div>
    	</div>
    	<br/>		     	
     </p>
<!-- phystech -->
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="phystech">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="phystech">
			    <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('phystech[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cdd', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.4.4: '"/>
					<xsl:with-param name="title" select="'Physical Characteristics'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			 <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('phystech[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cdd', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.4.4: '"/>
					<xsl:with-param name="title" select="'Physical Characteristics'"/>
				</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>
<!-- otherfindaid -->	
	<xsl:if test="$leveltype = 'collection'">
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="otherfindaid">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="otherfindaid">
			    <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('otherfindaid[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cde', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'false'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.4.5: '"/>
					<xsl:with-param name="title" select="'Finding Aids'"/>
				</xsl:call-template>	
			</xsl:for-each>		
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('otherfindaid[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cde', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'false'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.4.5: '"/>
				<xsl:with-param name="title" select="'Finding Aids'"/>
			</xsl:call-template>	
		</xsl:otherwise>
	</xsl:choose>
	</p>	
	</xsl:if>	     					
	</div>
<!--  -->
<!-- ALLIED MATERIALS -->
<!--  -->
	<div class="section">
    <span class="isadg"><h3>3.5: Allied Materials Area</h3></span>
<!-- originalsloc -->  
    <p>
    <xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="originalsloc">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="originalsloc">
		     	<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('originalsloc[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cea', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.5.1: '"/>
					<xsl:with-param name="title" select="'Existence/Location of Originals'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('originalsloc[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cea', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.5.1: '"/>
				<xsl:with-param name="title" select="'Existence/Location of Originals'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
    </p> 
<!-- altformavail -->
	<p>
	 <xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="altformavail">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="altformavail">
			    <xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('altformavail[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('ceb', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.5.2: '"/>
					<xsl:with-param name="title" select="'Existence/Location of Copies'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('altformavail[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('ceb', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.5.2: '"/>
				<xsl:with-param name="title" select="'Existence/Location of Copies'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>
<!-- relatedmaterial -->
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="relatedmaterial">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="relatedmaterial">
		     	<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('relatedmaterial[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cec', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.5.3: '"/>
					<xsl:with-param name="title" select="'Related Units of Description'"/>
				</xsl:call-template>
			</xsl:for-each>		
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('relatedmaterial[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cec', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.5.3: '"/>
				<xsl:with-param name="title" select="'Related Units of Description'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
    </p>
<!-- bibliography -->
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="bibliography">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="bibliography">
		     	<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('bibliography[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('ced', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.5.4: '"/>
					<xsl:with-param name="title" select="'Publication Note'"/>
					<xsl:with-param name="additional" select="'[Works based on or about the collection]'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('bibliography[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('ced', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.5.4: '"/>
				<xsl:with-param name="title" select="'Publication Note'"/>
				<xsl:with-param name="additional" select="'[Works based on or about the collection]'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>
	</div>
<!--  -->
<!-- NOTE AREA -->	
<!--  -->
	<div class="section">
	<span class="isadg"><h3>3.6: Note Area</h3></span> 
<!-- note -->
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="note">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>  
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="note">
		     	<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('note[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cfa', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.6.1: '"/>
					<xsl:with-param name="title" select="'Note'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('note[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cfa', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.6.1: '"/>
					<xsl:with-param name="title" select="'Note'"/>
				</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>
	</div>
<!--  -->
<!-- DESCRIPTION AREA -->
<!--  -->
	<xsl:if test="$leveltype = 'collection'">
	<div class="section">
	<span class="isadg"><h3>3.7: Description Area</h3></span> 
<!-- processinfo -->
	<p>
	<xsl:variable name="content">
		<xsl:choose>
			<xsl:when test="processinfo">
				<xsl:text>true</xsl:text>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:variable> 
	<xsl:choose>
		<xsl:when test="$content = 'true'">
			<xsl:for-each select="processinfo"> 
		     	<xsl:call-template name="textarea">
					<xsl:with-param name="name" select="concat('processinfo[', position(), ']')"/>
					<xsl:with-param name="id" select="concat('cga', position())"/>
					<xsl:with-param name="class" select="'menuField'"/>
					<xsl:with-param name="optional" select="'true'"/>
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="isadg" select="'3.7.1: '"/>
					<xsl:with-param name="title" select='"Archivist&apos;s Note"'/>
					<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/archnote.shtml'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="textarea">
				<xsl:with-param name="name" select="concat('processinfo[', position(), ']')"/>
				<xsl:with-param name="id" select="concat('cga', position())"/>
				<xsl:with-param name="class" select="'menuField'"/>
				<xsl:with-param name="optional" select="'true'"/>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="isadg" select="'3.7.1: '"/>
				<xsl:with-param name="title" select='"Archivist&apos;s Note"'/>
				<xsl:with-param name="help" select="'www.archiveshub.ac.uk/arch/archnote.shtml'"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	</p>
	</div>
	</xsl:if>
<!--  -->
<!--  -->
<!--  -->
<!--  -->
<!--  -->
<!-- ACCESSPOINTS -->
<!--  -->
	<div id="accesspointssection" class="section">
		<h3><a id="accesspoints" name="accesspoints">Access Points</a></h3>
<!-- subject -->
		<div id="subject" class="apcontainer">
			<p><strong>Subject</strong><br /><a onclick="window.open('http://www.archiveshub.ac.uk/unesco/', 'new', 'width=800 height=600');">[Search UNESCO] </a> <a onclick="window.open('http://www.archiveshub.ac.uk/lcsh/', 'new', 'width=800 height=600');"> [Search LCSH]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/subject">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'subject'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedsubjects" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="subjecttable" class="tablecontainer">
				<table id="table_subject">
				<tbody>
			    	<tr NoDrop="true" NoDrag="true"><td class="label">Subject:</td><td><input type="text" onfocus="setCurrent(this);" id="subject_subject" size="40"></input></td></tr>
			    	<tr NoDrop="true" NoDrag="true"><td class="label">Thesaurus:</td><td><input type="text" onfocus="setCurrent(this);" id="subject_source" size="40"></input></td></tr>
			    	<tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="subjectdropdown">
			    		<option value="subject_dates">Dates</option>
			    		<option value="subject_loc">Location</option>
			    		<option value="subject_other">Other</option>
			    	</select></td>
			    	<td><input type="text" onfocus="addField('subject')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
			    </tbody>
				</table>
			</div>
			<div id="subjectbuttons" class="buttoncontainer">			     
		  	    <input class="apbutton" type="button" onclick="addAccessPoint('subject');" value="Add to Record" ></input><br/>
		  	    <input class="apbutton" type="button" onclick="resetAccessPoint('subject');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>	
<!--persname -->
        <div id="persname" class="apcontainer">				
			<p><strong>Personal Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=P', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			
			<xsl:choose>
				<xsl:when test="controlaccess/persname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'persname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedpersnames" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="persnametable" class="tablecontainer">					
				<table id="table_persname"><tbody>					
				  	<tr NoDrop="true" NoDrag="true"><td class="label"> Surname:</td><td> <input type="text" onfocus="setCurrent(this);" id="persname_surname" size="40"></input></td></tr>
				  	<tr NoDrop="true" NoDrag="true"><td class="label"> Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="persname_source" size="40"></input></td></tr>
				  	<tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="persnamedropdown">
				  		<option value="persname_forename">Forename</option>
			    		<option value="persname_dates">Dates</option>
			    		<option value="persname_title">Title</option>
			    		<option value="persname_epithet">Epithet</option>
			    		<option value="persname_other">Other</option>		    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('persname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				</tbody></table>
			</div>
			<div id="persnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules:
					<select id="persname_rules" onchange="checkRules('persname')">
						<option value="none">None</option>
						<option value="ncarules">NCA Rules</option>
						<option value="aacr2">AACR2</option>
					</select>
				</p>
				<input class="apbutton" type="button" onclick="addAccessPoint('persname');" value="Add To Record" ></input><br />
				<input class="apbutton" type="button" onclick="resetAccessPoint('persname');" value="Reset" ></input>				
			</div>
			<br/>
		</div>
		<br/>
<!--famname -->
		<div id="famname" class="apcontainer">
			<p><strong>Family Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=F', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/famname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'famname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedfamnames" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>
			<div id="famnametable" class="tablecontainer">
			      <table id="table_famname"><tbody>
					  <tr NoDrop="true" NoDrag="true"><td class="label">Surname:</td><td> <input type="text" onfocus="setCurrent(this);" id="famname_surname" size="40"></input></td></tr>
					  <tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="famname_source" size="40"></input></td></tr>
				  	  <tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="famnamedropdown">
				  	  	<option value="famname_other">Other</option>		  		
			    		<option value="famname_dates">Dates</option>
			    		<option value="famname_title">Title</option>
			    		<option value="famname_epithet">Epithet</option>
			    		<option value="famname_loc">Location</option>		    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('famname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
			      </tbody></table>
			</div>
			<div id="famnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules: 
				<select id="famname_rules" onchange="checkRules('famname')">
					<option value="none">None</option>
					<option value="ncarules">NCA Rules</option>
					<option value="aacr2">AACR2</option>
				</select>
				</p>
				<input class="apbutton" type="button" onclick="addAccessPoint('famname');" value="Add To Record"></input><br />
				<input class="apbutton" type="button" onclick="resetAccessPoint('famname');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>		
<!-- corpname -->
		<div id="corpname" class="apcontainer">
			<p><strong>Corporate Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=O', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/corpname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'corpname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedcorpnames" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="corpnametable" class="tablecontainer">
				<table id="table_corpname"><tbody>
			    	<tr NoDrop="true" NoDrag="true"><td class="label">Organisation:</td><td><input type="text" onfocus="setCurrent(this);" id="corpname_organisation" size="40"></input></td></tr>
			    	<tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td><input type="text" onfocus="setCurrent(this);" id="corpname_source" size="40"></input></td></tr>
			    	<tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="corpnamedropdown">				  	  			  		
			    		<option value="corpname_dates">Dates</option>
			    		<option value="corpname_loc">Location</option>
			    		<option value="corpname_other">Other</option>		    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('corpname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				</tbody></table>
			</div>
			<div id="corpnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules:
				    <select id="corpname_rules" onchange="checkRules('corpname')">
				    	<option value="none">None</option>
						<option value="ncarules">NCA Rules</option>
						<option value="aacr2">AACR2</option>
				    </select>
				</p>
				<input class="apbutton" type="button" onclick="addAccessPoint('corpname');" value="Add To Record"></input><br />
				<input class="apbutton" type="button" onclick="resetAccessPoint('corpname');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>	
<!-- placename -->
		<div id="geogname" class="apcontainer">
			<p><strong>Place Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=PL', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/geogname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'geogname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedgeognames" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="geognametable" class="tablecontainer">
				    <table id="table_geogname"><tbody>
						<tr NoDrop="true" NoDrag="true"><td class="label">Location:</td><td> <input type="text" onfocus="setCurrent(this);" id="geogname_location" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="geogname_source" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="geognamedropdown">				  	  			  		
				    		<option value="geogname_dates">Dates</option>		    		
				    	</select></td>
				    	<td><input type="text" onfocus="addField('geogname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				    </tbody></table>
				</div>
				<div id="geognamebuttons" class="buttoncontainer">
					<p class="apbutton">Rules:
			    			<select id="geogname_rules" onchange="checkRules('geogname')">
			    				<option value="none">None</option>
			      				<option value="ncarules">NCA Rules</option>
			      				<option value="aacr2">AACR2</option>
			    			</select></p>
					<input class="apbutton" type="button" onclick="addAccessPoint('geogname');" value="Add To Record"></input><br />
					<input class="apbutton" type="button" onclick="resetAccessPoint('geogname');" value="Reset" ></input>
				</div>
				<br/>
		</div>
		<br/>
<!--title -->
		<div id="title" class="apcontainer">
			<p><strong>Book Title</strong></p>
			<xsl:choose>
				<xsl:when test="controlaccess/title">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'title'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedtitles" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="titletable" class="tablecontainer">
					<table id="table_title"><tbody>
						<tr NoDrop="true" NoDrag="true"><td class="label">Title:</td><td> <input type="text" onfocus="setCurrent(this);" id="title_title" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="title_source" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td><select onfocus="setCurrent(this);" id="titledropdown">				  	  			  		
				    		<option value="title_dates">Dates</option>			    		
				    	</select></td>
				    	<td><input type="text" onfocus="addField('title')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
					</tbody></table>
				</div>
				<div id="titlebuttons" class="buttoncontainer">
					<p class="apbutton">Rules:
					    <select id="title_rules" onchange="checkRules('title')">
					      <option value="none">None</option>
					      <option value="ncarules">NCA Rules</option>
					      <option value="aacr2">AACR2</option>
					    </select></p>
						<input class="apbutton" type="button" onclick="addAccessPoint('title');" value="Add To Record"></input><br />
						<input class="apbutton" type="button" onclick="resetAccessPoint('title');" value="Reset" ></input>
				</div>
				<br/>
			</div>
			<br/>	
<!-- genreform -->
		<div id="genreform" class="apcontainer">
			<p><strong>Genre Form</strong></p>
			<xsl:choose>
				<xsl:when test="controlaccess/genreform">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'genreform'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedgenreforms" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="genreformtable" class="tablecontainer">
					<table id="table_genreform"><tbody>
						<tr NoDrop="true" NoDrag="true"><td class="label">Genre:</td><td> <input type="text" onfocus="setCurrent(this);" id="genreform_genre" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="genreform_source" size="40"></input></td></tr>
					</tbody></table>
				</div>
				<div id="genreformbuttons" class="buttoncontainer">
						<input class="apbutton" type="button" onclick="addAccessPoint('genreform');" value="Add To Record"></input><br />
						<input class="apbutton" type="button" onclick="resetAccessPoint('genreform');" value="Reset" ></input>
				</div>
				<br/>
			</div>
			<br/>				
			
<!-- function -->
		<div id="function" class="apcontainer">
			<p><strong>Function</strong></p>
			<xsl:choose>
				<xsl:when test="controlaccess/function">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'function'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedfunctions" style="display:none" class="added"><xsl:text> </xsl:text></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="functiontable" class="tablecontainer">
					<table id="table_function"><tbody>
						<tr NoDrop="true" NoDrag="true"><td class="label">Function:</td><td> <input type="text" onfocus="setCurrent(this);" id="function_function" size="40"></input></td></tr>
						<tr NoDrop="true" NoDrag="true"><td class="label">Source:</td><td> <input type="text" onfocus="setCurrent(this);" id="function_source" size="40"></input></td></tr>
					</tbody></table>
				</div>
				<div id="functionbuttons" class="buttoncontainer">
						<input class="apbutton" type="button" onclick="addAccessPoint('function');" value="Add To Record"></input><br />
						<input class="apbutton" type="button" onclick="resetAccessPoint('function');" value="Reset" ></input>
				</div>
				<br/>
			</div>
			<br/>						
			
								
		</div>	
  </xsl:template>
  
  
  
  <xsl:template name="accesspoint">
  	<xsl:param name="aptype"/>
  	<div style="display:block" class="added"> 
  	<xsl:attribute name="id">
  		<xsl:text>added</xsl:text><xsl:value-of select="$aptype"/><xsl:text>s</xsl:text>
  	</xsl:attribute>
		<xsl:for-each select="controlaccess/*[name() = $aptype]">
		 	<input type="hidden">
		 		<xsl:attribute name="name">
		 			<xsl:text>controlaccess/</xsl:text><xsl:value-of select="$aptype"/>
		 		</xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$aptype"/><xsl:text>_formgen</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>xml</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="value">
					<div class="accesspoint">					 
						<xsl:call-template name="accesspointstring">					
							<xsl:with-param name="aptype" select="$aptype"/>
							<xsl:with-param name="separater" select="' ||| '"/>
						</xsl:call-template>
					</div>
				</xsl:attribute>
			</input>
	  	 	<div>
				<xsl:attribute name="id">
					<xsl:value-of select="$aptype"/><xsl:text>_formgen</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/>				
				</xsl:attribute>			
				<div class="icons">
					<a>
						<xsl:attribute name="onclick">
							<xsl:text>deleteAccessPoint('</xsl:text><xsl:value-of select="$aptype"/><xsl:text>_formgen</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>');</xsl:text>
						</xsl:attribute>
						<xsl:attribute name="title">
							<xsl:text>delete entry</xsl:text>
						</xsl:attribute>
						<img src="/images/deleteSmall1.gif">
						<xsl:attribute name="id">
							<xsl:text>delete</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/>
						</xsl:attribute>
						</img>
					</a>										
				</div>
				<div class="accesspoint">	
					<xsl:attribute name="onclick">
						<xsl:text>editAccessPoint('</xsl:text><xsl:value-of select="$aptype"/><xsl:text>_formgen', </xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>);</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="title">
						<xsl:text>Click to edit</xsl:text>
					</xsl:attribute>		 
					<xsl:call-template name="accesspointstring">					
						<xsl:with-param name="aptype" select="$aptype"/>
						<xsl:with-param name="separater" select="' '"/>
					</xsl:call-template>
				</div>
			</div>
			<br>
				<xsl:attribute name="id">
					<xsl:value-of select="$aptype"/><xsl:text>_formgen</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>br</xsl:text>
				</xsl:attribute>
			</br>			
	 	</xsl:for-each>	 												
	</div>	  	
  </xsl:template>
  
  
  
  
  <xsl:template name="accesspointstring">
  	 <xsl:param name="aptype"/>
  	 <xsl:param name="separater"/>
  	 <xsl:choose>
  	 	<xsl:when test="emph">
		  	 <xsl:choose>
		  	 	<xsl:when test="$separater = ' '">
		  	 		<xsl:for-each select="emph">
		  	 			<xsl:value-of select="."/>
		  	 			<xsl:value-of select="$separater"/>
		  	 		</xsl:for-each>
		  	 	</xsl:when>
		  	 	<xsl:when test="$separater = ' ||| '">
		  	 		<xsl:for-each select="emph">
		  	 			<xsl:value-of select="$aptype"/>
		  	 			<xsl:text>_</xsl:text>
		  	 			<xsl:value-of select="@altrender"/>
		  	 			<xsl:text> | </xsl:text>
		  	 			<xsl:value-of select="."/>
		  	 			<xsl:value-of select="$separater"/>
		  	 		</xsl:for-each>
		  	 		<xsl:if test="@source">
			  	  		<xsl:value-of select="$aptype"/>
		  	 			<xsl:text>_source | </xsl:text>
			  	  		<xsl:apply-templates select="@source"/>  	 
			  	  		<xsl:value-of select="$separater"/> 				
			  	  	</xsl:if>
					<xsl:if test="@rules">
						<xsl:value-of select="$aptype"/>
		  	 			<xsl:text>_rules | </xsl:text>
			  	  		<xsl:apply-templates select="@rules"/>  	 
			  	  		<xsl:value-of select="$separater"/> 				
			  	  	</xsl:if>
		  	 		<xsl:for-each select="@*">
		  	 			<xsl:if test="not(name() = 'rules') and not(name() = 'source')">
		  	 				<xsl:text>att_</xsl:text>
		  	 				<xsl:value-of select="name()"/>
		  	 				<xsl:text> | </xsl:text>
		  	 				<xsl:value-of select="."/>
		  	 				<xsl:value-of select="$separater"/>
		  	 			</xsl:if>
		  	 		</xsl:for-each>	 
		  	 	</xsl:when>
		  	 </xsl:choose>
	  	 </xsl:when>
	  	 <xsl:otherwise>
	  	 	<xsl:choose>
	  	 		<xsl:when test="$separater = ' '">
	  	 			<xsl:value-of select="./text()"/>
	  	 			<xsl:value-of select="$separater"/>
	  	 		</xsl:when>
	  	 		<xsl:when test="$separater = ' ||| '">
	  	 			<xsl:value-of select="$aptype"/>
		  	 		<xsl:text>_a | </xsl:text>
		  	 		<xsl:value-of select="."/>
		  	 		<xsl:value-of select="$separater"/>
		  	 		<xsl:if test="@source">
			  	  		<xsl:value-of select="$aptype"/>
		  	 			<xsl:text>_source | </xsl:text>
			  	  		<xsl:apply-templates select="@source"/>  	 
			  	  		<xsl:value-of select="$separater"/> 				
			  	  	</xsl:if>
					<xsl:if test="@rules">
						<xsl:value-of select="$aptype"/>
		  	 			<xsl:text>_rules | </xsl:text>
			  	  		<xsl:apply-templates select="@rules"/>  	 
			  	  		<xsl:value-of select="$separater"/> 				
			  	  	</xsl:if>
		  	 		<xsl:for-each select="@*">
		  	 			<xsl:if test="not(name() = 'rules') and not(name() = 'source')">
		  	 				<xsl:text>att_</xsl:text>
		  	 				<xsl:value-of select="name()"/>
		  	 				<xsl:text> | </xsl:text>
		  	 				<xsl:value-of select="."/>
		  	 				<xsl:value-of select="$separater"/>
		  	 			</xsl:if>
		  	 		</xsl:for-each>
	  	 		</xsl:when>
	  	 	</xsl:choose>
	  	 </xsl:otherwise>
	  </xsl:choose>
  </xsl:template>

  
  
  <xsl:template match="did/unitid">
	<input type="text" name="did/unitid/@countrycode" id="countrycode" maxlength="2" size="3" onblur="checkId()">	
		<xsl:choose>	
		<xsl:when test="@countrycode">
			<xsl:attribute name="value">
				<xsl:value-of select="@countrycode"/>
			</xsl:attribute>
		</xsl:when>	
		<xsl:when test="$leveltype='collection' and current()/ancestor::ead/eadheader/eadid/@countrycode">
			<xsl:attribute name="value">
				<xsl:value-of select="current()/ancestor::ead/eadheader/eadid/@countrycode"/>
			</xsl:attribute>
		</xsl:when>
		</xsl:choose>	
	</input>
	<input type="text" onfocus="setCurrent(this);" name="did/unitid/@repositorycode" id="repositorycode"  maxlength="4" size="5" onblur="checkId()">
		<xsl:choose>
		<xsl:when test="@repositorycode">
			<xsl:attribute name="value">
				<xsl:value-of select="@repositorycode"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="$leveltype='collection' and current()/ancestor::ead/eadheader/eadid/@mainagencycode">
			<xsl:attribute name="value">
				<xsl:value-of select="current()/ancestor::ead/eadheader/eadid/@mainagencycode"/>
			</xsl:attribute>
		</xsl:when>
		</xsl:choose>
	</input>
	<input type="text" onfocus="setCurrent(this);" name="did/unitid" id="unitid" size="50" onblur="checkId()">
		<xsl:attribute name="value">
			<xsl:value-of select="." />
		</xsl:attribute>
	</input> 
  </xsl:template>
  
  <xsl:template match="did/unittitle">
  	<input class="menuField" type="text" onfocus="setCurrent(this);" name="did/unittitle" id="cab" size="80" onchange="updateTitle(this)">
  		<xsl:attribute name="value">
  			<xsl:apply-templates/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
    
  <xsl:template match="unitdate">
  	<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="did/unitdate" id="cac" size="39">
  		<xsl:attribute name="value">
  		  <xsl:apply-templates/>
  		</xsl:attribute>	
  	</input>
  </xsl:template>
  
  <xsl:template match="unitdate/@normal">
  	<input type="text" onfocus="setCurrent(this);" name="did/unitdate" id="can" size="39" maxlength="10">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="did/repository">
  	<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="did/repository" id="rep" size="80">
  		<xsl:attribute name="value">
  			<xsl:apply-templates/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="filedesc/titlestmt/sponsor">
  	<strong><span class="isadg"></span>Sponsor </strong> <a class="smalllink" id="linkspo" title="add sponsor" onclick="addElement('spo')">hide</a> [optional]<br/>
  	<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="filedesc/titlestmt/sponsor" id="spo" size="80">
  		<xsl:attribute name="value">
  			<xsl:apply-templates/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  
  <xsl:template match="did/physdesc/extent">
  	<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="did/physdesc/extent" id="cae" size="80">
  		<xsl:attribute name="value">
  			<xsl:apply-templates/>
  		</xsl:attribute>
  	</input>
  </xsl:template>

  <xsl:template match="did/origination">
  	<input class="menuField" type="text" onchange="validateField(this, 'true');" onfocus="setCurrent(this);" name="did/origination" id="cba" size="80">
  		<xsl:attribute name="value">
  			<xsl:apply-templates/>
  		</xsl:attribute>
  	</input>
  </xsl:template>


  <xsl:template match="did/langmaterial">
	<div id="addedlanguages" style="display:block" class="added">
		<xsl:for-each select="language">
			<input type="hidden" name="did/langmaterial/language">
				<xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>xml</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:text>lang_code | </xsl:text><xsl:value-of select="@langcode"/><xsl:text> ||| lang_name | </xsl:text><xsl:value-of select="."/><xsl:text> ||| </xsl:text>
					<xsl:for-each select="@*">
		  	 			<xsl:if test="not(name() = 'langcode')">
		  	 				<xsl:text>att_</xsl:text>
		  	 				<xsl:value-of select="name()"/>
		  	 				<xsl:text> | </xsl:text>
		  	 				<xsl:value-of select="."/>
		  	 				<xsl:text> ||| </xsl:text>
		  	 			</xsl:if>
		  	 		</xsl:for-each>	
				</xsl:attribute>
			</input>
			<div>
				<xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/>				
				</xsl:attribute>			
				<div class="icons">
					<a>
						<xsl:attribute name="onclick">
							<xsl:text>deleteAccessPoint('language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>');</xsl:text>
						</xsl:attribute>
						<xsl:attribute name="title">
							<xsl:text>delete entry</xsl:text>
						</xsl:attribute>
						<img src="/images/deleteSmall1.gif">
						<xsl:attribute name="id">
							<xsl:text>delete</xsl:text><xsl:number level="single" count="language" format="1"/>
						</xsl:attribute>
						</img>
					</a>									
				</div>
				<div class="accesspoint">
				
					<xsl:attribute name="onclick">
						<xsl:text>editAccessPoint('language_formgen', </xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>);</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="title">
						<xsl:text>Click to edit</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="@langcode"/><xsl:text> </xsl:text><xsl:value-of select="."/>
				</div>
			</div>
			<br>
				<xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>br</xsl:text>
				</xsl:attribute>
			</br>
			
		</xsl:for-each>													
	</div>	
  </xsl:template>

  
  
  <xsl:template name="option">
	<!-- Generates an option to go in the drop-down list -->
	<xsl:param name="value" />
	<xsl:param name="label" />
	<xsl:param name="select" />

	<xsl:element name="option">
	  <xsl:attribute name="value"><xsl:value-of select="$value" /></xsl:attribute>
	  <xsl:if test="$value = $select"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
	  <xsl:value-of select="$label" />
	</xsl:element>
  </xsl:template>
  
  
  
  <xsl:template name="textarea">
  	<xsl:param name="name" />
  	<xsl:param name="id" />
  	<xsl:param name="class" />
  	<xsl:param name="optional" />
  	<xsl:param name="content" />  
  	<xsl:param name="isadg" />
  	<xsl:param name="title" />
  	<xsl:param name="help" />
  	<xsl:param name="additional" />
  	<xsl:call-template name="label">
  		<xsl:with-param name="id" select="$id"/>
  		<xsl:with-param name="optional" select="$optional"/>
  		<xsl:with-param name="content" select="$content"/> 
  		<xsl:with-param name="isadg" select="$isadg"/>
  		<xsl:with-param name="title" select="$title"/>
  		<xsl:with-param name="help" select="$help"/>  	
  		<xsl:with-param name="additional" select="$additional"/>  		
  	</xsl:call-template>
  	<textarea onchange="validateField(this, 'true');" onfocus="setCurrent(this);" rows="5" cols="80">
  		<xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
  		<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
  		<xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
  		<xsl:if test="$optional = 'true' and $content = 'false'">
  			<xsl:attribute name="style">display:none</xsl:attribute>	
  		</xsl:if>
  		<xsl:choose>
  			<xsl:when test="$content = 'false'">
  				<xsl:text> </xsl:text>
  			</xsl:when>
  			<xsl:otherwise>
  				<xsl:text> </xsl:text>
  				<xsl:apply-templates select="./node()"/>	
  			</xsl:otherwise>
  		</xsl:choose>
  	</textarea> 
  	
  </xsl:template>
   
   
  <xsl:template name="label">
  	<xsl:param name="id" />
  	<xsl:param name="optional" />
  	<xsl:param name="content" />
  	<xsl:param name="isadg" />
  	<xsl:param name="title" />
  	<xsl:param name="help" />
  	<xsl:param name="additional" />
  	<br/>
  	<strong><span class="isadg"><xsl:value-of select="$isadg"/></span> 	
  	<xsl:choose>
		<xsl:when test="not($help='')">
			<a>
			<xsl:attribute name="href">
				<xsl:value-of select="$help"/>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="$title"/><xsl:text> help - opens in new window</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="target">
				<xsl:text>_new</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="$title"/>
			</a>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$title"/>
		</xsl:otherwise>
  	</xsl:choose>  	
  	</strong>
  	<xsl:if test="not($additional = '')">
  		<xsl:text> </xsl:text>
  		<xsl:value-of select="$additional"/>
  	</xsl:if>
  	<xsl:if test="$optional = 'true'">
  		<xsl:text> </xsl:text>
  		<a class="smalllink">
  			<xsl:attribute name="title">
  				<xsl:text>add </xsl:text>
  				<xsl:value-of select="$title"/>
  			</xsl:attribute>
  			<xsl:attribute name="id">
  				<xsl:text>link</xsl:text>
  				<xsl:value-of select="$id"/>
  			</xsl:attribute>
  			<xsl:attribute name="onclick">
  				<xsl:text>addElement('</xsl:text><xsl:value-of select="$id"/><xsl:text>')</xsl:text>
  			</xsl:attribute>
  		    <xsl:choose>
  				<xsl:when test="$content = 'true'">
  					<xsl:text>hide</xsl:text>
  				</xsl:when>
  				<xsl:otherwise>
  					<xsl:text>add</xsl:text>
  				</xsl:otherwise>
  			</xsl:choose>
  		</a>
  		<xsl:text> [optional]</xsl:text>
  	</xsl:if>
	<br/>  	
  </xsl:template>
  
  <xsl:template match="comment()">
  	<xsl:comment><xsl:value-of select="."/></xsl:comment>
  </xsl:template>
  
  <xsl:template match="*">
        <xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/>
        <xsl:for-each select="@*">
			  <xsl:text> </xsl:text>
			  <xsl:value-of select="name()"/>
			  <xsl:text>="</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
        </xsl:for-each>
 <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
  </xsl:template> 
  
  
</xsl:stylesheet>

