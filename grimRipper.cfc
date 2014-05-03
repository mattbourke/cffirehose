component displayname="grimRipper" output="false" { 
/**
* This is will work only in Railo 4.0+
* The goal of this is so I can access pages blocked by websense or the chinese firewall when I visit China etc
* don't mention Tor, Proxy etc, if I'm in China I can't look that up, if its a internet cafe I can't change browser settings.
* with this I can simply load a blocked pages html like a news article, wikipedia etc.
* this is not intended to be fully usable to browse the entire internet.
* no license what so ever.
* this is currently 80% away from alpha :S
**/

//------------------------------------------- CONSTRUCTOR -----------------------
 
  public function init() {
  // setup structure for URLs and there alias URL
  if( ! session.keyexists("structLinks") ){
       session.structLinks = {};
    }

    if( ! session.keyexists("structURLs") ){
       session.structURLs  = {};
    }
    
  return this;
  }

//---------------------------- public methods ------------------

  public struct function getPage( required string urlToLoad
                                , urlDisplayPage = "index.cfm"
                                , ripCSS         = ""
                                , ripJavascript  = ""
                                , killImages     = "") { 
    var webpage         = "";
    var ripped          = { page = "", js = "", css = ""};
    var arrHrefs        = "";

    session.structLinks = {};
    session.structURLs  = {};

    if( len(arguments.urlToLoad) ){

      webpage     = _getURL     ( arguments.urlToLoad );
      arrHrefs    = _getHREFs   ( webpage             );
      ripped.page = _rewriteURLs( arrHrefs       = arrHrefs
                                , rippedPage     = webpage
                                , urlDisplayPage = arguments.urlDisplayPage);

      if( len(arguments.ripCSS) ){
          ripped      = _getCSS( ripped.page );
      }

      if( len(arguments.killImages) ){
          ripped.page = _setImagesToBlank(ripped.page);
      }

      if( len(arguments.ripJavascript) ){
          ripped      = _getJavascript( ripped );
      }
    }
  return ripped; 
  } 

//------------------------------------------- PRIVATE METHODS -------------------------------------------
  
  private any function _getURL( required string urlToRip ) { 
    var webPage = {};

    http method="GET" url="#replace(arguments.urlToRip, """", "", "all")#" result="webPage" resolveurl="Yes";
 
    return webPage.fileContent;
  }
    
  private any function _getHREFs( required string webpage ) { 

    var arrLinks = _getUrlsViaJavaRegExLookUp( webpage      = arguments.webPage
                                             , regExPattern = "<a[\w=\s""]+href=""https?://([-\w\.]+)+(:\d+)?(/([\w/_\-\.]*(\?+)?)?)?[""\']+");
    return arrLinks;
  } 
    
  private any function _rewriteURLs( required array  arrHrefs
                                   , required string rippedPage
                                   ,          string urlDisplayPage = "index.cfm") { 
   var rtnVariable = "";
   var countVar    = 1;
   var rippedPage  = arguments.rippedPage;
   var name        = "";
   var match       = "";

    loop array="#arrHrefs#" index="name"{
        match                           = REMatch("""https?://([-\w\._]+)+(:_\d+)?(/([-\w/\.+]*(\?\S+)?)?)?""", name);
        session.structLinks[#countVar#] = "#arguments.urlDisplayPage#?link=#countVar#&";
        session.structURLs[#countVar#]  = match[1];
        rippedPage                      = ReplaceNoCase(rippedPage, session.structURLs[#countVar#], session.structLinks[#countVar#], "all");
        countVar ++;
    }
    return rippedPage;
  }

  private any function _setImagesToBlank( required string webPage ) { 
      var imageSrcRegex = "src=""(http)?[sS:]*?[()/\w\.-]+\.(jpg|jpeg|gif|png)""";
      var webPage       = REReplaceNoCase(arguments.webPage, imageSrcRegex, "src=""""", "all");

      return webPage;
  }

  private any function _getJavascript( required struct webPage ) {     
    var js              = "";
    var countVar        = 1;
    var rippedPage      = arguments.webPage.page;
    var ripped.css      = arguments.webPage.css;

    var arrJsLinks      = _getUrlsViaJavaRegExLookUp( webpage      = rippedPage
                                                    , regExPattern = "(http)?[sS:]*?[()/\w\.-]+\.js"
                                                    );
    // lets loop over the array of found JS files and get the contents of each file
    loop array="#arrJsLinks#" index="name"{
        http method = "GET" url="#name#" result="jsContent" resolveurl="Yes";
        rippedPage  = ReplaceNoCase(rippedPage, name, "", "all");
        js          = js & " " & jsContent.fileContent;
        countVar ++;
    }

    ripped.page = rippedPage;
    ripped.js   = "<script>" & js & ";</script>";

    return ripped;
  }

  private any function _getCSS( required string webPage ) { 
    var css         = "";
    var countVar    = 1;
    var rippedPage  = arguments.webPage;
    var ripped      = { page = "" , css = ""};
    var match       = "";
    // maybe I should simply grab any url ending in .css ? or maybe commented out stuff might make it whacked
    var arrCSSLinks = _getUrlsViaJavaRegExLookUp( webpage      = arguments.webPage
                                                , regExPattern = "<link[\w\s=""'/]+href=(""|').+/>"
                                                );
    // lets loop over the array of found css files and get the contents of each file
    loop array="#arrCSSLinks#" index="name"{
        match       = REMatch("""https?://([-\w\._]+)+(:_\d+)?(/([-\w/\.+]*(\?\S+)?)?)?""", name);
        http method = "GET" url="#replace(match[1], """", "", "all")#" result="cssContent" resolveurl="Yes";
        rippedPage  = ReplaceNoCase(rippedPage, match[1], """""", "all");
        css         = css & " " & cssContent.fileContent;
        countVar ++;
    }
    ripped.page = rippedPage;
    ripped.css  = "<style type=""text/css"">" & css & "</style>";

    return ripped;
  }

  private any function _getUrlsViaJavaRegExLookUp( required string webpage
                                                 , required string regExPattern) { 
    var arrLinks   = [];

    // lets use some java to to speedup our regex matching by an average of 300%
    var objPattern = CreateObject("java","java.util.regex.Pattern").Compile(arguments.regExPattern);

    // lets grab all the matching items then place them into an array
    var objMatcher = objPattern.Matcher(arguments.webpage) ;

    loop condition = "objMatcher.Find()" {
        arrLinks.Append( objMatcher.Group() ) ;
    }

    return arrLinks;
  }

}