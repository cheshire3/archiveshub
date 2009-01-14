#
# Script:      htmlFragments.py
# Version:     0.07
# Date:        19 September 2008
# Copyright:   &copy; University of Liverpool 2005-2008
# Description:
#            HTML fragments used by Cheshire for Archives
#
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
#            CS - Catherine Smith <catherine.smith@liv.ac.uk>
#
# Version History:
# 0.01 - 03/01/2006 - JH - HTML Fragments migrated from localConfig.py
# 0.02 - 06/08/2007 - CS - rename_notes added
# 0.03 - 26/09/2007 - JH - Mods to component search display to accomodate hierarchy of titles
#                        - Folder tags added
# 0.04 - 30/10/2007 - CS - Config code for superuser and user added/modified
# 0.05 - 11/01/2008 - CS - javascript call to collapseLists function changed to createTreeFromList()
# 0.06 - 23/07/2008 - JH - Javascript show / hide made to degrade more gracefully when JS absent
# 0.07 - 19/09/2008 - JH - Pop-up slash screens removed permanently
#
# NB:
# - If you are not experieced in editing HTML you are advised not to edit any of the HTML fragments
# - Modifying placeholder words (block caps enclosed in '%' e.g. %TITLE%) WILL SERIOUSLY affect the functionality of the system.
#
# Changes to original:
# You should make a note of any changes that you make to the originally distributed file here.
# This will make it easier to remeber which fields need to be modified next time you update the software.
#
#
#

# img tags for icons used in results
# - N.B. These will only be displayed if the result_graphics switch is set to 1
full_tag = '<img src="/images/v3_full.gif" alt="Full"/>'
email_tag = '<img src="/images/v3_email.gif" alt="e-mail"/>'
similar_tag = '<img src="/images/v3_simlr.gif" alt="Similar"/>'

folder_closed_tag = '<img src="/images/folderClosed.jpg" alt="[+]"/>'
folder_open_tag = '<img src="/images/folderOpen.jpg" alt="[-]"/>'

# Result rows
browse_result_row = '''
    <tr class="%ROWCLASS%">
      <td class="term">
        <a href="SCRIPT?operation=search&amp;fieldidx1=%IDX%&amp;fieldrel1=%REL%&amp;fieldcont1=%CGITERM%#leftcol" title="Find matching records">%TERM%</a>
      </td>
      <td class="hitcount">%COUNT%</td>
    </tr>'''

subject_resolve_row = '''
    <tr class="%ROWCLASS%">
      <td>
        <a href="SCRIPT?operation=search&amp;fieldidx1=dc.subject&amp;fieldrel1=exact&amp;fieldcont1=%CGISUBJ%#leftcol" title="Find records with matching subjects">%TITLE%</a>
      </td>
      <td class="relv">%RELV%</td>
      <td class="hitcount">%COUNT%</td>
    </tr>'''

search_result_row = '''
    <tr>
      <td class="hit">
        <table width="100%">
          <tr>
            <td colspan="4">
              <a href="SCRIPT?operation=summary&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Display record summary"><strong>%TITLE%</strong></a>
            </td>
          </tr>
          <tr>
            <td width="100">
              <a href="SCRIPT?operation=full&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Display Full-text">%FULL%</a>
            </td>
            <td width="100">
              <a href="SCRIPT?operation=email&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Send record by e-mail">%EMAIL%</a>
            </td>
            <td width="100">
              <a href="SCRIPT?operation=similar&amp;%RSID%&amp;hitposition=%HITPOSITION%#leftcol" title="Find similar records">%SIMILAR%</a>
            </td>
            <td class="relv">%RELV%</td>
          </tr>
        </table>
      </td>
    </tr>'''

    
