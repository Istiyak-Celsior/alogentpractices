<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
Server.ScriptTimeout = 15 * 60
db.CommandTimeout = 0
%>
<script type="text/javascript">
    function OpenWindow(page) {
        var rndValue = Math.round(Math.random() * 10000);
        window.open(page, "CtrlWindow_" + rndValue, "toolbar=no,menubar=no,location=yes,scrollbars=yes,resizable=yes");
    }
</script>
<%
Dim uploadNavMode : uploadNavMode = 0 ' ### No checkboxes
Dim uploadNavShowDetails : uploadNavShowDetails = 0
Dim greyboxMode : greyboxMode = 0 ' ### page is not a greybox popup
dash = "y"
%>
<div class="aa-panel-header">
    <div><h3>Upload Folder Contents</h3></div>
    <div><a href="viewuploadfolder.asp">View Full Page</a></div>
</div>
<!-- #include file="../uploadnavpanel.inc" -->
<!-- #include file="../dbclose.inc" -->