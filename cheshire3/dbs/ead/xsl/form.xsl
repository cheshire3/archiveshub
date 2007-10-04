<?xml version="1.0"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:output method="html" encoding="UTF-8"/>
 
  <xsl:variable name="idstring">
  	<xsl:value-of select="//eadid/text()"/>
  </xsl:variable>

  
  <xsl:template match="/">
  <xsl:if test="/ead">
  	
  </xsl:if>
   <form id="eadForm" name="eadForm" onreset="resetForm(this)" action="#" onsubmit="alert($(this).serialize()); return false">
   <a id="addC" href="javascript: addComponent()">Add component/subcomponent to this record/component</a>
   <div class="section">
  	<h3>Collection Level Description</h3>
  	<p>
  	<strong>Repository Name</strong> (e.g. University of Nottingham)
	<br/>
  	<xsl:choose>
  		<xsl:when test="/ead/archdesc/did/repository">
  			<xsl:apply-templates select="/ead/archdesc/did/repository"/>
  		</xsl:when>
  		<xsl:otherwise>
			<input name="/ead/archdesc/did/repository" type="text" onfocus="parent.setCurrent(this);" id="rep" size="80"></input>
  		</xsl:otherwise>
  	</xsl:choose>
  	</p>
  	</div>
  	<div id="sec-3-1" class="section">
      <h3>3.1: Identity Statement Area</h3>
  	<p>
	  <strong>3.1.1: <a href="arch/refcode.shtml" title="Reference Code help - opens in new window" target="_new">Reference Code</a></strong> 
	  Comprising of <a href="http://www.iso.org/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html" target="_new" title="Further information on ISO Country Codes">ISO Country Code</a>, 
	  NCA Repository Code,
	  and a unique identifier for this record or component.
	  [<strong>all fields required</strong>]<br/>
  	<xsl:choose>
  		<xsl:when test="//eadid">
  			<xsl:apply-templates select="//eadid"/>
  		</xsl:when>
  		<xsl:otherwise>  			
			<input type="text" name="caa-cc" id="caa-cc" maxlength="2" size="3" value="GB"></input>
			<input type="text" onfocus="parent.setCurrent(this);" name="caa-rc" id="caa-rc" maxlength="4" size="5"></input>
			<input type="text" onfocus="parent.setCurrent(this);" name="caa-id" id="caa-id" size="50"></input>	
  		</xsl:otherwise>
  	</xsl:choose>
  	</p>
  	 <p>
		<strong>3.1.2: <a href="arch/title.shtml" title="Title help - opens in new window" target="_new">Title</a></strong><br/>
		<xsl:choose>
			<xsl:when test="//did/unittitle">
				<xsl:apply-templates select="//did/unittitle"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="did/unittitle" id="cab" size="80" onchange="updateTitle()"></input>
			</xsl:otherwise>
		</xsl:choose>		
   </p>
    <div class="float">
    	<p><strong>3.1.3: <a href="arch/dates1.shtml" title="Dates of Creation help - opens in new window" target="_new">Dates of Creation</a></strong><br/>
		<xsl:choose>
			<xsl:when test="//unitdate">
				<xsl:apply-templates select="//unitdate"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="cac" id="cac" size="39"></input>
			</xsl:otherwise>
		</xsl:choose>      
		</p>
	</div>
	<div class="float"><p>
		<strong><a href="arch/dates2.shtml" title="Normalised Date help - opens in new window" target="_new">Normalised Date</a></strong><br/>
	    	<xsl:choose>
	    		<xsl:when test="//unitdate/@normal">
	    			<xsl:apply-templates select="//unitdate/@normal"/>
	    		</xsl:when>
	    		<xsl:otherwise>
	    			<input type="text" onfocus="parent.setCurrent(this);" name="can" id="can" size="39" maxlength="10"></input>
	    		</xsl:otherwise>
	    	</xsl:choose>      
	            
		</p>
	</div>
   	<br/>
 	<p>
		<strong>3.1.5: <a href="arch/extent.shtml" title="Extent help - opens in new window" target="_new">Extent of Unit of Description</a></strong><br/>
		<xsl:choose>
			<xsl:when test="//extent">
				<xsl:apply-templates select="//extent"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="cae" id="cae" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>
		
    </p>
    <p><strong>Note: 3.1.4 Level of Description</strong> will be generated automatically for this record, with "fonds" as the default.</p>
  	</div>
 <!--  CONTEXT  --> 	
  	<div class="section">
		<h3>3.2: Context Area</h3> 
		<p>
		<strong>3.2.1: <a href="arch/name.shtml" title="Name of Creator help - opens in new window" target="_new">Name of Creator</a></strong>  [<strong>also add manually as <a href="#accesspoints" title="Add Access Point manually">Access Point</a></strong>]<br/>
		<xsl:choose>
			<xsl:when test="//origination">
				<xsl:apply-templates select="//origination"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="cba" id="cba" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>		
    	</p>
    	<p>
		<strong>3.2.2: <a href="arch/bioghist.shtml" title="Administrative/Biographical History help - opens in new window" target="_new">Administrative/Biographical History</a></strong>
		<br/>
		<xsl:choose>
			<xsl:when test="//bioghist">
				<xsl:apply-templates select="//bioghist"/>
			</xsl:when>
			<xsl:otherwise>
				<textarea name="cbb" id="cbb" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
			</xsl:otherwise>			
		</xsl:choose>
		</p>
		<p>		
		<xsl:choose>
			<xsl:when test="//custodhist">
				<xsl:apply-templates select="//custodhist"/>
			</xsl:when>
			<xsl:otherwise>
				<strong>3.2.3: Archival History </strong> <a class="smalllink" id="linkcbc" title="add archival history" onclick="addElement('cbc')">add</a> [optional]
				<br/>
				<textarea name="cbc" id="cbc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
			</xsl:otherwise>
		</xsl:choose>			
      	</p>      	
      	<p>
      	<xsl:choose>
      		<xsl:when test="//acqinfo">
      			<xsl:apply-templates select="//acqinfo"/>
      		</xsl:when>
      		<xsl:otherwise>
      			<strong>3.2.4: Immediate Source of Acquisition</strong> <a class="smalllink" id="linkcbd" title="add archival history" onclick="addElement('cbd')">add</a> [optional]
				<br/>
				<textarea name="cbd" id="cbd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>		
      	</p>       
	</div>  

