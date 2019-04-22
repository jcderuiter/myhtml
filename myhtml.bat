@echo off
setlocal

set title=unnamed
goto :cmdline

:usage            `
if not -%1==- echo>&2 %*
echo>&2 usage: %~n0 [-0] [-m] [title]
echo>&2        creates title.htm
echo>&2        options:
echo>&2        -0: minimal (no fancy stuff)
echo>&2        -m: js and css in separate files (title.js and title.css)
echo>&2        default title: %title%
exit /B 1

:cmdline
set args= %*                     &:: die spatie moet er bij, anders probleem bij lege %*
set args=%args:"=""%             &:: replace " by "", anders gaat if ".." mis
if "%args:-?=%" equ "%args%" goto :args
call :usage & exit /B 1          &:: -? zat in args

:args
rem todo: invullen of weg
set minimal=false
set multi=false

:argsloop
if "%~1"=="" goto :main          &:: die ~ erbij om quotes te verwijderen
if "%~1"=="-0" set minimal=true& goto :next
if "%~1"=="-m" set multi=true& goto :next
set title=%~1
:next
shift
goto :argsloop

:main                            &:: geen space . # in name (css: .class #id)
set name=%title: =_%
set name=%name:.=_%
set name=%name:#=_%


rem CSS
set cssparts=css_copy
if not "%minimal%"=="true" set cssparts=css_doc css_grid css_info css_sections css_listings css_refs %cssparts%

rem JS
set jsparts=js_top
if not "%minimal%"=="true" set jsparts=%jsparts% js_listings_onload js_refs_onload js_sections_onload
set jsparts=%jsparts% js_copy
if not "%minimal%"=="true" set jsparts=%jsparts% js_listings js_refs js_sections
set jsparts=%jsparts% js_bot

rem HTML
set htmlparts=html_head
if not "%minimal%"=="true" set htmlparts=%htmlparts% html_math
if "%multi%"=="true" (set htmlparts=%htmlparts% html_multi_css html_multi_js) else set htmlparts=%htmlparts% css_start %cssparts% css_end js_start %jsparts% js_end
set htmlparts=%htmlparts% html_body
if "%minimal%"=="true" (set htmlparts=%htmlparts% html_copy) else set htmlparts=%htmlparts% html_content
set htmlparts=%htmlparts% html_end


if not "%multi%"=="true" goto :htmlfile
:jsfile
echo *** creating %name%.js ...
call :createparts %jsparts% >%name%.js
:cssfile
if "%cssparts%"=="" goto :htmlfile
echo *** creating %name%.css ...
call :createparts %cssparts% >%name%.css
:htmlfile
echo *** creating %name%.htm ...
call :createparts %htmlparts% >%name%.htm
goto :done

:createparts
for %%a in (%*) do call :%%a
exit /B 0


:done
echo *** ... done, starting %name%.htm ...
start %name%.htm
echo *** ... have fun!
endlocal
exit /B 0


:html_head
echo:^<!doctype html^>
echo:^<html lang="nl"^>
echo:^<head^>
echo:^<meta http-equiv="expires" content="now"/^>
echo:^<meta name="viewport" content="width=device-width, initial-scale=1.0"/^>
echo:^<meta name="version" content="0.0.0"/^>
echo:^<title^>%title%^</title^>
exit /B 0

:html_body
echo:^</head^>
echo:^<body^>
echo:
exit /B 0

:html_end
echo:^</body^>
echo:^</html^>
exit /B 0

:html_multi_css
echo:^<link rel="stylesheet" href="%name%.css" type="text/css"/^>
exit /B 0

:html_multi_js
echo:^<script src="%name%.js"^>^</script^>
exit /B 0

:html_math
echo:^<!--
echo:^<script type="text/x-mathjax-config"^>
echo:   MathJax.Hub.Config({ tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']], processEscapes: true},
echo:                        TeX:     {extensions: ["extpfeil.js"]}
echo:                     });
echo:^</script^>
echo:^<script type="text/javascript" async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-AMS_CHTML"^>
echo:// http://docs.mathjax.org/en/latest/start.html
echo:^</script^>
echo:--^>
exit /B 0

:html_copy
echo:
echo:^<div class="my-copy"^>^</div^>
exit /B 0

:html_content
echo:^<div class="my-container"^>
echo:
echo:^<div class="my-header"^>^</div^> ^<!-- my-header --^>
echo:^<div class="my-left"^>
echo:^<ul class="my-sections" id="my-sections"^>^</ul^>
echo:^</div^> ^<!-- my-left --^>
echo:
echo:^<div class="my-main"^>
echo:
echo:Dit is een
echo:^<a href="#myref_wiki" class="my-refs-ref"^>referentie^</a^>.
echo:^<br/^>
echo:^<br/^>
echo:Een ^<label for="info_1" class="jcr-info"^>info^</label^> blok
echo:^<br/^>
echo:dat tussen
echo:^<input id="info_1" class="jcr-info" type="checkbox"/^>
echo:^<div class="jcr-info"^>
echo:^<label for="info_1" class="jcr-info"^>^</label^>
echo:Hier kwam geen JavaScript aan te pas!
echo:^</div^>
echo:deze regels komt.
echo:^<h4 class="center"^>^&#x2744;^&#x2744;^&#x2744;^</h4^>
echo:^<h4 class="my-section" id="section_1"^>Een sectie^</h4^>
echo:
echo:^</div^> ^<!-- my-main --^>
echo:
echo:^<div class="my-right"^>^</div^> ^<!-- my-right --^>
echo:
echo:^<div class="my-footer"^>
call :html_copy
call :html_refs
echo:^</div^> ^<!-- my-footer --^>
echo:
echo:^</div^> ^<!-- my-container --^>
exit /B 0

:html_refs
echo:
echo:^<!-- references --^>
echo:^<h3 class="my-section" id="section_references"^>Referenties^</h3^>
echo:^<!-- refer as:
echo:^<a href="#ref_something" class="my-refs-ref"^>^</a^>
echo:   references in textarea:
echo:#id [author]
echo:url
echo:text
echo:[origin (website)]
echo:   separate references with empty lines
echo:--^>
echo:
echo:^<textarea class="my-refs-list"^>
echo:#myref_wiki
echo:https://nl.wikipedia.org/
echo:Wikipedia voorpagina
echo:Wikipedia
echo:
echo:^</textarea^> ^<!-- my-refs-list --^>
exit /B 0


:css_start
echo:^<style^>
exit /B 0

:css_end
echo:^</style^>
exit /B 0

:css_copy
echo:
echo:/* begin copyright style */
echo:.my-copy
echo:{
echo:   border-top:  hsl(0, 0%%, 20%%) thin solid;      /* */
echo:   color:       hsl(0, 0%%, 20%%);                 /* */
echo:   font-size:   0.9rem;                          /* */
echo:   text-align:  right;                           /* */
echo:   margin:      1rem 0.5rem;                     /* */
echo:   padding:     0.5rem;                          /* */
echo:   user-select: none;                            /* */
echo:}
echo:.my-copy::before { content: '\00a9 '; }          /* */
echo:.my-copy::after  { content: ' jcr'; }            /* */
echo:/* end copyright style */
exit /B 0

:css_doc
echo:
echo:*
echo:{
echo:   box-sizing:       border-box;                 /* */
echo:   font-family:      sans-serif;                 /* */
echo:}
echo:
echo:body
echo:{
echo:/* background-color: hsl(0, 0%%, 85%%);            /* */
echo:   line-height:      1.6;                        /* */
echo:}
echo:
echo:a
echo:{
echo:   text-decoration: none;                        /* */
echo:   transition:      .5s;                         /* */
echo:}
echo:a, a:visited
echo:{
echo:   color: inherit;                               /* */
echo:/* color:           hsl(  0,   0%%, 50%%);         /* */
echo:}
echo:a:hover
echo:{
echo:/* text-decoration: underline;                   /* */
echo:   color:           hsl(315, 100%%, 50%%);         /* */
echo:}
echo:
echo:.center { text-align: center; }                  /* */
echo:.nowrap { white-space: nowrap; }                 /* */
exit /B 0

:css_grid
echo:
echo:/* begin page grid style */
echo:.my-header { grid-area: my-header; }
echo:.my-left   { grid-area: my-left;   }
echo:.my-main   { grid-area: my-main;   }
echo:.my-right  { grid-area: my-right;  }
echo:.my-footer { grid-area: my-footer; }
echo:
echo:.my-container
echo:{
echo:   display:             grid;                    /* */
echo:   grid-template-areas:
echo:                        'my-header'
echo:                        'my-left'
echo:                        'my-main'
echo:                        'my-right'
echo:                        'my-footer';
echo:}
echo:
echo:.my-main
echo:{
echo:   background-color: hsl(0, 0%%, 100%%);           /* */
echo:}
echo:
echo:.my-header:not(:empty)
echo:{
echo:   margin-bottom: 1rem;                          /* */
echo:}
echo:
echo:@media screen and (orientation: landscape)
echo:{
echo:   .my-container
echo:   {
echo:      grid-template-areas:
echo:                           'my-header my-header  my-header'  /* */
echo:/*                         'my-left   my-header  my-right'   /* */
echo:                           'my-left   my-main    my-right'   /* */
echo:                           'my-footer my-footer  my-footer'; /* */
echo:/*                         'my-left   my-footer  my-right';  /* */
echo:   }
echo:
echo:   .my-main
echo:   {
echo:   /* width:         70vh;                       /* A4 */
echo:      width:         62vw;                       /* 2/(1+sqrt(5)) */
echo:      min-height:    90vh;                       /* */
echo:/*    justify-self:  center;                     /* */
echo:/*    border:        hsl(0, 0%%, 20%%) thin solid; /* */
echo:      box-shadow:    0 0 .5rem;                  /* */
echo:      border-radius: 5px;                        /* */
echo:      padding:       1rem;                       /* */
echo:   }
echo:
echo:   .my-left, .my-right
echo:   {
echo:      min-width: 15vw;                           /* */
echo:   }
echo:}
echo:/*   end page grid style */
exit /B 0

:css_info
echo:
echo:/* begin info style */
echo:/* usage:                                                                   */
echo:/* ^<label for="id" class="jcr-info"^>optional text^</label^>                   */
echo:/*    other content                                                         */
echo:/*    other content                                                         */
echo:/* ^<input id="id" class="jcr-info" type="checkbox"/^>               */
echo:/* ^<div class="jcr-info"^>                                                   */
echo:/*    other content                                                         */
echo:/* ^<label for="id" class="jcr-info"^>optional text^</label^>                   */
echo:/*    other content                                                         */
echo:/* ^</div^>                                                                   */
echo:/* the ^<div^> must be the immediate successor of the ^<input^>                 */
echo:/* the first ^<label^> gets a small 'i'                                       */
echo:/* the second ^<label^> puts a 'close cross' in the right top of the ^<div^>    */
echo:/* both labels trigger an invisible checkbox on which CSS toggles the ^<div^> */
echo:
echo:label.jcr-info
echo:{
echo:   cursor:         pointer;                      /* */
echo:}
echo:
echo:label.jcr-info::after
echo:{
echo:   content:        '\01f6c8';                    /* */
echo:   font-weight:    bolder;                       /* */
echo:   color:          hsl(240, 100%%, 050%%);         /* */
echo:   vertical-align: super;                        /* */
echo:   font-size:      smaller;                      /* */
echo:}
echo:
echo:input[type="checkbox"].jcr-info
echo:{
echo:   width:            0;                          /* */
echo:   height:           0;                          /* */
echo:}
echo:
echo:input[type="checkbox"].jcr-info + div.jcr-info
echo:{
echo:   height:           0;                          /* */
echo:   overflow:         hidden;                     /* */
echo:   padding:          0;                          /* */
echo:
echo:   position:         relative;                   /* */
echo:
echo:   background-color: hsl(060, 100%%, 090%%);       /* */
echo:   box-shadow:       0 0 .5rem;                  /* */
echo:   border-radius:    5px;                        /* */
echo:
echo:   transform:        scale(0.0);                 /* */
echo:   opacity:          0.0;                        /* */
echo:   transition:       all .5s ease-in-out;        /* */
echo:}
echo:
echo:input[type="checkbox"].jcr-info:checked + div.jcr-info
echo:{
echo:   height:           auto;                       /* */
echo:   margin:           .5rem 1rem;                 /* */
echo:   padding:          1rem;                       /* */
echo:
echo:   transform:        scale(1.0);                 /* */
echo:   opacity:          1.0;                        /* */
echo:   transition:       all 2s ease-in-out;         /* */
echo:}
echo:
echo:div.jcr-info label.jcr-info::after
echo:{
echo:   content:  '\02612';                           /* */
echo:   position: absolute;                           /* */
echo:   top:      0;                                  /* */
echo:   right:    .5rem;                              /* */
echo:}
echo:/*   end info style */
exit /B 0

:css_sections
echo:
echo:/* begin sections style */
echo:@media screen and (orientation: portrait)        /* */
echo:{
echo:   .my-sections:not(:empty)::before
echo:   {
echo:      content: 'Jump to:';                       /* */
echo:   }
echo:   .my-sections:not(:empty):lang(nl)::before
echo:   {
echo:      content: 'Meteen naar:';                   /* */
echo:   }
echo:}
echo:@media print
echo:{
echo:   .my-sections
echo:   {
echo:      display: none;                             /* */
echo:   }
echo:}
echo:/* end sections style */
exit /B 0

:css_listings
echo:
echo:/* begin listings style */
echo:ol.my-listing
echo:{
echo:   font-family:      monospace;                  /* */
echo:   text-align:       left;                       /* */
echo:   line-height:      1.2;                        /* */
echo:   white-space:      pre-wrap;                   /* */
echo:   background-color: hsl(60, 100%%, 90%%);         /* */
echo:   border-radius:    .5rem;                      /* */
echo:   padding:          .5rem 0 .5rem 3rem;         /* */
echo:}
echo:ol.my-listing li
echo:{
echo:   border-left:    thin solid black;             /* */
echo:   padding:        0 .5rem;                      /* */
echo:}
echo:
echo:ol.my-listing.table
echo:{
echo:   display: table;                               /* */
echo:/* display: inline-table;                        /* */
echo:}
echo:
echo:ol.my-listing.nolinenrs
echo:{
echo:   list-style-type: none;                        /* */
echo:   padding-left:    0;                           /* */
echo:}
echo:ol.my-listing.nolinenrs li:empty::after
echo:{
echo:   content: '\000a';                             /* */
echo:}
echo:ol.my-listing.nolinenrs li
echo:{
echo:   border-left:     initial;                     /* */
echo:}
echo:/*   end listings style */
exit /B 0

:css_refs
echo:
echo:/* begin references style */
echo:.my-refs-ref
echo:{
echo:   vertical-align: super;                        /* */
echo:   font-size:      smaller;                      /* */
echo:}
echo:.my-refs-ref::before { content: '['; }           /* */
echo:.my-refs-ref::after  { content: ']'; }           /* */
echo:.my-refs-ref,
echo:.my-refs-ref:visited
echo:{
echo:   color: hsl(000, 000%%, 050%%);                  /* */
echo:}
echo:
echo:.my-refs-list ^> * { margin-top: 0; }             /* */
echo:
echo:@media screen
echo:{
echo:   .my-refs-list
echo:   {
echo:      column-width:     25vw;                              /* */
echo:      border:           hsl(0, 0%%, 30%%) thin solid;        /* */
echo:      background-color: hsl(60, 100%%,  90%%);               /* */
echo:   }
echo:}
echo:
echo:@media print
echo:{
echo:   * { color: hsl(0, 0%%, 0%%); }                  /* */
echo:
echo:   .my-refs-cites { display: none; }             /* */
echo:   .my-refs-list a[href]::after { content: ' (' attr(href) ')'; }  /* */
echo:}
echo:
echo:.my-refs-author
echo:{
echo:   white-space:   pre-wrap;                      /* */
echo:   padding-right: .3rem;                         /* */
echo:}
echo:
echo:.my-refs-link
echo:{
echo:   font-style:    italic;                        /* */
echo:   color:         hsl(240, 100%%, 50%%);           /* */
echo:}
echo:
echo:.my-refs-origin
echo:{
echo:   font-variant: small-caps;                     /* */
echo:   white-space:  pre-wrap;                       /* */
echo:   padding-left: .3rem;                          /* */
echo:}
echo:
echo:.my-refs-cites
echo:{
echo:   white-space:  pre-wrap;                       /* */
echo:   padding-left: .3rem;                          /* */
echo:}
echo:/*   end references style */
exit /B 0


:js_start
echo:^<script^>
exit /B 0

:js_end
echo:^</script^>
exit /B 0

:js_top
echo:'use strict';
echo:const %name%_js_object = {};
echo:document.addEventListener('DOMContentLoaded', () =^> %name%_js_object.onload(), false);
echo://window.addEventListener('load', () =^> %name%_js_object.onload(), false);
echo://onload = (function(other) {  return function() {  if (other) other(); %name%_js_object.onload(); } })(onload);
echo.
echo:(function(api)
echo:{
echo:   api.onload = function()
echo:   {
echo:      try
echo:      {
exit /B 0

:js_bot
echo:})(%name%_js_object);
exit /B 0

:js_copy
echo:         let year = new Date(document.lastModified).getFullYear();
echo:         document.querySelectorAll('.my-copy').forEach(y =^> y.innerHTML = year);
echo:      }  catch(err) { console.log('oops', err) }
echo:   }
exit /B 0

:js_refs_onload
echo:         createReferences();
exit /B 0

:js_refs
echo:
echo:   const createReferences = function()
echo:   {
echo:      let refnr = 1;
echo:      let refitem = {};
echo:
echo:
echo:      // the references
echo:      for (let element of document.querySelectorAll('textarea.my-refs-list'))
echo:      {
echo:         let ol = document.createElement('ol');
echo:         ol.className = element.className;
echo:         ol.start = refnr;
echo:
echo:         for (let record of element.innerHTML.replace(/\n\s*?\n\s*/, '\n\n').split('\n\n'))
echo:         {
echo:            let [line1, url, text, origin] = record.split('\n').map(s =^> s.trim());
echo:
echo:            let [hash, ...rest] = line1.split(' ');
echo:            let author = rest.join(' ');
echo:
echo:            if (!hash.startsWith('#')) { continue }
echo:
echo:            let li = document.createElement('li');
echo:            li.id = hash.substr(1);
echo:
echo:            if (author)
echo:            {
echo:               let span_author = document.createElement('span');
echo:               span_author.className = 'my-refs-author';
echo:               span_author.innerHTML = author;
echo:               li.appendChild(span_author);
echo:            }
echo:
echo:            let span_link = document.createElement('span');
echo:            span_link.className = 'my-refs-link';
echo:
echo:            let a = document.createElement('a');
echo:            a.href = url;
echo:            a.innerHTML = text ^|^| url;
echo:            span_link.appendChild(a);
echo:            li.appendChild(span_link);
echo:
echo:            if (origin)
echo:            {
echo:               let span_origin = document.createElement('span');
echo:               span_origin.className = 'my-refs-origin';
echo:               span_origin.innerHTML = origin;
echo:               li.appendChild(span_origin);
echo:            }
echo:
echo:            ol.appendChild(li);
echo:
echo:            refitem[hash] = { item: li, refnr: refnr, cited: [] }
echo:            refnr++;
echo:         }
echo:
echo:         element.replaceWith(ol);
echo:      }
echo:
echo:      // the citations (referrals)
echo:      for (let element of document.querySelectorAll('.my-refs-ref'))
echo:      {
echo:         if (!element.hash) { continue }
echo:
echo:         let span = document.createElement('span');
echo:         span.className = 'nowrap';
echo:         span.innerHTML = element.innerHTML;
echo:
echo:         if (refitem[element.hash])
echo:         {
echo:            element.innerHTML     = refitem[element.hash].refnr;
echo:            let hash_for_citation = `${[element.hash]}_${refitem[element.hash].cited.length}`;
echo:            element.id            = hash_for_citation.substr(1);
echo:            refitem[element.hash].cited.push(hash_for_citation);
echo:         }
echo:         else
echo:         {
echo:            element.innerHTML = 'link not present';
echo:         }
echo:
echo:         element.parentNode.insertBefore(span, element);
echo:         span.appendChild(element);
echo:      }
echo:
echo:
echo:      // reduce citations array (of hashes) to string of hyperlinks
echo:      function reduceCitations(accum, next, i, all)
echo:      {
echo:         let concat = accum;
echo:         if (i) { concat += ',' }
echo:         concat += `^<a href="${next}"^>^&uarr;`;
echo:         if (all.length ^> 1) { concat += `^<sub^>${i+1}^</sub^>` }
echo:         concat += '^</a^>';
echo:
echo:         return concat;
echo:      }
echo:
echo:      // add citations to items in hyperlink list
echo:      for (let hash in refitem)
echo:      {
echo:         if (!refitem[hash].cited.length) { continue }
echo:
echo:         refitem[hash].item.innerHTML += '^<span class="my-refs-cites"^>'
echo://                                    +  '^<sub^>cited:^</sub^>'
echo:                                      +  refitem[hash].cited.reduce(reduceCitations, '')
echo:                                      + '^</span^>';
echo:      }
echo:   }
exit /B 0

:js_sections_onload
echo:         setSectionLinks();
exit /B 0

:js_sections
echo:
echo:   const setSectionLinks = function()
echo:   {
echo:      let sectionlist = document.querySelector('#my-sections');
echo:      if (sectionlist)
echo:      {
echo://       sectionlist.innerHTML += '^<li^>^<a href="/"^>Home^</a^>^</li^>';
echo:         for (let section of document.querySelectorAll('.my-section[id]'))
echo:         {
echo:            let text = section.innerHTML;
echo:            sectionlist.innerHTML += `^<li^>^<a href="#${section.id}"^>${text}^</a^>^</li^>`;
echo:
echo:            section.innerHTML = `^<a href="#"^>${text}^</a^>`;
echo:            section.title     = 'to top of page';
echo:         }
echo:      }
echo:   }
exit /B 0

:js_listings_onload
echo:         createListings();
exit /B 0

:js_listings
echo:
echo:   const createListings = function()
echo:   {
echo:      for (let element of document.querySelectorAll('textarea.my-listing'))
echo:      {
echo:         let ol = document.createElement('ol');
echo:         ol.className = element.className;
echo:
echo:         for (let line of element.innerHTML.replace(/\n$/, '').split('\n'))
echo:         {
echo:            let li = document.createElement('li');
echo:            li.innerHTML = line;
echo:            ol.appendChild(li);
echo:         }
echo:
echo:         element.replaceWith(ol);
echo:      }
echo:   }
exit /B 0
