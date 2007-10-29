<?xml version="1.0"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:output method="html" encoding="UTF-8"/>
 
  <xsl:variable name="eadidstring">
  	<xsl:value-of select="/ead/eadheader/eadid/text()"/>
  </xsl:variable>
  
  <xsl:template match="/">
    <form id="eadForm" name="eadForm" onreset="resetForm(this)" action="#" onsubmit="alert($(this).serialize()); return false">
    <a id="addC" href="javascript: addComponent()">Add component/subcomponent to this record/component</a>
    <!--<a id="keyboardToggle" href="javascript: toggleKeyboard()">Show Character Entity Keyboard</a>-->
      <div class="section">
    	<xsl:choose>
    		<xsl:when test="/ead/eadheader">
    			<h3>Collection Level Description</h3>

    			<xsl:apply-templates select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc"/>
    		</xsl:when>
    		<xsl:otherwise>
    			<h3>Component Level Description</h3>
    			<xsl:if test="/c/recid">
   					<xsl:apply-templates select="/c/recid"/> 					
    			</xsl:if>
    			<xsl:apply-templates select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc"/>
    		</xsl:otherwise>
    	</xsl:choose>	
     </div> 	  
	</form>
  </xsl:template>
  
  <xsl:template match="/c/recid">
  	<input type="text" id="recid" name="recid">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="/ead/eadheader">
  	<div id="sec-3-1" class="section">
      <span class="isadg"><h3>3.1: Identity Statement Area</h3></span>
      <p>
	  <strong><span class="isadg">3.1.1: </span><a href="arch/refcode.shtml" title="Reference Code help - opens in new window" target="_new">Reference Code</a></strong> 
	  Comprising of <a href="http://www.iso.org/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html" target="_new" title="Further information on ISO Country Codes">ISO Country Code</a>, 
	  NCA Repository Code,
	  and a unique identifier for this record or component.
	  [<strong>all fields required</strong>]<br/>
      	<xsl:choose>
      		<xsl:when test="eadid">
      			<xsl:apply-templates select="eadid"/>
      		</xsl:when>
      		<xsl:otherwise>
      			<input type="text" name="caa-cc" id="caa-cc" maxlength="2" size="3" value="GB"></input>
				<input type="text" onfocus="parent.setCurrent(this);" name="caa-rc" id="caa-rc" maxlength="4" size="5"></input>
				<input type="text" onfocus="parent.setCurrent(this);" name="caa-id" id="caa-id" size="50"></input>	
      		</xsl:otherwise>
      	</xsl:choose>     	
      	</p>
      </div>
  </xsl:template>
  
<!--  <xsl:template match="/ead/archdesc">
  	
  </xsl:template> --> 
  
  <xsl:template match="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc">
  <xsl:if test="not(name() = 'archdesc')">
  	<p>
    	<strong>Component Label</strong>
    	<br />
   		<input type="text" name="ctype" id="ctype" maxlength="3" size="4">
   			<xsl:attribute name="value">
   				<xsl:value-of select="name()"/>   					
 			</xsl:attribute>
   		</input>
    </p>
  </xsl:if>
  	<div id="sec-3-1" class="section">
      <span class="isadg"><h3>3.1: Identity Statement Area</h3></span>
      <p>
	  <strong><span class="isadg">3.1.1: </span><a href="arch/refcode.shtml" title="Reference Code help - opens in new window" target="_new">Reference Code</a></strong> 
	  Comprising of <a href="http://www.iso.org/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html" target="_new" title="Further information on ISO Country Codes">ISO Country Code</a>, 
	  NCA Repository Code,
	  and a unique identifier for this record or component.
	  [<strong>all fields required</strong>]<br/>
	  <xsl:choose>
	  	<xsl:when test="did/unitid">
	  	   <xsl:apply-templates select="did/unitid"/>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<input type="text" name="did/unitid" id="caa-cc" maxlength="2" size="3" value="GB" disabled="true"></input>
			<input type="text" onfocus="parent.setCurrent(this);" name="did/unitid" id="caa-rc" maxlength="4" size="5"></input>
			<input type="text" onfocus="parent.setCurrent(this);" name="did/unitid" id="caa-id" size="50"></input>	
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
				<input type="text" onfocus="parent.setCurrent(this);" name="did/unittitle/test/test" id="cab" size="80" onchange="updateTitle()"></input>
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
				<input type="text" onfocus="parent.setCurrent(this);" name="did/unitdate" id="cac" size="39"></input>
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
	    			<input type="text" onfocus="parent.setCurrent(this);" name="did/unitdate/@normal" id="can" size="39" maxlength="10"></input>
	    		</xsl:otherwise>
	    	</xsl:choose>      	            
		</p>
	</div>
  	<br/>
 	<p>
		<strong><span class="isadg">3.1.5: </span><a href="arch/extent.shtml" title="Extent help - opens in new window" target="_new">Extent of Unit of Description</a></strong><br/>
		<xsl:choose>
			<xsl:when test="did/physdesc/extent">
				<xsl:apply-templates select="did/physdesc/extent"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="did/physdesc/extent" id="cae" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>		
    </p>
    <p><strong>Note: <span class="isadg">3.1.4: </span>Level of Description</strong> will be generated automatically for this record, with "fonds" as the default.</p>
   </div>
