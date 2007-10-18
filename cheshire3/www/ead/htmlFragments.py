#
# Script:      htmlFragments.py
# Version:     0.03
# Date:        26 September 2007
# Copyright:   &copy; University of Liverpool 2005-2007
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
      <td>
        <a href="SCRIPT?operation=search&amp;fieldidx1=%IDX%&amp;fieldrel1=%REL%&amp;fieldcont1=%CGITERM%" title="Find matching records">%TERM%</a>
      </td>
      <td class="hitcount">%COUNT%</td>
    </tr>'''

subject_resolve_row = '''
    <tr class="%ROWCLASS%">
      <td>
        <a href="SCRIPT?operation=search&amp;fieldidx1=dc.subject&amp;fieldrel1=exact&amp;fieldcont1=%CGISUBJ%" title="Find records with matching subjects">%TITLE%</a>
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
              <a href="SCRIPT?operation=summary%RSID%&amp;hitposition=%HITPOSITION%" title="Display record summary" %SPLASH%><strong>%TITLE%</strong></a>
            </td>
          </tr>
          <tr>
            <td width="100">
              <a href="SCRIPT?operation=full%RSID%&amp;hitposition=%HITPOSITION%" title="Display Full-text" %SPLASH%>%FULL%</a>
            </td>
            <td width="100">
              <a href="SCRIPT?operation=email%RSID%&amp;hitposition=%HITPOSITION%" title="Send record by e-mail">%EMAIL%</a>
            </td>
            <td width="100">
              <a href="SCRIPT?operation=similar%RSID%&amp;hitposition=%HITPOSITION%" title="Find similar records" %SPLASH%">%SIMILAR%</a>
            </td>
            <td class="relv">%RELV%</td>
          </tr>
        </table>
      </td>
    </tr>'''

    
search_component_row = '''
    <tr>
      <td class="comphit">
        <a href="javascript:;" onclick="toggleShow(this, \'comphier%HITPOSITION%\', \'folders');">''' + folder_closed_tag + '''</a><em>%PARENT%</em>
        <div class="comphier" id="comphier%HITPOSITION%">
          %HIERARCHY%
        </div>
        <table width="100%">
          <tr>
            <td colspan="4">
              <a href="SCRIPT?operation=summary%RSID%&amp;hitposition=%HITPOSITION%" title="Display record summary" %SPLASH%><strong>%TITLE%</strong></a>
            </td>
          </tr>
          <tr>
            <td width="100">
            <a href="SCRIPT?operation=full%RSID%&amp;hitposition=%HITPOSITION%" title="Display Full-text" %SPLASH%>%FULL%</a>
            </td>
            <td width="100">
            <a href="SCRIPT?operation=email%RSID%&amp;hitposition=%HITPOSITION%" title="Send record by e-mail">%EMAIL%</a>
            </td>
            <td width="100">
            <a href="SCRIPT?operation=similar%RSID%&amp;hitposition=%HITPOSITION%" title="Find similar records" %SPLASH%>%SIMILAR%</a>
            </td>
            <td class="relv">%RELV%</td>
          </tr>
        </table>
      </td>
    </tr>'''
    

toc_scripts = '''
<script type="text/javascript" src="/javascript/collapsibleLists.js"></script>
<script type="text/javascript" src="/javascript/cookies.js"></script>
<script type="text/javascript">
  <!--
  function loadPage() {
    closeSplash();
    collapseList('someId', getCookie('RECID-tocstate'), true);
  }
  function unloadPage() {
    setCookie('RECID-tocstate', stateToString('someId'));
  }
  -->
</script>
'''

printable_toc_scripts = toc_scripts

user_form = '''

'''

new_user_template = '''
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