<!--CONTENT AND STRUCTURE ==================================================================================== -->
	<div class="section">
	<h3>3.3: Content and Structure Area</h3> 
	 <p>
	 <strong>3.3.1: <a href="arch/scope.shtml" title="Scope and Content help - opens in new window" target="_new">Scope and Content</a></strong>
			<br/>
	 <xsl:choose>
	 	<xsl:when test="//scopecontent">
	 		<xsl:apply-templates select="//scopecontent"/>
	 	</xsl:when>
	 	<xsl:otherwise>	 		
			<textarea name="cca" id="cca" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
	 	</xsl:otherwise>
	 </xsl:choose>
	
      </p>
	</div>
		
  	</form>
  </xsl:template>  
  	  
   <xsl:template match="scopecontent">
  	  <textarea name="cca" id="cca" onfocus="parent.setCurrent(this);" rows="5" cols="80">
  	  	<xsl:value-of select="."/>
  	  </textarea>
   </xsl:template>
  
   <xsl:template match="acqinfo">
  		<strong>3.2.4: Immediate Source of Acquisition </strong> <a class="smalllink" id="linkcbd" title="add archival history" onclick="addElement('cbd')">hide</a> [optional]
		<br/>
  	  	<textarea name="cbd" id="cbd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>
  	
  <xsl:template match="custodhist">
  		<strong>3.2.3: Archival History </strong> <a class="smalllink" id="linkcbc" title="add archival history" onclick="addElement('cbc')">hide</a> [optional]
		<br/>
  	  	<textarea name="cbc" id="cbc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>
  
  <xsl:template match="bioghist">
  	<textarea name="cbb" id="cbb" onfocus="parent.setCurrent(this);" rows="5" cols="80">  		
		<xsl:value-of select="."/>  		  		
  	</textarea>
  </xsl:template>
  
  <xsl:template match="origination">
  	<input type="text" onfocus="parent.setCurrent(this);" name="cba" id="cba" size="80">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="extent">
  	<input type="text" onfocus="parent.setCurrent(this);" name="cae" id="cae" size="80">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="unitdate/@normal">
  	<input type="text" onfocus="parent.setCurrent(this);" name="can" id="can" size="39" maxlength="10">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="unitdate">
  	<input type="text" onfocus="parent.setCurrent(this);" name="cac" id="cac" size="39">
  		<xsl:attribute name="value">
  		  <xsl:value-of select="."/>
  		</xsl:attribute>	
  	</input>

  </xsl:template>
  
  <xsl:template match="unittitle">
  	<input type="text" onfocus="parent.setCurrent(this);" name="cab" id="cab" size="80" onchange="updateTitle()">
  		  <xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="eadid">
	<input type="text" name="caa-cc" id="caa-cc" maxlength="2" size="3" disabled="true">
		<xsl:attribute name="value">
			<xsl:value-of select="substring-before($idstring, ' ')" />
		</xsl:attribute>
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="caa-rc" id="caa-rc" maxlength="4" size="5" disabled="true">
		<xsl:attribute name="value">
			<xsl:value-of select="substring-before(substring-after($idstring, ' '), ' ')" />
		</xsl:attribute>
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="caa-id" id="caa-id" size="50" disabled="true">
		<xsl:attribute name="value">
			<xsl:value-of select="substring-after(substring-after($idstring, ' '), ' ')" />
		</xsl:attribute>
	</input> 
  </xsl:template>
  
  <xsl:template match="repository">
  	<input name="/ead/archdesc/did/repository" type="text" onfocus="parent.setCurrent(this);" id="rep" size="80">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  
  

  
</xsl:stylesheet>