<!-- CONTEXT -->   
   <div class="section">
		<span class="isadg"><h3>3.2: Context Area</h3></span> 
		<p>
		<strong><span class="isadg">3.2.1: </span><a href="arch/name.shtml" title="Name of Creator help - opens in new window" target="_new">Name of Creator</a></strong>  [<strong>also add manually as <a href="#accesspoints" title="Add Access Point manually">Access Point</a></strong>]<br/>
		<xsl:choose>
			<xsl:when test="did/origination">
				<xsl:apply-templates select="did/origination"/>
			</xsl:when>
			<xsl:otherwise>
				<input type="text" onfocus="parent.setCurrent(this);" name="did/origination" id="cba" size="80"></input>
			</xsl:otherwise>
		</xsl:choose>		
    	</p>
   		<p>
		<strong><span class="isadg">3.2.2: </span><a href="arch/bioghist.shtml" title="Administrative/Biographical History help - opens in new window" target="_new">Administrative/Biographical History</a></strong>
		<br/>
		<xsl:choose>
			<xsl:when test="bioghist">
				<xsl:apply-templates select="bioghist"/>
			</xsl:when>
			<xsl:otherwise>
				<textarea name="bioghist" id="cbb" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
			</xsl:otherwise>			
		</xsl:choose>
	   </p>  
	   <p>		
		<xsl:choose>
			<xsl:when test="custodhist">
				<xsl:apply-templates select="custodhist"/>
			</xsl:when>
			<xsl:otherwise>
				<strong><span class="isadg">3.2.3: </span>Archival History </strong> <a class="smalllink" id="linkcbc" title="add archival history" onclick="addElement('cbc')">add</a> [optional]
				<br/>
				<textarea name="custodhist" id="cbc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
			</xsl:otherwise>
		</xsl:choose>			
	    </p>      
	    <p>
      	<xsl:choose>
      		<xsl:when test="acqinfo">
      			<xsl:apply-templates select="acqinfo"/>
      		</xsl:when>
      		<xsl:otherwise>
      			<strong><span class="isadg">3.2.4: </span>Immediate Source of Acquisition </strong> <a class="smalllink" id="linkcbd" title="add archival history" onclick="addElement('cbd')">add</a> [optional]
				<br/>
				<textarea name="acqinfo" id="cbd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>		
      	</p>       
    </div>	
 <!-- CONTENT AND STRUCTURE -->   
    <div class="section">
	<span class="isadg"><h3>3.3: Content and Structure Area</h3></span> 
	 <p>
	 <strong><span class="isadg">3.3.1: </span><a href="arch/scope.shtml" title="Scope and Content help - opens in new window" target="_new">Scope and Content</a></strong>
			<br/>
	 <xsl:choose>
	 	<xsl:when test="scopecontent">
	 		<xsl:apply-templates select="scopecontent"/>
	 	</xsl:when>
	 	<xsl:otherwise>	 		
			<textarea name="scopecontent" id="cca" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
	 	</xsl:otherwise>
	 </xsl:choose>	
      </p>      
      <p>
      <xsl:choose>
      		<xsl:when test="appraisal">
      			<xsl:apply-templates select="appraisal"/>
      		</xsl:when>
      		<xsl:otherwise>
      			<strong><span class="isadg">3.3.2: </span>Appraisal </strong> <a class="smalllink" id="linkccb" title="add archival history" onclick="addElement('ccb')">add</a> [optional]
				<br/>
				<textarea name="appraisal" id="ccb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>		
      </p>
      <p>
      <xsl:choose>
      		<xsl:when test="accruals">
      			<xsl:apply-templates select="accruals"/>
      		</xsl:when>
      		<xsl:otherwise>
				<strong><span class="isadg">3.3.3: </span>Accruals </strong> <a class="smalllink" id="linkccc" title="add archival history" onclick="addElement('ccc')">add</a> [optional]
				<br />
				<textarea name="accruals" id="ccc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>		
      </p>
      <p>
      <xsl:choose>
      		<xsl:when test="arrangement">
      			<xsl:apply-templates select="arrangement"/>
      		</xsl:when>
      		<xsl:otherwise>
				<strong><span class="isadg">3.3.4: </span>System of Arrangement </strong> <a class="smalllink" id="linkccd" title="add archival history" onclick="addElement('ccd')">add</a> [optional]
				<br />
				<textarea name="arrangement" id="ccd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>		
      </p>
    </div>