search_component_row = '''
    <tr>
      <td class="comphit">
        <a href="#comphier%HITPOSITION%" class="jstoggle-folders">''' + folder_open_tag + '''</a><em>%PARENT%</em>
        <div class="jshide" id="comphier%HITPOSITION%">
          %HIERARCHY%
        </div>
        <table width="100%">
          <tr>
            <td colspan="4">
              <a href="SCRIPT?operation=summary&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Display record summary"><strong>%TITLE%</strong></a>
            </td>
          </tr>
          <tr>
            <td width="100">
            <a href="SCRIPT?operation=full&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Display Full-text">%FULL%</a>
            </td>
            <td width="100">
            <a href="SCRIPT?operation=email&amp;%RSID%&amp;hitposition=%HITPOSITION%#rightcol" title="Send record by e-mail">%EMAIL%</a>
            </td>
            <td width="100">
            <a href="SCRIPT?operation=similar&amp;%RSID%&amp;hitposition=%HITPOSITION%#leftcol" title="Find similar records">%SIMILAR%</a>
            </td>
            <td class="relv">%RELV%</td>
          </tr>
        </table>
      </td>
    </tr>'''
    
toc_scripts = '''
<script type="text/javascript" src="/ead/js/collapsibleLists.js"></script>
<script type="text/javascript" src="/ead/js/cookies.js"></script>
<script type="text/javascript">
  <!--
  var olf = function() { createTreeFromList('someId', getCookie('RECID-tocstate'), true, true);} ; 
  if (addLoadEvent) {
      addLoadEvent(olf);
  } else {
      window.onload = olf; 
  }
  var ulf = function() { setCookie('RECID-tocstate', stateToString('someId')); } ;
  if (addUnloadEvent) {
      addUnloadEvent(ulf);
  } else {
      window.onunload = ulf;
  }
  -->
</script>
'''

toc_scripts_printable = '''
<script type="text/javascript" src="/ead/js/collapsibleLists.js"></script>
<script type="text/javascript" src="/ead/js/cookies.js"></script>
<script type="text/javascript">
  <!--
  var olf = function() { createTreeFromList('someId', getCookie('RECID-tocstate'), true, false);} ; 
  if (addLoadEvent) {
      addLoadEvent(olf);
  } else {
      window.onload = olf; 
  }
  var ulf = function() { setCookie('RECID-tocstate', stateToString('someId')); } ;
  if (addUnloadEvent) {
      addUnloadEvent(ulf);
  } else {
      window.onunload = ulf;
  }
  -->
</script>
'''


full_record_link = ''



user_form = '''

'''

new_user_template = '''
<config type="user" id="%USERNAME%">
  <objectType>user.SimpleUser</objectType>
  <username>%USERNAME%</username>
  <flags>
    <flag>
      <object>recordStore</object>
      <value>c3r:administrator</value>     
    </flag>
    <flag>
      <object>eadDCStore</object>
      <value>c3r:administrator</value>
    </flag>
    <flag>
      <object>componentStore</object>
      <value>c3r:administrator</value>      
    </flag>
    <flag>
      <object>eadAuthStore</object>
        <value>info:srw/operation/2/retrieve</value>     
    </flag>
    <flag>
      <object>eadAuthStore</object>
        <value>info:srw/operation/1/replace</value>     
    </flag>
  </flags>
</config>'''

new_superuser_template = '''
<config type="user" id="%USERNAME%">
  <objectType>user.SimpleUser</objectType>
  <username>%USERNAME%</username>
  <flags>
    <flag>
      <object/>
      <value>c3r:administrator</value>
    </flag>
  </flags>
</config>'''


rename_notes = '''
<div id="notes">
  <strong>Notes</strong>: 
  <em>
    <ul>
      <li>You should avoid using spaces, accented characters, or punctuation in the filename. e.g. slashes, full-stops etc. Dashes are OK.</li>
      <li>as a file extension (e.g. \'sgml\', \'xml\') is essential, this will be added automatically. You may choose which of these is appropriate to the file.</li>
    </ul>
  </em>
</div>'''
#    <flag>
#      <object>eadDCStore</object>
#      <value>c3r:administrator</value>
#    </flag>
#    <flag>
#      <object>componentStore</object>
#      <value>c3r:administrator</value>      
#    </flag>
#    <flag>
#      <object>eadAuthStore</object>
#        <value>info:srw/operation/1/create</value>     
#    </flag>