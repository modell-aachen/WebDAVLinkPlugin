(function($) {
    $.fn.extend({
	webdav_open: function(event) {
	    // Invoked when an anchor tag that matches the requirements for
	    // a webdav link is clicked. 

            if (typeof(ActiveXObject) != 'undefined') {
		// ActiveX available; try to invoke MSAPPS

		// strip off url params
		var url = this.attr("href").replace(/\?.*?$/, "");

		var apps, appls, msapp, mscoll;
		$("meta[name='WEBDAVLINK_MSAPPS']").each(function() { 
                    apps = unescape(this.content); 
		});
		if (apps == null || apps == "") {
                    // JQuery sometimes can't see the meta tag in IE
                    if (typeof(foswiki) != 'undefined') {
			apps = unescape(foswiki.getMetaTag("WEBDAVLINK_MSAPPS"));
                    } else if (typeof(twiki) != 'undefined') {
			apps = unescape(twiki.getMetaTag("WEBDAVLINK_MSAPPS"));
                    }
                    if (apps == null || apps == '') {
			alert("No WEBDAVLINK_MSAPPS");
			return true;
                    }
		}
		appls = $.parseJSON(apps);
		for (var app in appls) {
                    var exts = new RegExp("\\.(" + appls[app] + ")$");
                    
                    if (exts.test(url)) {
			var appi = app.split('.');
			msapp = new ActiveXObject(appi[0] + '.Application');
			if (msapp != null) {
                            //alert("Opening using " + appi[1]); // debug
                            mscoll = msapp[appi[1]];
			}
			break;
                    }
		}
		if (mscoll != null) {
                    msapp.Visible = true;
                    mscoll.Open(url);
                    return false;
		}
            } else if ($.browser.mozilla) {
		// Send event to the firefox extension
		var ev = document.createEvent("Events");
		ev.initEvent("webdav_open", true, true);
		event.currentTarget.dispatchEvent(ev);
		return false;
	    }

            // Otherwise allow the event to bubble
            return true;
	}
    });

    $(document).ready(function() {
	var urls;
	$("meta[name='WEBDAVLINK_URLS']").each(
	    function () { urls = unescape(this.content); });
	
	if (urls == null || urls == '') {
	    // JQuery sometimes can't see the meta tag in IE
	    if (typeof(foswiki) != 'undefined') {
		urls = foswiki.getMetaTag("WEBDAVLINK_URLS");
	    } else if (typeof(twiki) != 'undefined') {
		urls = twiki.getMetaTag("WEBDAVLINK_URLS");
	    }
	    if (urls == null || urls == '') {
		alert("No WEBDAVLINK_URLS");
		return;
	    }
	}
        
	// Add an onclick handler to all anchor tags that match
	// the spec.
	urls = new RegExp("^(" + urls + ")");
        $('a:not(.webdav)').livequery(function(i) {
	    var $this = $(this);
	    if (urls.test(this.href)) {
                $this.addClass("webdav jqTooltip").attr(
		    "title", "Edit in native application");
                $this.click(function(e) {
		    return $this.webdav_open(e);
                });
	    }
        });
    });
})(jQuery);