<!-- ACCESS -->
    <div class="section">
		<span class="isadg"><h3>3.4: Conditions of Access and Use Area</h3></span>
			<p>
				 <strong><span class="isadg">3.4.1: </span><a href="arch/restrict.shtml" title="Conditions Governing Access help - opens in new window" target="_new">Conditions Governing Access</a></strong>
						<br/>
				 <xsl:choose>
				 	<xsl:when test="accessrestrict">
				 		<xsl:apply-templates select="accessrestrict"/>
				 	</xsl:when>
				 	<xsl:otherwise>	 		
						<textarea name="accessrestrict" id="cda" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
				 	</xsl:otherwise>
				 </xsl:choose>	
			</p>      
			<p>
		      <xsl:choose>
		      		<xsl:when test="userestrict">
		      			<xsl:apply-templates select="userestrict"/>
		      		</xsl:when>
		      		<xsl:otherwise>
						<strong><span class="isadg">3.4.2: </span>Conditions Governing Reproduction </strong> <a class="smalllink" id="linkcdb" title="add archival history" onclick="addElement('cdb')">add</a> [optional]
						<br />
						<textarea name="userestrict" id="cdb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
		      		</xsl:otherwise>
		      </xsl:choose>		
		     </p>
		     <p>
		     	<strong><span class="isadg">3.4.3: </span><a href="/arch/lang.shtml" title="Language of Material help - opens in new window" target="_new">Language of Material</a></strong> [Must include <a href="http://www.loc.gov/standards/iso639-2/englangn.html" title="ISO 639-2 codes - opens new window" target="_new">ISO 639-2 3-letter code</a>]
		     	<div id="language" class="apcontainer">
		     	<xsl:choose>
		     		<xsl:when test="langmaterial/language">
		     			<xsl:apply-templates select="langmaterial"/>
		     		</xsl:when>
		     		<xsl:otherwise>		     			
						<div id="addedlanguages" style="display:none" class="added"></div>		
		     		</xsl:otherwise>
		     	</xsl:choose>
		     		<div id="languagetable" class="tablecontainer">
		  				<table>
		      				<tr><td> 3-letter ISO code:</td><td> <input type="text" id="lang_code" maxlength="3" size="5"></input></td></tr>
							<tr><td> Language:</td><td> <input type="text" id="lang_name" onfocus="parent.setCurrent(this);" size="30"></input></td></tr>
		  				</table>
					</div>
		  			<div id="languagebuttons" class="buttoncontainer">
		      			<input class="apbutton" type="button" onclick="addLanguage();" value="Add Language" ></input>
		  			</div>
      			</div>
      			<br/>		     	
		     </p>
		     <p>
		     	<xsl:choose>
		     		<xsl:when test="phystech">
		     			<xsl:apply-templates select="phystech"/>
		     		</xsl:when>
		     		<xsl:otherwise>
		     			<strong><span class="isadg">3.4.4: </span>Physical Characteristics </strong> <a class="smalllink" id="linkcdd" title="add physical characteristics" onclick="addElement('cdd')">add</a> [optional]
						<br/>
						<textarea name="phystech" id="cdd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
		     		</xsl:otherwise>
		     	</xsl:choose>			 	
      		</p>
      		<p>
				<strong><span class="isadg">3.4.5: </span><a href="arch/other.shtml" title="Finding Aids help - opens in new window" target="_new">Finding Aids</a></strong>
				<br/>
				<xsl:choose>
					<xsl:when test="otherfindaid">
						<xsl:apply-templates select="otherfindaid"/> 
					</xsl:when>
					<xsl:otherwise>
						<textarea name="cde" id="cde" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
					</xsl:otherwise>
				</xsl:choose>				
	       </p>		     					
	</div>
	<div class="section">
      <span class="isadg"><h3>3.5: Allied Materials Area</h3></span>
      	<p>
      		<xsl:choose>
      			<xsl:when test="originalsloc">
      				<xsl:apply-templates select="originalsloc"/>
      			</xsl:when>
      			<xsl:otherwise>
      				<strong><span class="isadg">3.5.1: </span>Existence/Location of Originals </strong> <a class="smalllink" id="linkcea" title="add archival history" onclick="addElement('cea')">add</a> [optional]
					<br/>
        			<textarea  name="originalsloc" id="cea" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      			</xsl:otherwise>
      		</xsl:choose>	
        </p> 
		<p>
			<xsl:choose>
				<xsl:when test="altformavail">
					<xsl:apply-templates select="altformavail"/>
				</xsl:when>
				<xsl:otherwise>
					<strong><span class="isadg">3.5.2: </span>Existence/Location of Copies </strong> <a class="smalllink" id="linkceb" title="add archival history" onclick="addElement('ceb')">add</a> [optional]
					<br/>
					<textarea name="altformavail" id="ceb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
				</xsl:otherwise>
			</xsl:choose>			
      	</p>
		<p>
			<xsl:choose>
				<xsl:when test="relatedmaterial">
					<xsl:apply-templates select="relatedmaterial"/>
				</xsl:when>
				<xsl:otherwise>
					<strong><span class="isadg">3.5.3: </span>Related Units of Description </strong> <a class="smalllink" id="linkcec" title="add archival history" onclick="addElement('cec')">add</a> [optional]
					<br/>
					<textarea name="relatedmaterial" id="cec" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
				</xsl:otherwise>
			</xsl:choose>			
      	</p>
      	 <p>
      	 	<xsl:choose>
      	 		<xsl:when test="bibliography">
      	 			<xsl:apply-templates select="bibliography"/>
      	 		</xsl:when>
      	 		<xsl:otherwise>
      	 			<strong><span class="isadg">3.5.4: </span>Publication Note</strong> [Works based on or about the collection] <a class="smalllink" id="linkced" title="add archival history" onclick="addElement('ced')">add</a> [optional]
					<br/>
					<textarea name="bibliography" id="ced" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
      	 		</xsl:otherwise>
      	 	</xsl:choose>
      	</p>
	</div>
	<div class="section">
	<span class="isadg"><h3>3.6: Note Area</h3></span> 
	  <p>
	  	<xsl:choose>
	  		<xsl:when test="note">
	  			<xsl:apply-templates select="note"/>
	  		</xsl:when>
	  		<xsl:otherwise>
	  			<strong><span class="isadg">3.6.1: </span>Note </strong> <a class="smalllink" id="linkcfa" title="add archival history" onclick="addElement('cfa')">add</a> [optional]
				<br/>
				<textarea name="note" id="cfa" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none"></textarea>
	  		</xsl:otherwise>
	  	</xsl:choose>		
	  </p>
	</div>
	<div class="section">
      <span class="isadg"><h3>3.7: Description Area</h3></span> 
      <p>
      	<strong><a href="arch/archnote.shtml" title="Archivist's Note help - opens in new window" target="_new"><span class="isadg">3.7.1: </span>Archivist's Note</a></strong>
		<br/>
      	<xsl:choose>
      		<xsl:when test="processinfo">
      			<xsl:apply-templates select="processinfo"/>
      		</xsl:when>
      		<xsl:otherwise>      			
        		<textarea name="processinfo" id="cga" onfocus="parent.setCurrent(this);" rows="5" cols="80"></textarea>
      		</xsl:otherwise>
      	</xsl:choose>	
      </p>
	  <strong>Note: <!-- 3.7.2 Rules and Conventions</strong> and --><span class="isadg">3.7.3 </span>Dates of Description</strong> will be generated automatically for this record.
      <input type="hidden" name="revisions" id="revisions" value=""></input>
	</div>
	<div id="accesspointssection" class="section">
		<h3><a id="accesspoints" name="accesspoints">Access Points</a></h3>
