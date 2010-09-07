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

function update_time(year,month,date,hour,minute){
	$('scrape_run_ends_1i').children
	for ( var option = 0; option < $('scrape_run_ends_1i').children.length; option++ ) {
		$('scrape_run_ends_1i').children[option].selected = false;
	}
	for ( var option = 0; option < $('scrape_run_ends_1i').children.length; option++ ) {
		if (parseInt($('scrape_run_ends_1i').children[option].value) == year){
			$('scrape_run_ends_1i').children[option].selected = true;
		}
	}
	for ( var option = 0; option < $('scrape_run_ends_2i').children.length; option++ ) {
		$('scrape_run_ends_2i').children[option].selected = false;
	}
	for ( var option = 0; option < $('scrape_run_ends_2i').children.length; option++ ) {
		if (parseInt($('scrape_run_ends_2i').children[option].value) == month){
			$('scrape_run_ends_2i').children[option].selected = true;
		}
	}
	for ( var option = 0; option < $('scrape_run_ends_3i').children.length; option++ ) {
		$('scrape_run_ends_3i').children[option].selected = false;
	}
	for ( var option = 0; option < $('scrape_run_ends_3i').children.length; option++ ) {
		if (parseInt($('scrape_run_ends_3i').children[option].value) == date){
			$('scrape_run_ends_3i').children[option].selected = true;
		}
	}
	for ( var option = 0; option < $('scrape_run_ends_4i').children.length; option++ ) {
		$('scrape_run_ends_4i').children[option].selected = false;
	}
	for ( var option = 0; option < $('scrape_run_ends_4i').children.length; option++ ) {
		if (parseInt($('scrape_run_ends_4i').children[option].value) == hour){
			$('scrape_run_ends_4i').children[option].selected = true;
		}
	}
	for ( var option = 0; option < $('scrape_run_ends_5i').children.length; option++ ) {
		$('scrape_run_ends_5i').children[option].selected = false;
	}
	for ( var option = 0; option < $('scrape_run_ends_5i').children.length; option++ ) {
		if (parseInt($('scrape_run_ends_5i').children[option].value) == minute){
			$('scrape_run_ends_5i').children[option].selected = true;
		}
	}
}