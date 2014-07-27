<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet []>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <!--
    This file was produced, and released as part of Cheshire for Archives
    v3.x. Adapted for use in the Archives Hub EAD Editor. Copyright &#169;
    2005-2013 the University of Liverpool
    -->


    <xsl:import href="contents-editing.xsl" />

    <xsl:output method="xml" omit-xml-declaration="yes"
        encoding="UTF-8" />
    <xsl:preserve-space elements="*" />

    <xsl:variable name="eadidstring">
        <xsl:value-of select="/ead/eadheader/eadid/text()" />
    </xsl:variable>

    <xsl:variable name="formtype">
        <xsl:choose>
            <xsl:when test="/template">
                <xsl:text>template</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>ead</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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
                <xsl:value-of select="/*/@level" />
            </xsl:when>
            <xsl:when test="//archdesc/@level">
                <xsl:value-of select="//archdesc/@level" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template name="addButton">
        <xsl:element name="img">
            <xsl:attribute name="src">
            <xsl:text>/images/structure/form_add_row.png</xsl:text>
        </xsl:attribute>
            <xsl:attribute name="alt">
            <xsl:text>[+]</xsl:text>
        </xsl:attribute>
            <xsl:attribute name="title">
            <xsl:text>Add another</xsl:text>
        </xsl:attribute>
        </xsl:element>
    </xsl:template>


    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$formtype = 'ead'">
                <div id="formDiv" name="form" class="formDiv">
                    <form id="eadForm" name="eadForm" action="#">
                        <div class="float">
                            <input type="button" class="formbutton" id="addC"
                                onclick="javascript: addComponent()" value="Add Component"
                                title="Add a component to this level of the record"></input>
                        </div>
                        <!--
                            <div class="float"> <input type="button"
                            class="formbutton" id="reset" onclick="javascript:
                            resetForm()" value="Reset"></input> </div>
                        -->
                        <div class="pui">
                            <strong>
                                <xsl:text>Persistent Unique Identifier</xsl:text>
                            </strong>
                            <a
                                href="http://archiveshub.ac.uk/identifiers/"
                                title="PUI help - opens in new window" class="tip"
                                target="_new">
                                <img src="/images/structure/form_tip.png"
                                    alt="[?]" />
                            </a>
                            %PUI%
                        </div>

                        <br />
                        <div class="section">
                            <xsl:choose>
                                <xsl:when test="/ead/eadheader">
                                    <h3>Collection Level Description</h3>
                                    %RECID%
                                    <xsl:apply-templates
                                        select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <h3>Component Level Description</h3>
                                    <xsl:apply-templates
                                        select="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </form>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="formDiv" name="form" class="formDiv">
                    <form id="eadForm" name="eadForm" action="#">
                        <h3>EAD Template Creation</h3>
                        %PUI%

                        <b>Template Name: </b>
                        <xsl:choose>
                            <xsl:when test="/template/@name">
                                <input type="text" id="/template/@name"
                                    name="/template/@name">
                                    <xsl:attribute name="value">
									<xsl:value-of select="/template/@name" />
								</xsl:attribute>
                                    <input type="hidden" id="tempid">
                                        <xsl:attribute
                                            name="value">
										<xsl:value-of select="/template/@name" />
									</xsl:attribute>
                                    </input>
                                </input>
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="text" id="/template/@name"
                                    name="/template/@name"></input>
                                <input type="hidden" id="tempid"
                                    value="notSet" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="/template/ead/archdesc" />
                    </form>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template
        match="/c|/c01|/c02|/c03|/c04|/c05|/c06|/c07|/c08|/c09|/c10|/c11|/c12|/ead/archdesc|/template/ead/archdesc">
        <xsl:if test="not(name() = 'archdesc')">
            <p>
                <input type="hidden" name="ctype" id="ctype"
                    maxlength="3" size="4">
                    <xsl:attribute name="value">
   				<xsl:value-of select="name()" />   					
 			</xsl:attribute>
                </input>
            </p>
        </xsl:if>
        <div id="sec-3-1" class="section">
            <span class="isadg">
                <h3>3.1: Identity Statement Area</h3>
            </span>
            <xsl:if test="$formtype = 'ead'">
                <p id="unitidparent">
                    <strong>
                        <span class="isadg">3.1.1: </span>
                        Reference Code
                    </strong>
                    <a href="http://archiveshub.ac.uk/help/refcode"
                        class="tip" title="Reference Code help - opens in new window"
                        target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    Comprising
                    <a
                        href="http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm"
                        target="_new" title="Further information on ISO Country Codes">
                        ISO Country Code
		            </a>
                    ,
                    <a href="http://www.nationalarchives.gov.uk/archon/"
                        target="_new" title="ARCHON Service">Archon Code</a>
                    ,
                    and a unique identifier for this record or component.
                    <xsl:if test="$leveltype = 'collection'">
                        [
                        <strong>all fields required</strong>
                        ]
                    </xsl:if>
                </p>
                <xsl:choose>
                    <xsl:when test="did/unitid">
                        <xsl:for-each select="did/unitid">
                            <xsl:call-template name="unitid">
                                <xsl:with-param name="node"
                                    select="." />
                                <xsl:with-param name="position"
                                    select="position()" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="clear">
                            <div class="float">
                                <input type="text" onfocus="setCurrent(this);"
                                    name="did/unitid[1]/@countrycode" id="countrycode[1]"
                                    maxlength="2" size="3" value="GB" onblur="updateId();"></input>
                                <input type="text" onfocus="setCurrent(this);"
                                    name="did/unitid[1]/@repositorycode" id="archoncode[1]"
                                    maxlength="4" size="5" onblur="updateId();"></input>
                                <input type="text" onfocus="setCurrent(this);"
                                    name="did/unitid[1]" id="unitid[1]" size="40"
                                    onblur="updateId();"></input>
                                <select id="did/unitidlabel[1]" name="did/unitid[1]/@label">
                                    <option>
                                        <xsl:attribute name="value">
                                            <xsl:text>current</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="selected">
                                            <xsl:text>selected</xsl:text>
                                        </xsl:attribute>
                                        <xsl:text>current</xsl:text>
                                    </option>
                                    <option>
                                        <xsl:attribute name="value">
                       <xsl:text>former</xsl:text>
                   </xsl:attribute>
                                        <xsl:text>former</xsl:text>
                                    </option>
                                    <option>
                                        <xsl:attribute name="value">
                       <xsl:text>alternative</xsl:text>
                   </xsl:attribute>
                                        <xsl:text>alternative</xsl:text>
                                    </option>
                                </select>
                            </div> <!-- /.float -->
                        </div> <!-- /.clear -->
                    </xsl:otherwise>
                </xsl:choose>
                <span id="addUnitid">
                    <xsl:attribute name="onclick">
             <xsl:text>cloneField(this)</xsl:text>
         </xsl:attribute>
                    <xsl:call-template name="addButton" />
                </span>
                <div class="clear" />
            </xsl:if>
            <p>
                <strong>
                    <span class="isadg">3.1.2: </span>
                    Title
                </strong>
                <a href="http://archiveshub.ac.uk/help/title" class="tip"
                    title="Title help - opens in new window" target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
                <br />
                <xsl:choose>
                    <xsl:when test="did/unittitle">
                        <xsl:apply-templates select="did/unittitle" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$formtype = 'ead'">
                                <input class="menuField" type="text"
                                    onfocus="setCurrent(this);" name="did/unittitle"
                                    id="did/unittitle" size="60"
                                    onchange="updateTitle(this)"
                                    onkeypress="validateFieldDelay(this, 'true');"
                                    onblur="validateField(this, 'true');"></input>
                            </xsl:when>
                            <xsl:otherwise>
                                <input class="menuField" type="text"
                                    onfocus="setCurrent(this);" name="did/unittitle"
                                    id="did/unittitle" size="60"
                                    onchange="validateField(this, 'true');"
                                    onkeypress="validateFieldDelay(this, 'true');"
                                    onblur="validateField(this, 'true');"></input>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
            <xsl:choose>
                <xsl:when test="did/unitdate">
                    <xsl:for-each select="did/unitdate">
                        <xsl:call-template name="unitdate">
                            <xsl:with-param name="node" select="." />
                            <xsl:with-param name="path"
                                select="concat('did/unitdate[', position(), ']')" />
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="did/unittitle/unitdate">
                    <xsl:for-each select="did/unittitle/unitdate">
                        <xsl:call-template name="unitdate">
                            <xsl:with-param name="node" select="." />
                            <xsl:with-param name="path"
                                select="concat('did/unittitle/unitdate[', position(), ']')" />
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <div class="clear">
                        <div class="float">
                            <strong>
                                <span class="isadg">3.1.3: </span>
                                Dates of Creation
                            </strong>
                            <a href="http://archiveshub.ac.uk/help/dates"
                                class="tip"
                                title="Dates of Creation help - opens in new window"
                                target="_new">
                                <img src="/images/structure/form_tip.png"
                                    alt="[?]" />
                            </a>
                            <br />
                            <input class="menuField" type="text"
                                onfocus="setCurrent(this);"
                                onkeypress="validateFieldDelay(this, 'true');"
                                onchange="validateField(this, 'true');"
                                onblur="validateField(this, 'true');"
                                name="did/unitdate[1]" id="did/unitdate[1]"
                                size="29"></input>
                        </div>
                        <div class="float">
                            <strong>
                                <xsl:text>Normalised Date</xsl:text>
                            </strong>
                            <a href="http://archiveshub.ac.uk/help/dates"
                                class="tip"
                                title="Normalised Date help - opens in new window"
                                target="_new">
                                <img src="/images/structure/form_tip.png"
                                    alt="[?]" />
                            </a>
                            YYYY/YYYY or YYYYMMDD/YYYYMMDD
                            <br />
                            <input class="dateOK" type="text"
                                onfocus="setCurrent(this);"
                                onkeypress="validateNormdateDelay(this, 'true');"
                                onchange="validateNormdate(this, 'true');"
                                onblur="validateNormdate(this, 'true');"
                                name="did/unitdate[1]/@normal" id="did/unitdate[1]/@normal"
                                size="29" maxlength="21"></input>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
            <span id="addUnitdate">
                <xsl:attribute name="onclick">
             <xsl:text>cloneField(this)</xsl:text>
         </xsl:attribute>
                <xsl:call-template name="addButton" />
            </span>
            <br />
            <p>
                <!-- <xsl:if test="$leveltype = 'component'"> -->
                <strong>
                    <span class="isadg">3.1.4: </span>
                    Level of Description
                </strong>
                <a href="http://archiveshub.ac.uk/help/level" class="tip"
                    title="Level of Description help - opens in new window"
                    target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
                <xsl:if test="$leveltype = 'collection'">
                    <xsl:text>[mandatory]</xsl:text>
                </xsl:if>
                <br />
                <select name="@level" id="@level">
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="''" />
                        <xsl:with-param name="label"
                            select="'none'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'fonds'" />
                        <xsl:with-param name="label"
                            select="'fonds'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'collection'" />
                        <xsl:with-param name="label"
                            select="'collection'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'class'" />
                        <xsl:with-param name="label"
                            select="'class'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'series'" />
                        <xsl:with-param name="label"
                            select="'series'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'subfonds'" />
                        <xsl:with-param name="label"
                            select="'subfonds'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'subseries'" />
                        <xsl:with-param name="label"
                            select="'subseries'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'file'" />
                        <xsl:with-param name="label"
                            select="'file'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'item'" />
                        <xsl:with-param name="label"
                            select="'item'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                    <xsl:call-template name="option">
                        <xsl:with-param name="value"
                            select="'otherlevel'" />
                        <xsl:with-param name="label"
                            select="'otherlevel'" />
                        <xsl:with-param name="select"
                            select="$level" />
                    </xsl:call-template>
                </select>
                <!-- </xsl:if> -->
            </p>
            <p>
                <strong>
                    <span class="isadg">3.1.5: </span>
                    Extent of Unit of Description
                </strong>
                <a href="http://archiveshub.ac.uk/help/extent" class="tip"
                    title="Extent help - opens in new window"
                    target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
                <br />
                <xsl:choose>
                    <xsl:when test="did/physdesc/extent">
                        <xsl:for-each select="did/physdesc/extent">
                            <xsl:call-template name="textfield">
                                <xsl:with-param name="name"
                                    select="concat('did/physdesc/extent[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <input class="menuField" type="text"
                            onfocus="setCurrent(this);" onkeypress="validateFieldDelay(this, 'true');"
                            onchange="validateField(this, 'true');"
                            onblur="validateField(this, 'true');"
                            name="did/physdesc/extent[1]" id="did/physdesc/extent[1]"
                            size="60"></input>
                    </xsl:otherwise>
                </xsl:choose>
                <span id="addExtent">
                    <xsl:attribute name="onclick">
                        <xsl:text>cloneField(this)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="addButton" />
                </span>
            </p>
            <xsl:if
                test="$leveltype = 'collection' or $formtype = 'template'">
                <p>
                    <strong>Repository</strong>
                    <a href="http://archiveshub.ac.uk/help/repository"
                        id="repositoryhelp" name="repositoryhelp" class="tip"
                        target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <xsl:choose>
                        <xsl:when test="did/repository">
                            <xsl:apply-templates
                                select="did/repository" />
                        </xsl:when>
                        <xsl:otherwise>
                            <input class="menuField" type="text"
                                onfocus="setCurrent(this);"
                                onkeypress="validateFieldDelay(this, 'true');"
                                onchange="validateField(this, 'true');"
                                onblur="validateField(this, 'true');"
                                name="did/repository" id="did/repository"
                                size="60"></input>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
                <p>
                    <xsl:choose>
                        <xsl:when
                            test="../eadheader/filedesc/titlestmt/sponsor">
                            <xsl:apply-templates
                                select="../eadheader/filedesc/titlestmt/sponsor" />
                        </xsl:when>
                        <xsl:otherwise>
                            <strong>Sponsor</strong>
                            <a href="http://archiveshub.ac.uk/help/sponsor"
                                class="tip" id="sponsorhelp" name="sponsorhelp"
                                target="_new">
                                <img src="/images/structure/form_tip.png"
                                    alt="[?]" />
                            </a>
                            <a class="smalllink" id="linkfiledesc/titlestmt/sponsor"
                                title="add sponsor"
                                onclick="addElement('filedesc/titlestmt/sponsor')">add content</a>
                            [optional]
                            <br />
                            <input class="menuField" type="text"
                                onkeypress="validateFieldDelay(this, 'true');"
                                onchange="validateField(this, 'true');"
                                onblur="validateField(this, 'true');"
                                onfocus="setCurrent(this);" name="filedesc/titlestmt/sponsor"
                                id="filedesc/titlestmt/sponsor"
                                size="60" style="display:none"></input>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:if>
        </div>
        <!-- -->
        <!-- CONTEXT -->
        <!-- -->
        <div class="section">
            <span class="isadg">
                <h3>3.2: Context Area</h3>
            </span>
            <div class="subsection">
                <strong>
                    <span class="isadg">3.2.1: </span>
                    Name of Creator
                </strong>
                <a href="http://archiveshub.ac.uk/help/name" class="tip"
                    title="Name of Creator help - opens in new window" target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                [
                <strong>
                    also add manually as
                    <a href="#accesspoints" title="Add Access Point manually">Access Point</a>
                </strong>
                ]
                <br />
                <xsl:choose>
                    <xsl:when test="did/origination">
                        <xsl:for-each select="did/origination">
                            <xsl:call-template name="origination">
                                <xsl:with-param name="node"
                                    select="." />
                                <xsl:with-param name="position"
                                    select="position()" />
                            </xsl:call-template>
                        </xsl:for-each>
                        <!--                    <xsl:apply-templates select="did/origination"/>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="input-name-prefix">
                            <xsl:text>did/origination[1]</xsl:text>
                        </xsl:variable>
                        <div class="clear">
                            <div class="float">

                                <xsl:call-template name="originationTypeSelect">
                                    <xsl:with-param name="input-name-prefix" select="$input-name-prefix"/>
                                    <xsl:with-param name="position" select="1"/>
                                    <xsl:with-param name="localname">
                                        <xsl:text>origination</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>

                                <input class="menuField" type="text" onfocus="setCurrent(this);"
                                    onkeypress="validateFieldDelay(this, 'true');"
                                    onchange="validateField(this, 'true');"
                                    onblur="validateField(this, 'true');"
                                    size="48">
                                    <xsl:attribute name="name">
                                        <xsl:value-of select="$input-name-prefix" />
                                    </xsl:attribute>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="$input-name-prefix" />
                                    </xsl:attribute>
                                </input>
                            </div> <!-- /.float -->
                        </div> <!-- /.clear -->
                    </xsl:otherwise>
                </xsl:choose>
                <span id="addOrigination">
                    <xsl:attribute name="onclick">
                        <xsl:text>cloneField(this); initCreatorSelect()</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="addButton" />
                </span>
            </div> <!-- /.subsection -->
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
                                <xsl:with-param name="name"
                                    select="concat('bioghist[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'false'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.2.2: '" />
                                <xsl:with-param name="title"
                                    select="'Administrative/Biographical History'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/bioghist'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('bioghist[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'false'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.2.2: '" />
                            <xsl:with-param name="title"
                                select="'Administrative/Biographical History'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/bioghist'" />
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
                                <xsl:with-param name="name"
                                    select="concat('custodhist[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.2.3: '" />
                                <xsl:with-param name="title"
                                    select="'Archival History'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/custodhist '" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('custodhist[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.2.3: '" />
                            <xsl:with-param name="title"
                                select="'Archival History'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/custodhist'" />
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
                                <xsl:with-param name="name"
                                    select="concat('acqinfo[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.2.4: '" />
                                <xsl:with-param name="title"
                                    select="'Immediate Source of Acquisition'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/acqinfo'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('acqinfo[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.2.4: '" />
                            <xsl:with-param name="title"
                                select="'Immediate Source of Acquisition'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/acqinfo'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </div>
        <!-- -->
        <!-- CONTENT AND STRUCTURE -->
        <!-- -->
        <div class="section">
            <span class="isadg">
                <h3>3.3: Content and Structure Area</h3>
            </span>
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
                                <xsl:with-param name="name"
                                    select="concat('scopecontent[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'false'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.3.1: '" />
                                <xsl:with-param name="title"
                                    select="'Scope and Content'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/scope'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('scopecontent[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'false'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.3.1: '" />
                            <xsl:with-param name="title"
                                select="'Scope and Content'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/scope'" />
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
                                <xsl:with-param name="name"
                                    select="concat('appraisal[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.3.2: '" />
                                <xsl:with-param name="title"
                                    select="'Appraisal'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/appraisal'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('appraisal[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.3.2: '" />
                            <xsl:with-param name="title"
                                select="'Appraisal'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/appraisal'" />
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
                                <xsl:with-param name="name"
                                    select="concat('accruals[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.3.3: '" />
                                <xsl:with-param name="title"
                                    select="'Accruals'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/accruals'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('accruals[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.3.3: '" />
                            <xsl:with-param name="title"
                                select="'Accruals'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/accruals'" />
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
                                <xsl:with-param name="name"
                                    select="concat('arrangement[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.3.4: '" />
                                <xsl:with-param name="title"
                                    select="'System of Arrangement'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/arrangement'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('arrangement[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.3.4: '" />
                            <xsl:with-param name="title"
                                select="'System of Arrangement'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/arrangement'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </div>
        <!-- -->
        <!-- ACCESS -->
        <!-- -->
        <div class="section">
            <span class="isadg">
                <h3>3.4: Conditions of Access and Use Area</h3>
            </span>
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
                                <xsl:with-param name="name"
                                    select="concat('accessrestrict[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'false'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.4.1: '" />
                                <xsl:with-param name="title"
                                    select="'Conditions Governing Access'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/restrict'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('accessrestrict[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'false'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.4.1: '" />
                            <xsl:with-param name="title"
                                select="'Conditions Governing Access'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/restrict'" />
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
                                <xsl:with-param name="name"
                                    select="concat('userestrict[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.4.2: '" />
                                <xsl:with-param name="title"
                                    select="'Conditions Governing Reproduction'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/userestrict'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('userestrict[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.4.2: '" />
                            <xsl:with-param name="title"
                                select="'Conditions Governing Reproduction'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/userestrict'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
            <!-- langmaterial -->
            <p>
                <strong>
                    <span class="isadg">3.4.3: </span>
                    Language of Material
                </strong>
                <a href="http://archiveshub.ac.uk/help/lang"
                    title="Language of Material help - opens in new window"
                    target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
                [Must include
                <a
                    href="http://www.loc.gov/standards/iso639-2/php/English_list.php"
                    title="ISO 639-2 codes - opens new window" target="_new">ISO
                    639-2 3-letter code</a>
                ]
                <xsl:for-each select="did/langmaterial/@*">
                    <input type="hidden">
                        <xsl:attribute name="name">
     				<xsl:text>did/langmaterial/@</xsl:text><xsl:value-of
                            select="name()" />
     			</xsl:attribute>
                        <xsl:attribute name="value">
     				<xsl:value-of select="." />
     			</xsl:attribute>
                    </input>
                </xsl:for-each>
                <div id="language" class="langcontainer">
                    <xsl:choose>
                        <xsl:when test="did/langmaterial/language">
                            <xsl:apply-templates
                                select="did/langmaterial" />
                        </xsl:when>
                        <xsl:otherwise>
                            <div id="addedlanguages" style="display:none"
                                class="added">
                                <xsl:text> </xsl:text>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    <div id="languagetable" class="tablecontainer">
                        <table>
                            <tbody>
                                <tr>
                                    <td> 3-letter ISO code:</td>
                                    <td>
                                        <input type="text" id="lang_code"
                                            onfocus="setCurrent(this);"
                                            maxlength="3" size="5"></input>
                                    </td>
                                </tr>
                                <tr>
                                    <td> Language:</td>
                                    <td>
                                        <input type="text" id="lang_name"
                                            onfocus="setCurrent(this);"
                                            size="35"></input>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div id="languagebuttons" class="buttoncontainer">
                        <input class="apbutton" type="button"
                            onclick="addLanguage();" value="Add to Record"></input>
                        <br />
                        <input class="apbutton" type="button"
                            onclick="resetAccessPoint('language');"
                            value="Reset"></input>
                    </div>
                </div>
                <br />
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
                                <xsl:with-param name="name"
                                    select="concat('phystech[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.4.4: '" />
                                <xsl:with-param name="title"
                                    select="'Physical Characteristics'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/phystech'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('phystech[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.4.4: '" />
                            <xsl:with-param name="title"
                                select="'Physical Characteristics'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/phystech'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
            <!-- otherfindaid -->
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
                                <xsl:with-param name="name"
                                    select="concat('otherfindaid[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'false'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.4.5: '" />
                                <xsl:with-param name="title"
                                    select="'Finding Aids'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/other'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('otherfindaid[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'false'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.4.5: '" />
                            <xsl:with-param name="title"
                                select="'Finding Aids'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/other'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
            <!-- prefercite -->
            <p>
                <xsl:variable name="content">
                    <xsl:choose>
                        <xsl:when test="prefercite">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>false</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$content = 'true'">
                        <xsl:for-each select="prefercite">
                            <xsl:call-template name="textarea">
                                <xsl:with-param name="name"
                                    select="concat('prefercite[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="title"
                                    select="'Preferred Citation'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/preferredcitation'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('prefercite[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="title"
                                select="'Preferred Citation'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/preferredcitation'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>

        </div>
        <!-- -->
        <!-- ALLIED MATERIALS -->
        <!-- -->
        <div class="section">
            <span class="isadg">
                <h3>3.5: Allied Materials Area</h3>
            </span>
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
                                <xsl:with-param name="name"
                                    select="concat('originalsloc[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.5.1: '" />
                                <xsl:with-param name="title"
                                    select="'Existence/Location of Originals'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/originalsloc'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('originalsloc[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.5.1: '" />
                            <xsl:with-param name="title"
                                select="'Existence/Location of Originals'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/originalsloc'" />
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
                                <xsl:with-param name="name"
                                    select="concat('altformavail[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.5.2: '" />
                                <xsl:with-param name="title"
                                    select="'Existence/Location of Copies'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/altformavail'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('altformavail[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.5.2: '" />
                            <xsl:with-param name="title"
                                select="'Existence/Location of Copies'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/altformavail'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
            <span class="isadg">
                <h4>3.5.3: Related Units of Description</h4>
            </span>
            <!-- separatedmaterial -->
            <p>
                <xsl:variable name="content">
                    <xsl:choose>
                        <xsl:when test="separatedmaterial">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>false</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$content = 'true'">
                        <xsl:for-each select="separatedmaterial">
                            <xsl:call-template name="textarea">
                                <xsl:with-param name="name"
                                    select="concat('separatedmaterial[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.5.3a: '" />
                                <xsl:with-param name="title"
                                    select="'Separated Material'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/separatedmaterial'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('separatedmaterial[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.5.3a: '" />
                            <xsl:with-param name="title"
                                select="'Separated Material'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/separatedmaterial'" />
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
                                <xsl:with-param name="name"
                                    select="concat('relatedmaterial[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.5.3b: '" />
                                <xsl:with-param name="title"
                                    select="'Related Material'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/relatedmaterial'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('relatedmaterial[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.5.3b: '" />
                            <xsl:with-param name="title"
                                select="'Related Material'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/relatedmaterial'" />
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
                                <xsl:with-param name="name"
                                    select="concat('bibliography[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.5.4: '" />
                                <xsl:with-param name="title"
                                    select="'Publication Note'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/bibliography'" />
                                <xsl:with-param name="additional"
                                    select="'[Works based on or about the collection]'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('bibliography[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.5.4: '" />
                            <xsl:with-param name="title"
                                select="'Publication Note'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/bibliography'" />
                            <xsl:with-param name="additional"
                                select="'[Works based on or about the collection]'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </div>
        <!-- -->
        <!-- NOTE AREA -->
        <!-- -->
        <div class="section">
            <span class="isadg">
                <h3>3.6: Note Area</h3>
            </span>
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
                                <xsl:with-param name="name"
                                    select="concat('note[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'true'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.6.1: '" />
                                <xsl:with-param name="title"
                                    select="'Note'" />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/note'" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="textarea">
                            <xsl:with-param name="name"
                                select="concat('note[', position(), ']')" />
                            <xsl:with-param name="class"
                                select="'menuField'" />
                            <xsl:with-param name="optional"
                                select="'true'" />
                            <xsl:with-param name="content"
                                select="$content" />
                            <xsl:with-param name="isadg"
                                select="'3.6.1: '" />
                            <xsl:with-param name="title"
                                select="'Note'" />
                            <xsl:with-param name="help"
                                select="'http://archiveshub.ac.uk/help/note'" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </div>
        <!-- -->
        <!-- DESCRIPTION AREA -->
        <!-- -->
        <xsl:if test="$leveltype = 'collection'">
            <div class="section">
                <span class="isadg">
                    <h3>3.7: Description Area</h3>
                </span>
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
                                <xsl:call-template
                                    name="textarea">
                                    <xsl:with-param name="name"
                                        select="concat('processinfo[', position(), ']')" />
                                    <xsl:with-param name="class"
                                        select="'menuField'" />
                                    <xsl:with-param name="optional"
                                        select="'false'" />
                                    <xsl:with-param name="content"
                                        select="$content" />
                                    <xsl:with-param name="isadg"
                                        select="'3.7.1: '" />
                                    <xsl:with-param name="title"
                                        select='"Archivist&apos;s Note"' />
                                    <xsl:with-param name="help"
                                        select="'http://archiveshub.ac.uk/help/archnote'" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="textarea">
                                <xsl:with-param name="name"
                                    select="concat('processinfo[', position(), ']')" />
                                <xsl:with-param name="class"
                                    select="'menuField'" />
                                <xsl:with-param name="optional"
                                    select="'false'" />
                                <xsl:with-param name="content"
                                    select="$content" />
                                <xsl:with-param name="isadg"
                                    select="'3.7.1: '" />
                                <xsl:with-param name="title"
                                    select='"Archivist&apos;s Note"' />
                                <xsl:with-param name="help"
                                    select="'http://archiveshub.ac.uk/help/archnote'" />
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </div>
        </xsl:if>
        <!-- -->
        <!-- -->
        <!-- -->
        <!-- DIGITAL OBJECTS -->
        <div id="digitalobjectssection" class="section">
            <h3>
                Digital Objects
                <a href="http://archiveshub.ac.uk/help/dao" class="tip"
                    id="daohelp" name="daohelp" target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
            </h3>
            <div id="daocontainer">
                <!-- Digital Object not in did -->
                <xsl:if test="dao">
                    <xsl:for-each select="dao">
                        <xsl:choose>
                            <xsl:when test="@show='embed'">
                                <div class="embed">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdao</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Display image</b>
                                    <xsl:call-template
                                        name="dao">
                                        <xsl:with-param
                                            name="type" select="'embed'" />
                                        <xsl:with-param
                                            name="number" select="position()" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdao</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="new">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdao</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Link to file</b>
                                    <xsl:call-template
                                        name="dao">
                                        <xsl:with-param
                                            name="type" select="'new'" />
                                        <xsl:with-param
                                            name="number" select="position()" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdao</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="daogrp">
                    <xsl:for-each select="daogrp">
                        <xsl:choose>
                            <xsl:when test="daoloc/@role='thumb'">
                                <div class="thumb">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxgrp</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Thumbnail link to file</b>
                                    <xsl:call-template
                                        name="thumb">
                                        <xsl:with-param
                                            name="number" select="position()" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxgrp</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="multiple">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxgrp</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Link to multiple files</b>
                                    <xsl:call-template
                                        name="multiple">
                                        <xsl:with-param
                                            name="number" select="position()" />
                                        <xsl:with-param
                                            name="form" select="'daogrp'" />
                                        <xsl:with-param
                                            name="path" select="''" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxgrp</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                <!-- DAO in did -->
                <xsl:if test="did/dao">
                    <xsl:for-each select="did/dao">
                        <xsl:choose>
                            <xsl:when test="@show='embed'">
                                <div class="embed">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdiddao</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Display image</b>
                                    <xsl:call-template
                                        name="dao">
                                        <xsl:with-param
                                            name="type" select="'embed'" />
                                        <xsl:with-param
                                            name="number" select="position()" />
                                        <xsl:with-param
                                            name="path" select="'did'" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdiddao</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="new">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdiddao</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Link to file</b>
                                    <xsl:call-template
                                        name="dao">
                                        <xsl:with-param
                                            name="type" select="'new'" />
                                        <xsl:with-param
                                            name="number" select="position()" />
                                        <xsl:with-param
                                            name="form" select="'dao'" />
                                        <xsl:with-param
                                            name="path" select="'did'" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdiddao</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="did/daogrp">
                    <xsl:for-each select="did/daogrp">
                        <xsl:choose>
                            <xsl:when test="daoloc/@role='thumb'">
                                <div class="thumb">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdidgrp</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Thumbnail link to file</b>
                                    <xsl:call-template
                                        name="thumb">
                                        <xsl:with-param
                                            name="number" select="position()" />
                                        <xsl:with-param
                                            name="path" select="'did'" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdidgrp</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="multiple">
                                    <xsl:attribute name="id">
									<xsl:text>daoformxdidgrp</xsl:text><xsl:value-of
                                        select="position()" />
								</xsl:attribute>
                                    <b>Link to multiple files</b>
                                    <xsl:call-template
                                        name="multiple">
                                        <xsl:with-param
                                            name="number" select="position()" />
                                        <xsl:with-param
                                            name="form" select="'daogrp'" />
                                        <xsl:with-param
                                            name="path" select="'did'" />
                                    </xsl:call-template>
                                    <input type="button" value="Delete">
                                        <xsl:attribute
                                            name="onclick">
										<xsl:text>deleteDao('daoformxdidgrp</xsl:text><xsl:value-of
                                            select="position()" /><xsl:text>')</xsl:text>
									</xsl:attribute>
                                    </input>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>


                <div id="createnewdao">
                    <span>Add new DAO  </span>
                    <select name="daoselect" id="daoselect">
                        <option value="null">Select...</option>
                        <option value="new">Link to file</option>
                        <option value="embed">Display image</option>
                        <option value="thumb">Display thumbnail link to
                            file</option>
                        <option value="multiple">Link to multiple files
                        </option>
                    </select>
                    <input type="button" value="Create" onclick="createDaoForm()" />
                </div>
            </div>
        </div>
        <!-- -->
        <!-- -->
        <!-- ACCESSPOINTS -->
        <!-- -->
        <div id="accesspointssection" class="section">
            <h3>
                Access Points
                <a href="http://archiveshub.ac.uk/help/access" class="tip"
                    id="accesspoints" name="accesspoints" target="_new">
                    <img src="/images/structure/form_tip.png" alt="[?]" />
                </a>
            </h3>

            <!-- subject -->
            <div id="subject" class="apcontainer">
                <p>
                    <strong>Subject</strong>
                    <a href="http://archiveshub.ac.uk/help/subject"
                        class="tip" id="subjecthelp" name="subjecthelp"
                        target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!-- <a class="extSearch" onclick="window.open('http://databases.unesco.org/thesaurus/', 
                        'new');">[Search UNESCO]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://databases.unesco.org/thesaurus/">[Search UNESCO]</a>
                    <xsl:text>  </xsl:text>
                    <!-- <a class="extSearch" onclick="window.open('http://authorities.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;PAGE=First', 
                        'new');">[Search LCSH]</a></p> -->
                    <a class="extSearch" target="_new"
                        href="http://authorities.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;PAGE=First">[Search LCSH]</a>
                    <xsl:text>  </xsl:text>
                    <!--
                        <a class="extSearch"
                        onclick="window.open('http://www.ukat.org.uk/',
                        'new');">[Search UKAT]</a>
                    -->
                    <a class="extSearch" target="_new" href="http://www.ukat.org.uk/">[Search UKAT]
                    </a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/subject">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'subject'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedsubjects" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="subjecttable" class="tablecontainer">
                    <table id="table_subject">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Subject:</td>
                                <td>
                                    <input type="text" onfocus="setCurrent(this);"
                                        id="subject_subject" size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Thesauri:</td>
                                <td>
                                    <select id="subject_source">
                                        <option value="">select...
                                        </option>
                                        <option value="aat">aat
                                        </option>
                                        <option value="lcsh">lcsh
                                        </option>
                                        <option value="mesh">mesh
                                        </option>
                                        <option value="ukat">ukat
                                        </option>
                                        <option value="unesco">unesco
                                        </option>
                                        <option value="ewt">ewt
                                        </option>
                                    </select><!-- <input type="text" onfocus="setCurrent(this);" 
                                        id="subject_source" size="40"></input> -->
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="subjectdropdown">
                                        <option value="subject_dates">Dates
                                        </option>
                                        <option value="subject_loc">Location
                                        </option>
                                        <option value="subject_other">Other
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('subject');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('subject')" size="40" value="Click to Add Selected Field" 
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="subjectbuttons" class="buttoncontainer">
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('subject');" value="Add to Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('subject');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!--persname -->
            <div id="persname" class="apcontainer">
                <p>
                    <strong>Personal Name (structured; has surname/forename)</strong>
                    <a href="http://archiveshub.ac.uk/help/persname"
                        class="tip" title="What is this?" id="persnamehelp"
                        name="persnamehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!-- <a class="extSearch" onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=P', 
                        'new');">[Search NRA]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=P"
                        title="Search National Register of Archives">
                        [Search NRA]
                </a>
                </p>

                <xsl:choose>
                    <xsl:when test="controlaccess/persname/emph[@altrender='a']">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'persname'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedpersnames" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="persnametable" class="tablecontainer">
                    <table id="table_persname">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label"> Surname:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="persname_surname"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label"> Forename:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="persname_forename"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label"> Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="persname_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="persnamedropdown">
                                        <option value="persname_dates">Dates
                                        </option>
                                        <option value="persname_title">Title
                                        </option>
                                        <option value="persname_epithet">Epithet
                                        </option>
                                        <option value="persname_other">Other
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('persname');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('persname')" size="35" value="Click to Add Selected Field"
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="persnamebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="persname_rules" onchange="checkRules('persname')">
                            <option value="none">None</option>
                            <option value="ncarules">NCA Rules</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('persname');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('persname');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!--persname (non-western) -->
            <div id="persname-non-western" class="apcontainer">
                <p>
                    <strong>Personal Name (unstructured; no identified surname)</strong>
                    <a href="http://archiveshub.ac.uk/help/persnamestring"
                        class="tip" title="What is this?" id="persnamehelp"
                        name="persnamehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <a class="extSearch" target="_new"
                        href="http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=P"
                        title="Search National Register of Archives">
                        [Search NRA]
                </a>
                </p>

                <xsl:choose>
                    <!-- When there are no subfileds, or no surname subfield -->
                    <xsl:when test="controlaccess/persname[not(*)] or controlaccess/persname[not(emph/@altrender='a')]">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'persname-non-western'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedpersname-non-westerns" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="persname-non-westerntable" class="tablecontainer">
                    <table id="table_persname-non-western">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Name:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="persname-non-western_name"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label"> Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="persname-non-western_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="persname-non-westerndropdown">
                                        <option value="persname-non-western_dates">Dates
                                        </option>
                                        <option value="persname-non-western_title">Title
                                        </option>
                                        <option value="persname-non-western_epithet">Epithet
                                        </option>
                                        <option value="persname-non-western_other">Other
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('persname-non-western');">Add
                                        Selected Field</a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="persnamebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="persname-non-western_rules" onchange="checkRules('persname-non-western')">
                            <option value="none">None</option>
                            <option value="ncarules">NCA Rules</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('persname-non-western');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('persname-non-western');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!--famname -->
            <div id="famname" class="apcontainer">
                <p>
                    <strong>Family Name</strong>
                    <a href="http://archiveshub.ac.uk/help/famname"
                        class="tip" title="What is this?" id="famnamehelp"
                        name="famnamehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!-- <a class="extSearch" onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=F', 
                        'new');">[Search NRA]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=F">[Search NRA]</a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/famname">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'famname'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedfamnames" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="famnametable" class="tablecontainer">
                    <table id="table_famname">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Surname:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="famname_surname"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="famname_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="famnamedropdown">
                                        <option value="famname_other">Other
                                        </option>
                                        <option value="famname_dates">Dates
                                        </option>
                                        <option value="famname_title">Title
                                        </option>
                                        <option value="famname_epithet">Epithet
                                        </option>
                                        <option value="famname_loc">Location
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('famname');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('famname')" size="35" value="Click to Add Selected Field"
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="famnamebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="famname_rules" onchange="checkRules('famname')">
                            <option value="none">None</option>
                            <option value="ncarules">NCA Rules</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('famname');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('famname');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!-- corpname -->
            <div id="corpname" class="apcontainer">
                <p>
                    <strong>Corporate Name</strong>
                    <a href="http://archiveshub.ac.uk/help/corpname"
                        class="tip" title="What is this?" id="corpnamehelp"
                        name="corpnamehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!-- <a class="extSearch" onclick="window.open('http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=O', 
                        'new');">[Search NRA]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://www.nationalarchives.gov.uk/nra/searches/simpleSearch.asp?subjectType=O">[Search NRA]</a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/corpname">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'corpname'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedcorpnames" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="corpnametable" class="tablecontainer">
                    <table id="table_corpname">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Organisation:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="corpname_organisation"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="corpname_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="corpnamedropdown">
                                        <option value="corpname_dates">Dates
                                        </option>
                                        <option value="corpname_loc">Location
                                        </option>
                                        <option value="corpname_other">Other
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('corpname');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('corpname')" size="35" value="Click to Add Selected Field"
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="corpnamebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="corpname_rules" onchange="checkRules('corpname')">
                            <option value="none">None</option>
                            <option value="ncarules">NCA Rules</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('corpname');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('corpname');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!-- placename -->
            <div id="geogname" class="apcontainer">
                <p>
                    <strong>Place Name</strong>
                    <a href="http://archiveshub.ac.uk/help/geogname"
                        class="tip" title="What is this?" id="geognamehelp"
                        name="geognamehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <a class="extSearch" target="_new"
                        href="http://www.geonames.org/"
                        title="Search the GeoNames geographical database">
                        [Search GeoNames]
                    </a>
                    <a class="extSearch" target="_new"
                        href="http://www.getty.edu/research/tools/vocabularies/tgn/"
                        title="Search the Getty Thesaurus">
                        [Search Getty]
                    </a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/geogname">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'geogname'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedgeognames" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="geognametable" class="tablecontainer">
                    <table id="table_geogname">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Place Name:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="geogname_location"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="geogname_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="geognamedropdown">
                                        <option value="geogname_dates">Dates
                                        </option>
                                        <option value="geogname_loc">Location
                                        </option>
                                        <option value="geogname_other">Other
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('geogname');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('geogname')" size="35" value="Click to Add Selected Field"
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="geognamebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="geogname_rules" onchange="checkRules('geogname')">
                            <option value="none">None</option>
                            <option value="ncarules">NCA Rules</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('geogname');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('geogname');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!--title -->
            <div id="title" class="apcontainer">
                <p>
                    <strong>Book Title</strong>
                    <a href="http://archiveshub.ac.uk/help/booktitle"
                        class="tip" title="What is this?" id="booktitlehelp"
                        name="booktitlehelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/title">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'title'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedtitles" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="titletable" class="tablecontainer">
                    <table id="table_title">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Title:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="title_title"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="title_source"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td>
                                    <select onfocus="setCurrent(this);"
                                        id="titledropdown">
                                        <option value="title_dates">Dates
                                        </option>
                                    </select>
                                </td>
                                <td>
                                    <a class="addfield" onclick="addField('title');">Add
                                        Selected Field</a><!-- <input type="text" 
                                        onfocus="addField('title')" size="35" value="Click to Add Selected Field"
                                        style="background:#F2F2F2; color: grey;"></input> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="titlebuttons" class="buttoncontainer">
                    <p class="apbutton">
                        Rules:
                        <select id="title_rules" onchange="checkRules('title')">
                            <option value="none">None</option>
                            <option value="aacr2">AACR2</option>
                        </select>
                    </p>
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('title');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('title');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
            <!-- genreform -->
            <div id="genreform" class="apcontainer">
                <p>
                    <strong>Genre Form</strong>
                    <a href="http://archiveshub.ac.uk/help/genreform"
                        class="tip" title="What is this?" id="genreformhelp"
                        name="genreformhelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!--
                        <a class="extSearch"
                        onclick="window.open('http://www.getty.edu/research/conducting_research/vocabularies/aat/',
                        'new');">[Search AAT]</a>
                    -->
                    <a class="extSearch" target="_new"
                        href="http://www.getty.edu/research/conducting_research/vocabularies/aat/">[Search AAT]</a>
                    <xsl:text> </xsl:text>
                    <!--
                        <a class="extSearch"
                        onclick="window.open('http://www.loc.gov/rr/print/tgm2/',
                        'new');">[Search TGM]</a>
                    -->
                    <a class="extSearch" target="_new"
                        href="http://www.loc.gov/rr/print/tgm2/">[Search TGM]</a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/genreform">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'genreform'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedgenreforms" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="genreformtable" class="tablecontainer">
                    <table id="table_genreform">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Genre:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="genreform_genre"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="genreform_source"
                                        size="35"></input>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="genreformbuttons" class="buttoncontainer">
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('genreform');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('genreform');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />

            <!-- function -->
            <div id="function" class="apcontainer">
                <p>
                    <strong>Function</strong>
                    <a href="http://archiveshub.ac.uk/help/function"
                        class="tip" title="What is this?" id="functionhelp"
                        name="functionhelp" target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <!--
                        <a class="extSearch"
                        onclick="window.open('http://www.jisc.ac.uk/publications/publications/recordssrlstructure/fama.aspx',
                        'new');">[Search JISC]</a>
                    -->
                    <!--
                    <a class="extSearch" target="_new"
                        href="http://vle.causeway.ac.uk/jisc_he/">[Search
                        JISC]</a>
                    -->
                    <!--            <xsl:text> </xsl:text>-->
                    <!-- <a class="extSearch" onclick="window.open('http://www.getty.edu/research/conducting_research/vocabularies/aat/', 
                        'new');">[Search AAT]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://www.getty.edu/research/conducting_research/vocabularies/aat/">[Search AAT]</a>
                    <xsl:text> </xsl:text>
                    <!-- <a class="extSearch" onclick="window.open('http://www.naa.gov.au/records-management/create-capture-describe/describe/agift/index.aspx', 
                        'new');">[Search AGIFT]</a> -->
                    <a class="extSearch" target="_new"
                        href="http://www.naa.gov.au/records-management/publications/agift.aspx">[Search AGIFT]</a>
                </p>
                <xsl:choose>
                    <xsl:when test="controlaccess/function">
                        <xsl:call-template name="accesspoint">
                            <xsl:with-param name="aptype"
                                select="'function'" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="addedfunctions" style="display:none"
                            class="added">
                            <xsl:text> </xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <div id="functiontable" class="tablecontainer">
                    <table id="table_function">
                        <tbody>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Function:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="function_function"
                                        size="35"></input>
                                </td>
                            </tr>
                            <tr NoDrop="true" NoDrag="true">
                                <td class="label">Source:</td>
                                <td>
                                    <input type="text"
                                        onfocus="setCurrent(this);" id="function_source"
                                        size="35"></input>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="functionbuttons" class="buttoncontainer">
                    <input class="apbutton" type="button"
                        onclick="addAccessPoint('function');" value="Add To Record"></input>
                    <br />
                    <input class="apbutton" type="button"
                        onclick="resetAccessPoint('function');" value="Reset"></input>
                </div>
                <br />
            </div>
            <br />
        </div>
    </xsl:template>

    <xsl:template name="accesspoint">
        <xsl:param name="aptype" />
        <div style="display:block" class="added">
            <xsl:attribute name="id">
                <xsl:text>added</xsl:text>
                <xsl:value-of select="$aptype" />
                <xsl:text>s</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$aptype = 'persname'">
                    <xsl:for-each select="controlaccess/persname[emph/@altrender='a']">
                        <xsl:call-template name="accesspointrow">
                            <xsl:with-param name="aptype">
                                <xsl:value-of select="$aptype"/>
                            </xsl:with-param>
                            <xsl:with-param name="position">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$aptype = 'persname-non-western'">
                    <xsl:for-each select="controlaccess/persname[not(*)]|controlaccess/persname[not(emph/@altrender='a')]">
                        <xsl:call-template name="accesspointrow">
                            <xsl:with-param name="aptype">
                                <xsl:value-of select="$aptype"/>
                            </xsl:with-param>
                            <xsl:with-param name="position">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="controlaccess/*[name() = $aptype]">
                        <xsl:call-template name="accesspointrow">
                            <xsl:with-param name="aptype">
                                <xsl:value-of select="$aptype"/>
                            </xsl:with-param>
                            <xsl:with-param name="position">
                                <xsl:value-of select="position()"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="accesspointrow">
        <xsl:param name="aptype"/>
        <xsl:param name="position"/>
        <input type="hidden">
            <xsl:attribute name="name">
                <xsl:text>controlaccess/</xsl:text>
                <xsl:value-of select="$aptype" />
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="$aptype" />
                <xsl:text>_formgen</xsl:text>
                <xsl:value-of select="$position"/>
                <xsl:text>xml</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="value">
                <!--<div class="accesspoint">-->
                   <xsl:call-template name="accesspointstring">
                      <xsl:with-param name="aptype" select="$aptype" />
                       <xsl:with-param name="separater" select="' ||| '" />
                    </xsl:call-template>
                <!--</div>-->
            </xsl:attribute>
        </input>
        <div>
            <xsl:attribute name="id">
                <xsl:value-of select="$aptype" />
                <xsl:text>_formgen</xsl:text>
                <xsl:value-of select="$position"/>
            </xsl:attribute>
            <div class="icons">
                <a>
                    <xsl:attribute name="onclick">
                        <xsl:text>deleteAccessPoint('</xsl:text>
                        <xsl:value-of
                            select="$aptype" />
                        <xsl:text>_formgen</xsl:text>
                        <xsl:value-of select="$position"/>
                        <xsl:text>');</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text>delete entry</xsl:text>
                    </xsl:attribute>
                    <img src="/images/editor/delete.png" class="deletelogo"
                        alt="X">
                        <xsl:attribute name="onmouseover">
                            <xsl:text>this.src='/images/editor/delete-hover.png';</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="onmouseout">
                            <xsl:text>this.src='/images/editor/delete.png';</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="id">
                            <xsl:text>delete</xsl:text>
                            <xsl:value-of select="$position"/>
                        </xsl:attribute>
                    </img>
                </a>
            </div>
            <div class="accesspoint">
                <a>
                    <xsl:attribute name="onclick">
                        <xsl:text>editAccessPoint('</xsl:text>
                        <xsl:value-of
                            select="$aptype" />
                        <xsl:text>_formgen', </xsl:text>
                        <xsl:value-of select="$position"/>
                        <xsl:text>);</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:text>Click to edit</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="accesspointstring">
                        <xsl:with-param name="aptype"
                            select="$aptype" />
                        <xsl:with-param name="separater"
                            select="' '" />
                    </xsl:call-template>
                </a>
            </div>
        </div>
        <br>
            <xsl:attribute name="id">
                <xsl:value-of select="$aptype" />
                <xsl:text>_formgen</xsl:text>
                <xsl:value-of select="$position"/>
                <xsl:text>br</xsl:text>
            </xsl:attribute>
        </br>
    </xsl:template>


    <xsl:template name="accesspointstring">
        <xsl:param name="aptype" />
        <xsl:param name="separater" />
        <xsl:choose>
            <xsl:when test="emph">
                <xsl:choose>
                    <xsl:when test="$separater = ' '">
                        <xsl:for-each select="emph">
                            <xsl:value-of select="." />
                            <xsl:value-of select="$separater" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$separater = ' ||| '">
                        <xsl:for-each select="emph">
                            <xsl:value-of select="$aptype" />
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="@altrender" />
                            <xsl:text> | </xsl:text>
                            <xsl:value-of select="." />
                            <xsl:value-of select="$separater" />
                        </xsl:for-each>
                        <xsl:if test="@source">
                            <xsl:value-of select="$aptype" />
                            <xsl:text>_source | </xsl:text>
                            <xsl:apply-templates
                                select="@source" />
                            <xsl:value-of select="$separater" />
                        </xsl:if>
                        <xsl:if test="@rules">
                            <xsl:value-of select="$aptype" />
                            <xsl:text>_rules | </xsl:text>
                            <xsl:apply-templates
                                select="@rules" />
                            <xsl:value-of select="$separater" />
                        </xsl:if>
                        <xsl:for-each select="@*">
                            <xsl:if
                                test="not(name() = 'rules') and not(name() = 'source')">
                                <xsl:text>att_</xsl:text>
                                <xsl:value-of select="name()" />
                                <xsl:text> | </xsl:text>
                                <xsl:value-of select="." />
                                <xsl:value-of select="$separater" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$separater = ' '">
                        <xsl:value-of select="./text()" />
                        <xsl:value-of select="$separater" />
                    </xsl:when>
                    <xsl:when test="$separater = ' ||| '">
                        <xsl:value-of select="$aptype" />
                        <xsl:text>_a | </xsl:text>
                        <xsl:value-of select="." />
                        <xsl:value-of select="$separater" />
                        <xsl:if test="@source">
                            <xsl:value-of select="$aptype" />
                            <xsl:text>_source | </xsl:text>
                            <xsl:apply-templates
                                select="@source" />
                            <xsl:value-of select="$separater" />
                        </xsl:if>
                        <xsl:if test="@rules">
                            <xsl:value-of select="$aptype" />
                            <xsl:text>_rules | </xsl:text>
                            <xsl:apply-templates
                                select="@rules" />
                            <xsl:value-of select="$separater" />
                        </xsl:if>
                        <xsl:for-each select="@*">
                            <xsl:if
                                test="not(name() = 'rules') and not(name() = 'source')">
                                <xsl:text>att_</xsl:text>
                                <xsl:value-of select="name()" />
                                <xsl:text> | </xsl:text>
                                <xsl:value-of select="." />
                                <xsl:value-of select="$separater" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unitid">
        <xsl:param name="node" />
        <xsl:param name="position" />
        <xsl:variable name="input-name-prefix">
            <xsl:text>did/unitid[</xsl:text>
            <xsl:value-of select="$position" />
            <xsl:text>]</xsl:text>
        </xsl:variable>
        <div class="clear">
            <div class="float">
                <!-- disabled? -->
                <xsl:if test="@type = 'persistent'">
                    <xsl:attribute name="title">
                    <xsl:text>You may not edit this field; it has been designated as the persistent identifier</xsl:text>
                </xsl:attribute>
                </xsl:if>
                <input type="text" onfocus="setCurrent(this);"
                    maxlength="2" size="3" onblur="updateId();">
                    <xsl:attribute name="id">
                    <xsl:text>countrycode[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                    <xsl:attribute name="name">
	                <xsl:value-of select="$input-name-prefix" />
	                <xsl:text>/@countrycode</xsl:text>
	            </xsl:attribute>
                    <!-- disabled? -->
                    <xsl:if test="@type = 'persistent'">
                        <xsl:attribute name="readonly">
                            <xsl:text>readonly</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <!-- value -->
            <xsl:choose>
                        <xsl:when test="$node/@countrycode">
                    <xsl:attribute name="value">
	                    <xsl:value-of select="$node/@countrycode" />
			</xsl:attribute>
                </xsl:when>
                <xsl:when
                            test="$leveltype='collection' and $node/ancestor::ead/eadheader/eadid/@countrycode">
                    <xsl:attribute name="value">
				<xsl:value-of
                                select="$node/ancestor::ead/eadheader/eadid/@countrycode" />
			</xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </input>

                <input type="text" onfocus="setCurrent(this);"
                    maxlength="4" size="5" onblur="updateId();">
                    <xsl:attribute name="id">
                    <xsl:text>archoncode[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                    <xsl:attribute name="name">
	                <xsl:value-of select="$input-name-prefix" />
	                <xsl:text>/@repositorycode</xsl:text>
	            </xsl:attribute>
                    <!-- disabled? -->
                    <xsl:if test="@type = 'persistent'">
                        <xsl:attribute name="readonly">
                            <xsl:text>readonly</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <!-- value -->
            <xsl:choose>
                        <xsl:when test="$node/@repositorycode">
                    <xsl:attribute name="value">
	                    <xsl:value-of select="$node/@repositorycode" />
			</xsl:attribute>
                </xsl:when>
                <xsl:when
                            test="$leveltype='collection' and $node/ancestor::ead/eadheader/eadid/@mainagencycode">
                    <xsl:attribute name="value">
				<xsl:value-of
                                select="$node/ancestor::ead/eadheader/eadid/@mainagencycode" />
			</xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </input>
                <input type="text" onfocus="setCurrent(this);" size="25"
                    onblur="updateId();">
                    <xsl:attribute name="id">
                    <xsl:text>unitid[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                    <xsl:attribute name="name">
	                <xsl:value-of select="$input-name-prefix" />
	            </xsl:attribute>
                    <!-- disabled? -->
                    <xsl:if test="@type = 'persistent'">
                        <xsl:attribute name="readonly">
                            <xsl:text>readonly</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <!-- value -->
            <xsl:attribute name="value">
	                <xsl:value-of select="$node" />
		</xsl:attribute>
        </input>
                <strong>
                    <xsl:text>Label: </xsl:text>
                </strong>
                <xsl:variable name="label">
                    <xsl:value-of
                        select="translate($node/@label, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
                </xsl:variable>
                <select>
                    <xsl:attribute name="id">
                   <xsl:text>unitidlabel[</xsl:text>
                   <xsl:value-of select="$position" />
                   <xsl:text>]</xsl:text>
               </xsl:attribute>
                    <xsl:attribute name="name">
                   <xsl:value-of select="$input-name-prefix" />
                   <xsl:text>/@label</xsl:text>
               </xsl:attribute>
                    <option>
                        <xsl:attribute name="value">
	                   <xsl:text>current</xsl:text>
	               </xsl:attribute>
                        <xsl:if
                            test="not(starts-with($label, 'former') or starts-with($label, 'alt'))">
                            <xsl:attribute name="selected">
                                <xsl:text>selected</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:text>current</xsl:text>
                    </option>
                    <option>
                        <xsl:attribute name="value">
                       <xsl:text>former</xsl:text>
                   </xsl:attribute>
                        <xsl:if test="starts-with($label, 'former')">
                            <xsl:attribute name="selected">
                                <xsl:text>selected</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:text>former</xsl:text>
                    </option>
                    <option>
                        <xsl:attribute name="value">
                       <xsl:text>alternative</xsl:text>
                   </xsl:attribute>
                        <xsl:if test="starts-with($label, 'alt')">
                            <xsl:attribute name="selected">
                                <xsl:text>selected</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:text>alternative</xsl:text>
                    </option>
                </select>
            </div> <!-- /.float -->
        </div> <!-- /.clear -->
    </xsl:template>

    <xsl:template match="did/unittitle">
        <xsl:choose>
            <xsl:when test="$formtype = 'ead'">
                <input class="menuField" type="text" onfocus="setCurrent(this);"
                    name="did/unittitle" id="did/unittitle" size="60"
                    onchange="updateTitle(this);" onkeypress="validateFieldDelay(this, 'true');">
                    <xsl:attribute name="value">
			  			<xsl:apply-templates />
			  		</xsl:attribute>
                </input>
            </xsl:when>
            <xsl:otherwise>
                <input class="menuField" type="text" onfocus="setCurrent(this);"
                    name="did/unittitle" id="did/unittitle" size="60"
                    onchange="validateField(this, 'true');" onkeypress="validateFieldDelay(this, 'true');">
                    <xsl:attribute name="value">
			  			<xsl:apply-templates />
			  		</xsl:attribute>
                </input>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="unitdate">
        <xsl:param name="node" />
        <xsl:param name="path" />
        <div class="clear">
            <div class="float">
                <p>
                    <strong>
                        <span class="isadg">3.1.3: </span>
                        Dates of Creation
                    </strong>
                    <a href="http://archiveshub.ac.uk/help/dates" class="tip"
                        title="Dates of Creation help - opens in new window"
                        target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    <br />
                    <input class="menuField" type="text" onfocus="setCurrent(this);"
                        onkeypress="validateFieldDelay(this, 'true');"
                        onchange="validateField(this, 'true');" onblur="validateField(this, 'true');"
                        size="29">
                        <xsl:attribute name="name">
		                    <xsl:value-of select="$path" />
		                </xsl:attribute>
                        <xsl:attribute name="id">
		                    <xsl:value-of select="$path" />
                        </xsl:attribute>
                        <xsl:attribute name="value">
                            <xsl:value-of select="$node" />
                        </xsl:attribute>
                    </input>
                </p>
            </div>
            <div class="float">
                <p>
                    <strong>
                        <xsl:text>Normalised Date</xsl:text>
                    </strong>
                    <a href="http://archiveshub.ac.uk/help/dates" class="tip"
                        title="Normalised Date help - opens in new window"
                        target="_new">
                        <img src="/images/structure/form_tip.png" alt="[?]" />
                    </a>
                    YYYY/YYYY or YYYYMMDD/YYYYMMDD
                    <br />
        <input class="dateOK" type="text" onfocus="setCurrent(this);"
                        onkeypress="validateNormdateDelay(this, 'true');"
                        onchange="validateNormdate(this, 'true');" onblur="validateNormdate(this, 'true');"
                        size="29" maxlength="21">
                        <xsl:attribute name="name">
		                <xsl:value-of select="$path" />
		                <xsl:text>/@normal</xsl:text>
		            </xsl:attribute>
                        <xsl:attribute name="id">
		                <xsl:value-of select="$path" />
		                <xsl:text>/@normal</xsl:text>
		            </xsl:attribute>
            <xsl:attribute name="value">
                        <xsl:value-of select="$node/@normal" />
  		</xsl:attribute>
        </input>
                </p>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="did/repository">
        <input class="menuField" type="text"
            onkeypress="validateFieldDelay(this, 'true');" onchange="validateField(this, 'true');"
            onblur="validateField(this, 'true');" onfocus="setCurrent(this);"
            name="did/repository" id="did/repository" size="60">
            <xsl:attribute name="value">
  			<xsl:apply-templates />
  		</xsl:attribute>
        </input>
    </xsl:template>

    <xsl:template name="originationTypeSelect">
        <xsl:param name="input-name-prefix"/>
        <xsl:param name="position"/>
        <xsl:param name="localname"/>
        <select class="originationType">
            <!-- id required for cloning; need not be meaningful -->
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <option>
                <xsl:attribute name="id">
                    <xsl:value-of select="$input-name-prefix"/>
                </xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:value-of select="$input-name-prefix"/>
                </xsl:attribute>
                <xsl:text>Choose&#8230;</xsl:text>
            </option>
            <option>
                <!--
                id required for cloning; need not be meaningful
                but add a position predicate to trigger substitution
                in value
                -->
                <xsl:attribute name="id">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/persname[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/persname[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:if test="$localname = 'persname'">
                    <xsl:attribute name="selected">
                        <xsl:text>selected</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:text>Person</xsl:text>
            </option>
            <option>
                <!--
                id required for cloning; need not be meaningful
                but add a position predicate to trigger substitution
                in value
                -->
                <xsl:attribute name="id">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/famname[</xsl:text>
                    <xsl:value-of select="$position" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/famname[</xsl:text>
                    <xsl:value-of select="position()" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:if test="$localname = 'famname'">
                    <xsl:attribute name="selected">
                        <xsl:text>selected</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:text>Family</xsl:text>
            </option>
            <option>
                <!--
                id required for cloning; need not be meaningful
                but add a position predicate to trigger substitution
                in value
                -->
                <xsl:attribute name="id">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/corpname[</xsl:text>
                    <xsl:value-of select="position()" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="value">
                    <xsl:value-of select="$input-name-prefix"/>
                    <xsl:text>/corpname[</xsl:text>
                    <xsl:value-of select="position()" />
                    <xsl:text>]</xsl:text>
                </xsl:attribute>
                <xsl:if test="$localname = 'corpname'">
                    <xsl:attribute name="selected">
                        <xsl:text>selected</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:text>Organization</xsl:text>
            </option>
        </select>
    </xsl:template>

    <xsl:template name="origination">
        <xsl:param name="node" />
        <xsl:param name="position" />
        <xsl:variable name="input-name-prefix">
            <xsl:text>did/origination[</xsl:text>
            <xsl:value-of select="$position" />
            <xsl:text>]</xsl:text>
        </xsl:variable>
        <xsl:for-each select="self::node()[not(*)]|./*">
            <xsl:variable name="input-name">
                <xsl:value-of select="$input-name-prefix" />
                <xsl:if test="local-name() != 'origination'">
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="local-name()" />
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="position()" />
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:variable>
            <div class="clear">
                <div class="float">

                    <xsl:call-template name="originationTypeSelect">
                        <xsl:with-param name="input-name-prefix" select="$input-name-prefix"/>
                        <xsl:with-param name="position" select="position()"/>
                        <xsl:with-param name="localname" select="local-name()"/>
                    </xsl:call-template>

                    <input class="menuField" type="text" onfocus="setCurrent(this);"
                        onkeypress="validateFieldDelay(this, 'true');"
                        onchange="validateField(this, 'true');"
                        onblur="validateField(this, 'true');"
                        size="48">
                        <xsl:attribute name="name">
                            <xsl:value-of select="$input-name" />
                        </xsl:attribute>
                        <xsl:attribute name="id">
                            <xsl:value-of select="$input-name" />
                        </xsl:attribute>
                        <xsl:attribute name="value">
                            <xsl:value-of select="." />
                        </xsl:attribute>
                    </input>
                </div> <!-- /.float -->
            </div> <!-- /.clear -->
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/ead/eadheader/filedesc/titlestmt/sponsor">
        <strong>Sponsor</strong>
        <a href="http://archiveshub.ac.uk/help/sponsor" class="tip"
            id="sponsorhelp" name="sponsorhelp" target="_new">
            <img src="/images/structure/form_tip.png" alt="[?]" />
        </a>
        <a class="smalllink" id="linkspo" title="add sponsor"
            onclick="addElement('filedesc/titlestmt/sponsor')">hide content</a>
        [optional]
        <br />
        <input class="menuField" type="text"
            onkeypress="validateFieldDelay(this, 'true');" onchange="validateField(this, 'true');"
            onfocus="setCurrent(this);" name="filedesc/titlestmt/sponsor" id="filedesc/titlestmt/sponsor"
            size="60">
            <xsl:attribute name="value">
  			<xsl:apply-templates />
  		</xsl:attribute>
        </input>
    </xsl:template>

    <xsl:template match="did/origination">
        <input class="menuField" type="text"
            onkeypress="validateFieldDelay(this, 'true');" onchange="validateField(this, 'true');"
            onblur="validateField(this, 'true');" onfocus="setCurrent(this);"
            name="did/origination" id="did/origination" size="60">
            <xsl:attribute name="value">
  			<xsl:apply-templates />
  		</xsl:attribute>
        </input>
    </xsl:template>

    <xsl:template match="did/langmaterial">
        <div id="addedlanguages" style="display:block" class="added">
            <xsl:for-each select="language">
                <input type="hidden" name="did/langmaterial/language">
                    <xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single"
                        count="language" format="1" /><xsl:text>xml</xsl:text>
				</xsl:attribute>
                    <xsl:attribute name="value">
					<xsl:text>lang_code | </xsl:text><xsl:value-of
                        select="@langcode" /><xsl:text> ||| lang_name | </xsl:text><xsl:value-of
                        select="." /><xsl:text> ||| </xsl:text>
					<xsl:for-each select="@*">
		  	 			<xsl:if test="not(name() = 'langcode')">
		  	 				<xsl:text>att_</xsl:text>
		  	 				<xsl:value-of select="name()" />
		  	 				<xsl:text> | </xsl:text>
		  	 				<xsl:value-of select="." />
		  	 				<xsl:text> ||| </xsl:text>
		  	 			</xsl:if>
		  	 		</xsl:for-each>	
				</xsl:attribute>
                </input>
                <div>
                    <xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single"
                        count="language" format="1" />				
				</xsl:attribute>
                    <div class="icons">
                        <a>
                            <xsl:attribute name="onclick">
							<xsl:text>deleteAccessPoint('language_formgen</xsl:text><xsl:number
                                level="single" count="language" format="1" /><xsl:text>');</xsl:text>
						</xsl:attribute>
                            <xsl:attribute name="title">
							<xsl:text>delete entry</xsl:text>
						</xsl:attribute>
                            <img src="/images/editor/delete.png" class="deletelogo"
                                alt="X">
                                <xsl:attribute name="onmouseover">
	                            <xsl:text>this.src='/images/editor/delete-hover.png';</xsl:text>
                        </xsl:attribute>
                                <xsl:attribute name="onmouseout">
	                            <xsl:text>this.src='/images/editor/delete.png';</xsl:text>
                        </xsl:attribute>
                                <xsl:attribute name="id">
							<xsl:text>delete</xsl:text><xsl:number level="single"
                                    count="language" format="1" />
						</xsl:attribute>
                            </img>
                        </a>
                    </div>
                    <div class="accesspoint">
                        <a>
                            <xsl:attribute name="onclick">
						<xsl:text>editAccessPoint('language_formgen', </xsl:text><xsl:number
                                level="single" count="language" format="1" /><xsl:text>);</xsl:text>
					</xsl:attribute>
                            <xsl:attribute name="title">
						<xsl:text>Click to edit</xsl:text>
					</xsl:attribute>
                            <xsl:value-of select="@langcode" />
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="." />
                        </a>
                    </div>
                </div>
                <br>
                    <xsl:attribute name="id">
					<xsl:text>language_formgen</xsl:text><xsl:number level="single"
                        count="language" format="1" /><xsl:text>br</xsl:text>
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
            <xsl:attribute name="value"><xsl:value-of
                select="$value" /></xsl:attribute>
            <xsl:if test="$value = $select">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$label" />
        </xsl:element>
    </xsl:template>

    <xsl:template name="textfield">
        <xsl:param name="name" />
        <xsl:param name="class" />
        <input type="text" onkeypress="validateFieldDelay(this, 'true');"
            onchange="validateField(this, 'true');" onblur="validateField(this, 'true');"
            onfocus="setCurrent(this);" size="60">
            <xsl:attribute name="name">
	            <xsl:value-of select="$name" />
	        </xsl:attribute>
            <xsl:attribute name="id">
	            <xsl:value-of select="$name" />
	        </xsl:attribute>
            <xsl:attribute name="class">
	            <xsl:value-of select="$class" />
	        </xsl:attribute>
            <xsl:attribute name="value">
                <xsl:apply-templates select="./node()" />
            </xsl:attribute>
        </input>
    </xsl:template>


    <xsl:template name="textarea">
        <xsl:param name="name" />
        <xsl:param name="class" />
        <xsl:param name="optional" />
        <xsl:param name="content" />
        <xsl:param name="isadg" />
        <xsl:param name="title" />
        <xsl:param name="help" />
        <xsl:param name="additional" />
        <xsl:call-template name="label">
            <xsl:with-param name="id" select="$name" />
            <xsl:with-param name="optional" select="$optional" />
            <xsl:with-param name="content" select="$content" />
            <xsl:with-param name="isadg" select="$isadg" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="help" select="$help" />
            <xsl:with-param name="additional" select="$additional" />
        </xsl:call-template>
        <textarea onkeypress="validateFieldDelay(this, 'true');"
            onchange="validateField(this, 'true');" onblur="validateField(this, 'true');"
            onfocus="setCurrent(this);" rows="5" cols="60">
            <xsl:attribute name="name">
  		    <xsl:value-of select="$name" />
	    </xsl:attribute>
            <xsl:attribute name="id">
  		    <xsl:value-of select="$name" />
        </xsl:attribute>
            <xsl:attribute name="class">
  		    <xsl:value-of select="$class" />
        </xsl:attribute>
            <xsl:if test="$optional = 'true' and $content = 'false'">
                <xsl:attribute name="style">display:none</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$content = 'false'">
                    <xsl:text>&lt;p&gt;&lt;/p&gt;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="./node()" />
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
        <br />
        <strong>
            <span class="isadg">
                <xsl:value-of select="$isadg" />
            </span>
            <xsl:value-of select="$title" />
        </strong>
        <xsl:if test="not($help='')">
            <a class="tip">
                <xsl:attribute name="href">
                  <xsl:value-of select="$help" />
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:value-of select="$title" /><xsl:text> help - opens in new window</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_new</xsl:text>
                </xsl:attribute>
                <img src="/images/structure/form_tip.png" alt="[?]"/>
            </a>
        </xsl:if>

        <xsl:if test="not($additional = '')">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$additional" />
        </xsl:if>
        <xsl:if test="$optional = 'true'">
            <xsl:text> </xsl:text>
            <a class="smalllink">
                <xsl:attribute name="title">
                   <xsl:text>add content </xsl:text>
                   <xsl:value-of select="$title" />
                </xsl:attribute>
                <xsl:attribute name="id">
                   <xsl:text>link</xsl:text>
                   <xsl:value-of select="$id" />
                </xsl:attribute>
                <xsl:attribute name="onclick">
                    <xsl:text>addElement('</xsl:text>
                    <xsl:value-of select="$id" />
                    <xsl:text>')</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$content = 'true'">
                        <xsl:text>hide content</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>add content</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:text> [optional]</xsl:text>
        </xsl:if>
        <br />
    </xsl:template>

    <xsl:template match="comment()">
        <xsl:comment>
            <xsl:value-of select="." />
        </xsl:comment>
    </xsl:template>

    <xsl:template match="*">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()" />
        <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name()" />
            <xsl:text>="</xsl:text>
            <xsl:value-of select="." />
            <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()" />
        <xsl:text>&gt;</xsl:text>
    </xsl:template>


    <xsl:template name="dao">
        <xsl:param name="type" />
        <xsl:param name="number" />
        <xsl:param name="path" />
        <table>
            <tbody>
                <tr>
                    <td class="label">File URI: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@href" />
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>dao</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|href</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>dao</xsl:text>
                                <xsl:value-of select="$number" /><xsl:text>|href</xsl:text>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td class="label">Description: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);" class="menuField" onkeypress="validateFieldDelay(this, 'true');" onchange="validateField(this, 'true');" onblur="validateField(this, 'true');">
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>dao</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>dao</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="daodesc">
                                        <xsl:apply-templates select="daodesc" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&lt;p&gt;&lt;/p&gt;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
            </tbody>
        </table>
        <input type="hidden">
            <xsl:attribute name="value">
                <xsl:value-of select="$type" />
            </xsl:attribute>
            <xsl:attribute name="name">
                <xsl:text>daox</xsl:text>
                <xsl:value-of select="$path" />
                <xsl:text>dao</xsl:text>
                <xsl:value-of select="$number" />
                <xsl:text>|</xsl:text>
                <xsl:value-of select="$type" />
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:text>daox</xsl:text><xsl:value-of select="$path" />
                <xsl:text>dao</xsl:text><xsl:value-of select="$number" />
                <xsl:text>|</xsl:text>
                <xsl:value-of select="$type" />
            </xsl:attribute>
        </input>
    </xsl:template>

    <xsl:template name="thumb">
        <xsl:param name="number" />
        <xsl:param name="path" />
        <table>
            <tbody>
                <tr>
                    <td class="label">Thumbnail URI: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);">
                            <xsl:attribute name="value">
                                <xsl:value-of select="daoloc[@role='thumb']/@href" />
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|href1</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|href1</xsl:text>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td class="label">File URI: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);">
                            <xsl:attribute name="value">
                                <xsl:value-of select="daoloc[@role='reference']/@href" />
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|href2</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|href2</xsl:text>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td class="label">Description: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);"
                            class="menuField" onkeypress="validateFieldDelay(this, 'true');"
                            onchange="validateField(this, 'true');"
                            onblur="validateField(this, 'true');">
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" /><xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="daodesc">
                                      <xsl:apply-templates select="daodesc" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&lt;p&gt;&lt;/p&gt;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
            </tbody>
        </table>
        <input type="hidden" value="thumb">
            <xsl:attribute name="name">
                <xsl:text>daox</xsl:text><xsl:value-of select="$path" /><xsl:text>grp</xsl:text><xsl:value-of
                select="$number" /><xsl:text>|thumb</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:text>daox</xsl:text>
                <xsl:value-of select="$path" />
                <xsl:text>grp</xsl:text>
                <xsl:value-of select="$number" />
                <xsl:text>|thumb</xsl:text>
            </xsl:attribute>
        </input>
        <input type="hidden" value="reference">
            <xsl:attribute name="name">
                <xsl:text>daox</xsl:text>
                <xsl:value-of select="$path" />
                <xsl:text>grp</xsl:text>
                <xsl:value-of select="$number" />
                <xsl:text>|reference</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:text>daox</xsl:text>
                <xsl:value-of select="$path" />
                <xsl:text>grp</xsl:text>
                <xsl:value-of select="$number" />
                <xsl:text>|reference</xsl:text>
            </xsl:attribute>
        </input>
    </xsl:template>

    <xsl:template name="multiple">
        <xsl:param name="number" />
        <xsl:param name="form" />
        <xsl:param name="path" />
        <table class="daotable">
            <tbody>
                <xsl:for-each select="daoloc">
                    <xsl:variable name="class">
                        <xsl:choose>
                            <xsl:when test="position() mod 2 = 1">
                                even
                            </xsl:when>
                            <xsl:otherwise>
                                odd
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <tr>
                        <xsl:attribute name="class">
                            <xsl:value-of select="$class" />
                        </xsl:attribute>
                        <td class="label">
                            <xsl:text>File </xsl:text>
                            <xsl:value-of select="position()" />
                            <xsl:text> URI: </xsl:text>
                        </td>
                        <td>
                            <input type="text" size="60"
                                onfocus="setCurrent(this);">
                                <xsl:attribute name="name">
                                    <xsl:text>daox</xsl:text>
                                    <xsl:value-of select="$path" />
                                    <xsl:text>grp</xsl:text>
                                    <xsl:value-of select="$number" />
                                    <xsl:text>|href</xsl:text>
                                    <xsl:value-of select="position()" />
                                </xsl:attribute>
                                <xsl:attribute name="id">
                                    <xsl:text>daox</xsl:text>
                                    <xsl:value-of select="$path" />
                                    <xsl:text>grp</xsl:text>
                                    <xsl:value-of select="$number" />
                                    <xsl:text>|href</xsl:text>
                                    <xsl:value-of select="position()" />
                                </xsl:attribute>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="@href" />
                                </xsl:attribute>
                            </input>
                        </td>
                    </tr>
                    <tr>
                        <xsl:attribute name="class">
                           <xsl:value-of select="$class" />
                        </xsl:attribute>
                        <td class="label">
                            <xsl:text>File </xsl:text>
                            <xsl:value-of select="position()" />
                            <xsl:text> Title: </xsl:text>
                        </td>
                        <td>
                            <input type="text" size="60"
                                onfocus="setCurrent(this);">
                                <xsl:attribute name="name">
                                    <xsl:text>daox</xsl:text>
                                    <xsl:value-of select="$path" />
                                    <xsl:text>grp</xsl:text>
                                    <xsl:value-of select="$number" />
                                    <xsl:text>|title</xsl:text>
                                    <xsl:value-of select="position()" />
                                </xsl:attribute>
                                <xsl:attribute name="id">
                                    <xsl:text>daox</xsl:text>
                                    <xsl:value-of select="$path" />
                                    <xsl:text>grp</xsl:text>
                                    <xsl:value-of select="$number" />
                                    <xsl:text>|title</xsl:text>
                                    <xsl:value-of select="position()" />
                                </xsl:attribute>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="@title" />
                                </xsl:attribute>
                            </input>
                        </td>
                    </tr>
                    <input type="hidden" value="reference">
                        <xsl:attribute name="name">
                            <xsl:text>daox</xsl:text>
                            <xsl:value-of select="$path" />
                            <xsl:text>grp</xsl:text>
                            <xsl:value-of select="$number" />
                            <xsl:text>|role</xsl:text>
                            <xsl:value-of select="position()" />
                        </xsl:attribute>
                        <xsl:attribute name="id">
                            <xsl:text>daox</xsl:text>
                            <xsl:value-of select="$path" />
                            <xsl:text>grp</xsl:text>
                            <xsl:value-of select="$number" />
                            <xsl:text>|role</xsl:text>
                            <xsl:value-of select="position()" />
                        </xsl:attribute>
                    </input>
                </xsl:for-each>
                <tr>
                    <td></td>
                    <td>
                        <a class="smalllink">
                            <xsl:attribute name="onclick">
                                <xsl:text>addFile('daoformx</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            add another file
                        </a>
                    </td>
                </tr>
                <tr>
                    <td class="label">Description of group: </td>
                    <td>
                        <input size="60" type="text" onfocus="setCurrent(this);"
                            class="menuField" onkeypress="validateFieldDelay(this, 'true');"
                            onchange="validateField(this, 'true');"
                            onblur="validateField(this, 'true');">
                            <xsl:attribute name="name">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:text>daox</xsl:text>
                                <xsl:value-of select="$path" />
                                <xsl:text>grp</xsl:text>
                                <xsl:value-of select="$number" />
                                <xsl:text>|desc</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="daodesc">
                                        <xsl:apply-templates select="daodesc" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&lt;p&gt;&lt;/p&gt;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>


    <xsl:template match="daodesc">
        <xsl:apply-templates />
    </xsl:template>

</xsl:stylesheet>