<!-- SUBJECT -->
		<div id="subject" class="apcontainer">
			<p><strong>Subject</strong><br /><a onclick="window.open('http://www.archiveshub.ac.uk/unesco/', 'new', 'width=800 height=600');">[Search UNESCO] </a> <a onclick="window.open('http://www.archiveshub.ac.uk/lcsh/', 'new', 'width=800 height=600');"> [Search LCSH]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/subject">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'subject'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedsubjects" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="subjecttable" class="tablecontainer">
				<table>
				<tbody>
			    	<tr><td class="label">Subject:</td><td><input type="text" onfocus="parent.setCurrent(this);" id="subject_subject" size="40"></input></td></tr>
			    	<tr><td><select onfocus="parent.setCurrent(this);" id="subjectdropdown">
			    		<option value="subject_dates">Dates</option>
			    		<option value="subject_loc">Location</option>
			    		<option value="subject_other">Other</option>
			    		<option value="subject_source">Thesaurus</option>			    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('subject')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
			    </tbody>
				<!--<tr><td>Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="su_dates" size="40"></input></td></tr>
					<tr><td>Location:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="su_loc" size="40"></input></td></tr>
					<tr><td>Other:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="su_other" size="40"></input></td></tr>
					<tr><td>Thesaurus:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="su_source" size="40"></input></td></tr> -->
				</table>
			</div>
			<div id="subjectbuttons" class="buttoncontainer">
			<!--    <input class="apbutton" type="button" onclick="opensearch(0);" value="Search UNESCO" ></input><br/>-->
		  	<!--    <input class="apbutton" type="button" onclick="window.open('http://fantasia.cse.msstate.edu/lcshdb/index.cgi');" value="Search LCSH" ></input><br/>	-->			     
		  	    <input class="apbutton" type="button" onclick="addAccessPoint('subject');" value="Add to Record" ></input><br/>
		  	    <input class="apbutton" type="button" onclick="resetAccessPoint('subject');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>	
