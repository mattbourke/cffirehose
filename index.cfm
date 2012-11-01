<!--- TODO: alot - 
fixed up regex
.add better JS for checkboxes
.add individual sessions for tabs
.add fix so user can go back when an error or has form above error etc and session structs still fine.
.fix up javascript import so it loads in correct position/order and has correct separation between js files
.speed up processing
.add error handling
.tidy up code lol!
.last and least, other stuff lol
  --->
<cfsetting enableCFoutputOnly = "no"  requestTimeOut = "6000" showDebugOutput = "yes" >
<cfparam name="currentUrl"           default="">
<cfparam name="url.link"             default="">
<cfparam name="form.urltogo"         default="">
<cfparam name="form.ripCSS"          default="">
<cfparam name="form.ripJavascript"   default="">
<cfparam name="form.killImages"      default="">
<cfparam name="form.stealthMode"     default="">
<cfset objRipper  = createObject("component", "grimRipper").init()> 

<cfif isnumeric(link) AND session.keyExists("structURLs")>
	<cfset currentUrl = session.structURLs[url.link]>
</cfif>
<cfif len(form.urltogo)>
  <cfset currentUrl = form.urltogo>
</cfif>
<cfset rippedPage = objRipper.getPage( urlToLoad      = currentUrl
                                     , urlDisplayPage = "index.cfm"
                                     , ripCSS         = form.ripCSS
                                     , ripJavascript  = form.ripJavascript
                                     , killImages     = form.killImages
                                     )>
<form name="urlform" id="urlform" method="post" action="index.cfm">
  <cfoutput>
    <input name="urltogo"       type="text"     value="#replace(currentUrl, """", "", "all")#" id="urltogo" size="50">
    <input name="submiturl"     type="submit"   value="Load URL">

    <label for="ripCSS">External CSS</label> 
    <input name="ripCSS"        type="checkbox" value="checked" id="ripCSS" #form.ripCSS#>

    <label for="ripJavascript">External Javascript</label> 
    <input name="ripJavascript" type="checkbox" value="checked" id="ripJavascript" #form.ripJavascript#>

    <label for="killImages">Kill Images</label> 
    <input name="killImages"    type="checkbox" value="checked" id="killImages" #form.killImages#>

    <label for="stealthMode">Stealth Mode</label> 
    <input name="stealthMode"   type="checkbox" value="checked" id="stealthMode" #form.stealthMode# onclick="javascript:checkAll('urlform');">
  </cfoutput>
</form>
<cfoutput>
    #rippedPage.page#
</cfoutput>
<cfhtmlhead text="#rippedPage.css#" />
<cfsavecontent variable="checkboxJavascript">
<script language="javascript">
function checkAll(formname)
{
  var checkboxes = new Array(); 
  checkboxes = document[formname].getElementsByTagName('input');

  if(!(document.getElementById('stealthMode').checked)){                   
    var checktoggle = 0;
  }
  else {   
    var checktoggle = 1;
  }

  for (var i=0; i<checkboxes.length; i++)  {
    if (checkboxes[i].type == 'checkbox')   {
      checkboxes[i].checked = checktoggle;
    }
  }
}
</script>
<cfif rippedPage.keyExists("js")>
  <cfoutput>
    #rippedPage.js#
  </cfoutput>
</cfif>
</cfsavecontent>
<cfhtmlhead text="#checkboxJavascript#" />










