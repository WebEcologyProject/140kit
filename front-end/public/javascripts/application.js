// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var search_timeout;

function disableEnterKey(e){
     var key;
     if(window.event)
          key = window.event.keyCode;
     else
          key = e.which;
     if(key == 13)
          return false;
     else
          return true;
}