<!--PERSNAME -->
        <div id="persname" class="apcontainer">				
			<p><strong>Personal Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=P', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/persname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'persname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedpersnames" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="persnametable" class="tablecontainer">					
				<table>
				  	<tr><td class="label"> Surname:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="persname_surname" size="40"></input></td></tr>
				  	<tr><td><select onfocus="parent.setCurrent(this);" id="persnamedropdown">
				  		<option value="persname_forename">Forename</option>
			    		<option value="persname_dates">Dates</option>
			    		<option value="persname_title">Title</option>
			    		<option value="persname_epithet">Epithet</option>
			    		<option value="persname_other">Other</option>
			    		<option value="persname_source">Source</option>			    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('persname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
			<!-- 	<tr><td> Forename:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_forename" size="40"></input></td></tr>
				    <tr><td> Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_dates" size="40"></input></td></tr>
				    <tr><td> Title:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_title" size="40"></input></td></tr>
				    <tr><td> Epithet:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_epithet" size="40"></input></td></tr>
				    <tr><td> Other:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_other" size="40"></input></td></tr>
				    <tr><td> Source:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="pn_source" size="40"></input></td></tr>-->
				</table>
			</div>
			<div id="persnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules:
					<select id="persname_rules">
						<option value="ncarules">NCA Rules</option>
						<option value="aacr2">AACR2</option>
					</select>
				</p>
			<!-- 	<input class="apbutton" type="button" onclick="window.open('http://www.hmc.gov.uk/nra/personal_simple.htm', 'new', 'width=800 height=600');" value="Search NRA" ></input><br/> -->
				<input class="apbutton" type="button" onclick="addAccessPoint('persname');" value="Add Persname" ></input><br/>
				<input class="apbutton" type="button" onclick="resetAccessPoint('persname');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>
<!--FAMNAME -->
		<div id="famname" class="apcontainer">
			<p><strong>Family Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=F', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/famname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'famname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedfamnames" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>
			<div id="famnametable" class="tablecontainer">
			      <table>
					  <tr><td class="label">Surname:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="famname_surname" size="40"></input></td></tr>
				  	  <tr><td><select onfocus="parent.setCurrent(this);" id="famnamedropdown">
				  	  	<option value="famname_other">Other</option>		  		
			    		<option value="famname_dates">Dates</option>
			    		<option value="famname_title">Title</option>
			    		<option value="famname_epithet">Epithet</option>
			    		<option value="famname_loc">Location</option>
			    		<option value="famname_source">Source</option>			    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('famname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				  <!--<tr><td>Other:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="fn_other" size="40" value="family"></input></td></tr>
					  <tr><td>Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="fn_dates" size="40"></input></td></tr>
					  <tr><td>Title:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="fn_title" size="40"></input></td></tr>
					  <tr><td>Epithet:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="fn_epithet" size="40"></input></td></tr>
					  <tr><td>Location:</td><td><input type="text" onfocus="parent.setCurrent(this);" id="fn_loc" size="40"></input></td></tr>
					  <tr><td>Source:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="fn_source" size="40"></input></td></tr>-->
			      </table>
			</div>
			<div id="famnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules: 
				<select id="famname_rules">
					<option value="ncarules">NCA Rules</option>
					<option value="aacr2">AACR2</option>
				</select>
				</p>
				<!--<input class="apbutton" type="button" onclick="window.open('http://www.hmc.gov.uk/nra/family_simple.htm', 'new', 'width=800 height=600');" value="Search NRA"></input><br/>  -->
				<input class="apbutton" type="button" onclick="addAccessPoint('famname');" value="Add Famname"></input><br />
				<input class="apbutton" type="button" onclick="resetAccessPoint('famname');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>		
		<div id="corpname" class="apcontainer">
			<p><strong>Corporate Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=O', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/corpname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'corpname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedcorpnames" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>	
			<div id="corpnametable" class="tablecontainer">
				<table>
			    	<tr><td class="label">Organisation:</td><td><input type="text" onfocus="parent.setCurrent(this);" id="corpname_organisation" size="40"></input></td></tr>
			    	<tr><td><select onfocus="parent.setCurrent(this);" id="corpnamedropdown">				  	  			  		
			    		<option value="corpname_dates">Dates</option>
			    		<option value="corpname_loc">Location</option>
			    		<option value="corpname_other">Other</option>
			    		<option value="corpname_source">Source</option>			    		
			    	</select></td>
			    	<td><input type="text" onfocus="addField('corpname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				<!--<tr><td>Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="cn_dates" size="40"></input></td></tr>
					<tr><td>Location:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="cn_loc" size="40"></input></td></tr>
					<tr><td>Other:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="cn_other" size="40"></input></td></tr>
					<tr><td>Source:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="cn_source" size="40"></input></td></tr> -->
				</table>
			</div>
			<div id="corpnamebuttons" class="buttoncontainer">
				<p class="apbutton">Rules:
				    <select id="corpname_rules">
						<option value="ncarules">NCA Rules</option>
						<option value="aacr2">AACR2</option>
				    </select>
				</p>
				<!-- <input class="apbutton" type="button" onclick="window.open('http://www.hmc.gov.uk/nra/corporate_simple.htm', 'new', 'width=800 height=600');" value="Search NRA" ></input><br/> -->
				<input class="apbutton" type="button" onclick="addAccessPoint('corpname');" value="Add Corpname"></input><br />
				<input class="apbutton" type="button" onclick="resetAccessPoint('corpname');" value="Reset" ></input>
			</div>
			<br/>
		</div>
		<br/>	
<!--PLACENAME-->
		<div id="geogname" class="apcontainer">
			<p><strong>Place Name</strong><br /><a onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=PL', 'new', 'width=800 height=600');">[Search NRA]</a></p>
			<xsl:choose>
				<xsl:when test="controlaccess/geogname">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'geogname'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedgeognames" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="geognametable" class="tablecontainer">
				    <table>
						<tr><td class="label">Location:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="geogname_location" size="40"></input></td></tr>
						<tr><td><select onfocus="parent.setCurrent(this);" id="geognamedropdown">				  	  			  		
				    		<option value="geogname_dates">Dates</option>
				    		<option value="geogname_source">Source</option>			    		
				    	</select></td>
				    	<td><input type="text" onfocus="addField('geogname')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
				   <!-- <tr><td>Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="gn_dates" size="40"></input></td></tr>
						<tr><td>Source:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="gn_source" size="40"></input></td></tr> -->
				    </table>
				</div>
				<div id="geognamebuttons" class="buttoncontainer">
					<p class="apbutton">Rules:
			    			<select id="geogname_rules">
			      				<option value="ncarules">NCA Rules</option>
			      				<option value="aacr2">AACR2</option>
			    			</select></p>
					<input class="apbutton" type="button" onclick="addAccessPoint('geogname');" value="Add Geogname"></input><br />
					<input class="apbutton" type="button" onclick="resetAccessPoint('geogname');" value="Reset" ></input>
				</div>
				<br/>
		</div>
		<br/>
<!--TITLE -->
		<div id="title" class="apcontainer">
			<p><strong>Book Title</strong></p>
			<xsl:choose>
				<xsl:when test="controlaccess/title">
					<xsl:call-template name="accesspoint">
						<xsl:with-param name="aptype" select="'title'"/>
					</xsl:call-template>	
				</xsl:when>
				<xsl:otherwise>
					<div id="addedtitles" style="display:none" class="added"></div>
				</xsl:otherwise>
			</xsl:choose>	
				<div id="titletable" class="tablecontainer">
					<table>
						<tr><td class="label">Title:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="title_title" size="40"></input></td></tr>
						<tr><td><select onfocus="parent.setCurrent(this);" id="titledropdown">				  	  			  		
				    		<option value="title_dates">Dates</option>
				    		<option value="title_source">Source</option>			    		
				    	</select></td>
				    	<td><input type="text" onfocus="addField('title')" size="40" value="Click to Add Selected Field" style="background:#F2F2F2; color: grey;"></input></td></tr>
						
					<!--<tr><td>Dates:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="bt_dates" size="40"></input></td></tr>
						<tr><td>Source:</td><td> <input type="text" onfocus="parent.setCurrent(this);" id="bt_source" size="40"></input></td></tr>-->
					</table>
				</div>
				<div id="titlebuttons" class="buttoncontainer">
					<p class="apbutton">Rules:
					    <select id="title_rules">
					      <option value="ncarules">NCA Rules</option>
					      <option value="aacr2">AACR2</option>
					    </select></p>
						<input class="apbutton" type="button" onclick="addAccessPoint('title');" value="Add Title"></input><br />
						<input class="apbutton" type="button" onclick="resetAccessPoint('title');" value="Reset" ></input>
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
		 			<xsl:value-of select="$aptype"/>
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
							<xsl:text>deleteaccesspoint('</xsl:text><xsl:value-of select="$aptype"/><xsl:text>_formgen</xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>');</xsl:text>
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
				<!--<a>
						<xsl:attribute name="onclick">
							<xsl:text>editaccesspoint('</xsl:text><xsl:value-of select="$aptype"/><xsl:text>_formgen', </xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>);</xsl:text>
						</xsl:attribute>
						<xsl:text>edit</xsl:text>
					</a>	 -->									
				</div>
				<div class="accesspoint">	
						<xsl:attribute name="onclick">
							<xsl:text>editAccessPoint('</xsl:text><xsl:value-of select="$aptype"/><xsl:text>_formgen', </xsl:text><xsl:number level="single" count="controlaccess/*[name() = $aptype]" format="1"/><xsl:text>);</xsl:text>
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
  	 	</xsl:when>
  	 </xsl:choose>
  </xsl:template>

  
  <xsl:template match="did/unitid">
	<input type="text" name="did/unitid" id="caa-cc" maxlength="2" size="3" disabled="true">		
		<xsl:if test="@countrycode">
			<xsl:attribute name="value">
				<xsl:value-of select="@countrycode"/>
			</xsl:attribute>
		</xsl:if>		
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="did/unitid" id="caa-rc" maxlength="4" size="5">
		<xsl:if test="@mainagencycode">
			<xsl:attribute name="value">
				<xsl:value-of select="@mainagencycode"/>
			</xsl:attribute>
		</xsl:if>
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="did/unitid" id="caa-id" size="50">
		<xsl:attribute name="value">
			<xsl:value-of select="." />
		</xsl:attribute>
	</input> 
  </xsl:template>
  
  <xsl:template match="did/unittitle">
  	<input type="text" onfocus="parent.setCurrent(this);" name="did/unittitle" id="cab" size="80" onchange="updateTitle()">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
    
  <xsl:template match="unitdate">
  	<input type="text" onfocus="parent.setCurrent(this);" name="did/unitdate" id="cac" size="39">
  		<xsl:attribute name="value">
  		  <xsl:value-of select="."/>
  		</xsl:attribute>	
  	</input>
  </xsl:template>
  
  <xsl:template match="unitdate/@normal">
  	<input type="text" onfocus="parent.setCurrent(this);" name="did/unitdate" id="can" size="39" maxlength="10">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>
  
  <xsl:template match="did/physdesc/extent">
  	<input type="text" onfocus="parent.setCurrent(this);" name="did/physdesc/extent" id="cae" size="80">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>

  <xsl:template match="did/origination">
  	<input type="text" onfocus="parent.setCurrent(this);" name="did/origination" id="cba" size="80">
  		<xsl:attribute name="value">
  			<xsl:value-of select="."/>
  		</xsl:attribute>
  	</input>
  </xsl:template>

 <xsl:template match="bioghist">
  	<textarea name="bioghist" id="cbb" onfocus="parent.setCurrent(this);" rows="5" cols="80">  		
		<xsl:value-of select="."/>  		  		
  	</textarea>
  </xsl:template>

  <xsl:template match="custodhist">
  		<strong><span class="isadg">3.2.3: </span>Archival History </strong> <a class="smalllink" id="linkcbc" title="add archival history" onclick="addElement('cbc')">hide</a> [optional]
		<br/>
  	  	<textarea name="custodhist" id="cbc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>

  <xsl:template match="acqinfo">
  		<strong><span class="isadg">3.2.4: </span>Immediate Source of Acquisition </strong> <a class="smalllink" id="linkcbd" title="add archival history" onclick="addElement('cbd')">hide</a> [optional]
		<br/>
  	  	<textarea name="acqinfo" id="cbd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>

    <xsl:template match="scopecontent">
  	  <textarea name="scopecontent" id="cca" onfocus="parent.setCurrent(this);" rows="5" cols="80">
  	  	<xsl:value-of select="."/>
  	  </textarea>
   </xsl:template>

  <xsl:template match="appraisal">
  		<strong><span class="isadg">3.3.2: </span>Appraisal </strong> <a class="smalllink" id="linkccb" title="add archival history" onclick="addElement('ccb')">hide</a> [optional]
		<br/>
  	  	<textarea name="appraisal" id="ccb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>
 
 <xsl:template match="accruals">
  		<strong><span class="isadg">3.3.3: </span>Accruals </strong> <a class="smalllink" id="linkccc" title="add archival history" onclick="addElement('ccc')">hide</a> [optional]
		<br/>
  	  	<textarea name="accruals" id="ccc" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>

  <xsl:template match="arrangement">
  		<strong><span class="isadg">3.3.4: </span>System of Arrangement </strong> <a class="smalllink" id="linkccd" title="add archival history" onclick="addElement('ccd')">hide</a> [optional]
		<br/>
  	  	<textarea name="arrangement" id="ccd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>

  <xsl:template match="accessrestrict">
  	  <textarea name="accessrestrict" id="cca" onfocus="parent.setCurrent(this);" rows="5" cols="80">
  	  	<xsl:value-of select="."/>
  	  </textarea>
   </xsl:template>
   
   <xsl:template match="userestrict">
  		<strong><span class="isadg">3.4.2: </span>Conditions Governing Reproduction </strong> <a class="smalllink" id="linkcdb" title="add archival history" onclick="addElement('cdb')">hide</a> [optional]
		<br/>
  	  	<textarea name="userestrict" id="cdb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
  		<xsl:value-of select="."/>
  	  </textarea>
  </xsl:template>

  <xsl:template match="langmaterial">
	<div id="addedlanguages" style="display:block" class="added">
		<xsl:for-each select="language">
			<input type="hidden" name="language">
				<xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>xml</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:text>&lt;language langcode="</xsl:text><xsl:value-of select="@langcode"/><xsl:text>"&gt;</xsl:text>
					<xsl:value-of select="."/><xsl:text>&lt;/language&gt;</xsl:text>
				</xsl:attribute>
			</input>
			<div>
				<xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/>				
				</xsl:attribute>			
				<div class="icons">
					<a>
						<xsl:attribute name="onclick">
							<xsl:text>deleteaccesspoint('language_formgen</xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>');</xsl:text>
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
					<a>
						<xsl:attribute name="onclick">
							<xsl:text>editaccesspoint('language_formgen', </xsl:text><xsl:number level="single" count="language" format="1"/><xsl:text>);</xsl:text>
						</xsl:attribute>
						<xsl:text>edit</xsl:text>
					</a>										
				</div>
				<div class="accesspoint">
					<xsl:value-of select="@langcode"/><xsl:text> | </xsl:text><xsl:value-of select="."/><xsl:text> |</xsl:text>
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

  <xsl:template match="phystech">
    <strong><span class="isadg">3.4.4: </span>Physical Characteristics </strong> <a class="smalllink" id="linkcdd" title="add physical characteristics" onclick="addElement('cdd')">hide</a> [optional]
	<br/>
	<textarea name="phystech" id="cdd" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:block">
			<xsl:value-of select="."/>
	</textarea>
  </xsl:template>

  <xsl:template match="otherfindaid">
  	<textarea name="cde" id="cde" onfocus="parent.setCurrent(this);" rows="5" cols="80">
  		<xsl:value-of select="."/>
  	</textarea>
  </xsl:template>
  
  <xsl:template match="originalsloc">
  	<strong><span class="isadg">3.5.1: </span>Existence/Location of Originals </strong> <a class="smalllink" id="linkcea" title="add archival history" onclick="addElement('cea')">hide</a> [optional]
	<br/>
    <textarea  name="originalsloc" id="cea" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none">
    	<xsl:value-of select="."/>
    </textarea>
  </xsl:template>
  
  <xsl:template match="altformavail">
	<strong><span class="isadg">3.5.2: </span>Existence/Location of Copies </strong> <a class="smalllink" id="linkceb" title="add archival history" onclick="addElement('ceb')">hide</a> [optional]
	<br/>
	<textarea name="altformavail" id="ceb" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none">
		<xsl:value-of select="."/>
	</textarea>  
  </xsl:template>
  
  <xsl:template match="relatedmaterial">
  	<strong><span class="isadg">3.5.3: </span>Related Units of Description </strong> <a class="smalllink" id="linkcec" title="add archival history" onclick="addElement('cec')">hide</a> [optional]
	<br/>
	<textarea name="relatedmaterial" id="cec" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none">
		<xsl:value-of select="."/>
	</textarea>
  </xsl:template>
  
  <xsl:template match="bibliography">
  	<strong><span class="isadg">3.5.4: </span>Publication Note</strong> [Works based on or about the collection] <a class="smalllink" id="linkced" title="add archival history" onclick="addElement('ced')">hide</a> [optional]
	<br/>
	<textarea name="bibliography" id="ced" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none">
		<xsl:value-of select="."/>
	</textarea>
  </xsl:template>
  
  <xsl:template match="note">
  	<strong><span class="isadg">3.6.1: </span>Note </strong> <a class="smalllink" id="linkcfa" title="add archival history" onclick="addElement('cfa')">add</a> [optional]
	<br/>
	<textarea name="note" id="cfa" onfocus="parent.setCurrent(this);" rows="5" cols="80" style="display:none">
		<xsl:value-of select="."/>
	</textarea>
  </xsl:template>
  
  <xsl:template match="processinfo">
  	<textarea name="processinfo" id="cga" onfocus="parent.setCurrent(this);" rows="5" cols="80">
  		<xsl:value-of select="."/>
  	</textarea>
  </xsl:template>
  
  


  <xsl:template match="eadid">
	<input type="text" name="caa-cc" id="caa-cc" maxlength="2" size="3" disabled="true">
		<xsl:attribute name="value">
		    <xsl:choose>
		    	<xsl:when test="@countrycode">
		    	   <xsl:value-of select="@countrycode"/>
		    	</xsl:when>
		    	<xsl:otherwise>
		    	   <xsl:value-of select="substring($eadidstring, 1, 3)" />
		    	</xsl:otherwise>
		    </xsl:choose>					
		</xsl:attribute>
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="caa-rc" id="caa-rc" maxlength="4" size="5" disabled="true">
		<xsl:attribute name="value">
			<xsl:choose>
				<xsl:when test="@mainagencycode">
					<xsl:value-of select="@mainagencycode" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($eadidstring, 4, 5)" />
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:attribute>
	</input>
	<input type="text" onfocus="parent.setCurrent(this);" name="caa-id" id="caa-id" size="50" disabled="true">
		<xsl:attribute name="value">
			<xsl:value-of select="$eadidstring"/>
		</xsl:attribute>
	</input> 
  </xsl:template>
  
</xsl:stylesheet>


<!--   <xsl:template name="accesspointstring1">
  
  	 <xsl:param name="aptype"/>
  	 <xsl:param name="separater"/>
  	 <xsl:choose>
  	  	<xsl:when test="$aptype = 'subject' or $aptype = 'corpname'">
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='a']|emph[@altrender='subject']|emph[@altrender='corpname']">
	  	  			<xsl:apply-templates select="emph[@altrender='a']|emph[@altrender='subject']|emph[@altrender='corpname']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
			<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='y']|emph[@altrender='dates']">
	  	  			<xsl:apply-templates select="emph[@altrender='y']|emph[@altrender='dates']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='z']|emph[@altrender='loc']">
	  	  			<xsl:apply-templates select="emph[@altrender='z']|emph[@altrender='loc']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='x']|emph[@altrender='other']">
	  	  			<xsl:apply-templates select="emph[@altrender='x']|emph[@altrender='other']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@source and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@source"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@rules and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@rules"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  	</xsl:when>
  	  	<xsl:when test="$aptype = 'persname'">
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='surname']">
	  	  			<xsl:apply-templates select="emph[@altrender='surname']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='forename']">
	  	  			<xsl:apply-templates select="emph[@altrender='forename']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='y']|emph[@altrender='dates']">
	  	  			<xsl:apply-templates select="emph[@altrender='y']|emph[@altrender='dates']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='title']">
	  	  			<xsl:apply-templates select="emph[@altrender='title']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='epithet']">
	  	  			<xsl:apply-templates select="emph[@altrender='epithet']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='x']|emph[@altrender='other']">
	  	  			<xsl:apply-templates select="emph[@altrender='x']|emph[@altrender='other']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@source and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@source"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose> 	  
  	  		<xsl:choose>
	  	  		<xsl:when test="@rules and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@rules"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>		
  	  	</xsl:when>
  	  	<xsl:when test="$aptype = 'famname'">
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='surname']">
	  	  			<xsl:apply-templates select="emph[@altrender='surname']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='x']|emph[@altrender='other']">
	  	  			<xsl:apply-templates select="emph[@altrender='x']|emph[@altrender='other']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='y']|emph[@altrender='dates']">
	  	  			<xsl:apply-templates select="emph[@altrender='y']|emph[@altrender='dates']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='title']">
	  	  			<xsl:apply-templates select="emph[@altrender='title']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='epithet']">
	  	  			<xsl:apply-templates select="emph[@altrender='epithet']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='z']|emph[@altrender='loc']">
	  	  			<xsl:apply-templates select="emph[@altrender='z']|emph[@altrender='loc']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@source and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@source"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose> 	  
  	  		<xsl:choose>
	  	  		<xsl:when test="@rules and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@rules"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>	
  	  	</xsl:when>
  	  	<xsl:when test="$aptype = 'geogname'">
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='z']|emph[@altrender='loc']">
	  	  			<xsl:apply-templates select="emph[@altrender='z']|emph[@altrender='loc']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='y']|emph[@altrender='dates']">
	  	  			<xsl:apply-templates select="emph[@altrender='y']|emph[@altrender='dates']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@source and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@source"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose> 
  	  		<xsl:choose>
	  	  		<xsl:when test="@rules and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@rules"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>	  
  	  	</xsl:when>
  	  	<xsl:when test="$aptype = 'title'">
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='a']|emph[@altrender='title']">
	  	  			<xsl:apply-templates select="emph[@altrender='a']|emph[@altrender='title']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="emph[@altrender='y']|emph[@altrender='dates']">
	  	  			<xsl:apply-templates select="emph[@altrender='y']|emph[@altrender='dates']"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>
  	  		<xsl:choose>
	  	  		<xsl:when test="@source and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@source"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose> 
  	  		<xsl:choose>
	  	  		<xsl:when test="@rules and $separater=' ||| '">
	  	  			<xsl:apply-templates select="@rules"/>  	 
	  	  			<xsl:value-of select="$separater"/> 				
	  	  		</xsl:when>
	  	  		<xsl:otherwise>
	  	  			<xsl:value-of select="$separater"/> 
	  	  		</xsl:otherwise>
  	  		</xsl:choose>	 
  	  	</xsl:when>
  	  </xsl:choose>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='a']|emph[@altrender='title']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='a']|emph[@altrender='subject']|emph[@altrender='corpname']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='y']|emph[@altrender='dates']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='z']|emph[@altrender='loc']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="@source">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='x']|emph[@altrender='other']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='surname']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='title']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='forename']">
  	<xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="emph[@altrender='epithet']">
  	<xsl:value-of select="."/>
  </xsl:template>-->