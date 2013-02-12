(function($) { $.fn.extend( {
	webdav_open: function( e ) {
	    // Invoked when an anchor tag that matches the requirements for
	    // a webdav link is clicked. 

        if ( typeof(ActiveXObject) != 'undefined' ) {
			// ActiveX available; try to invoke MSAPPS

			// strip off url params
			var url = this.attr( "href" ).replace( /\?.*?$/, "" );

			var apps, appls, msapp, mscoll;
			$( "meta[name='WEBDAVLINK_MSAPPS']" ).each( function() { apps = unescape( this.content ); } );
			if ( apps == null || apps == "" ) {
				// JQuery sometimes can't see the meta tag in IE
				if ( typeof(foswiki) != 'undefined' ) {
					apps = unescape( foswiki.getMetaTag( "WEBDAVLINK_MSAPPS" ) );
				} else if ( typeof(twiki) != 'undefined' ) {
					apps = unescape( twiki.getMetaTag( "WEBDAVLINK_MSAPPS" ) );
				}
                
				if ( apps == null || apps == '' ) {
					alert( "No WEBDAVLINK_MSAPPS" );
					return true;
				}
			}
			
			appls = $.parseJSON( apps );
			for ( var app in appls ) {
				var exts = new RegExp( "\\.(" + appls[app] + ")$" );
				if ( exts.test( url ) ) {
					var appi = app.split('.');
					msapp = new ActiveXObject( appi[0] + '.Application' );
					if ( msapp != null ) {
						//alert("Opening using " + appi[1]); // debug
						mscoll = msapp[appi[1]];
					}
					
					break;
				}
			}
			
			if ( mscoll != null ) {
				msapp.Visible = true;
				mscoll.Open( url );
				return false;
			}
		} else if ( $.browser.mozilla ) {
			// Send event to the firefox extension
			var ev = document.createEvent("Events");
			ev.initEvent("webdav_open", true, true);
			e.currentTarget.dispatchEvent(ev);
			
			return false;
		}

		// Otherwise allow the event to bubble
		return true;
	},
	
	setCookie: function( value ) {
	    $.cookie( "MODAC_WEBDAV", value, { path: "/" } );
	},
	
	getCookie: function() {
		if ( $.cookie( "MODAC_WEBDAV" ) == undefined ) {
			var value = $(this).isAlwaysEnabled() ? "1" : "0";
			$(this).setCookie( value );
		}
		
		return $.cookie( "MODAC_WEBDAV" );
	},
	
	isWarningEnabled: function() {
		return $( "meta[name='WEBDAVLINK_SHOW_WARNING']" ).attr( "content" ) == 1;
	},
	
	isFolderLinkVisible: function() {
		return $( "meta[name='WEBDAVLINK_SHOW_FOLDER_LINK']" ).attr( "content" ) == 1;
	},
	
	isAlwaysEnabled: function() {
		return $( "meta[name='WEBDAVLINK_ALWAYS_ENABLED']" ).attr( "content" ) == 1;
	},
	
	isEnabled: function() {
		return $(this).getCookie() == "1";
	},
	
	toggleWebDAVLinkVisibility: function( setCookie ) {
		var folderLink = $( "#webdav-folder" );
		if ( $(this).isAlwaysEnabled() ) {
			$( "#webdav-link" ).hide();
			$(this).isFolderLinkVisible() ? folderLink.show() : folderLink.hide();
			return;
		}

		var isEnabled = $(this).isEnabled();
		if ( setCookie ) {
			var newVal = !isEnabled ? "1" : "0";
			$(this).setCookie( newVal );
			isEnabled = !isEnabled;
		}
		
		if ( isEnabled ) {
			$('#webdav-enable-text').hide();
			$('#webdav-disable-text').show();
			$('a.webdav-entry').show();
			var hideFolder = $(this).isFolderLinkVisible() == false;
			hideFolder ? folderLink.hide() : folderLink.show();
		} else {
			$('#webdav-enable-text').show();
			$('#webdav-disable-text').hide();
			$( "#webdav-folder" ).hide();
			$('a.webdav-entry').hide();
		}
	}
});

    $( document ).ready( function() {
		$(this).toggleWebDAVLinkVisibility( false );
	
		$('#webdav-link').click( function( e ) {
			var isAlwaysEnabled = $(this).isAlwaysEnabled();
			var isEnabled = $(this).isEnabled();
			var showWarning = $(this).isWarningEnabled();

			var condition = !isAlwaysEnabled && !isEnabled && showWarning;
			
			if ( condition ) {
				var ok_text = $("meta[name='WEBDAVLINK_OK_TEXT']").attr( "content" );
				var cancel_text = $("meta[name='WEBDAVLINK_CANCEL_TEXT']").attr( "content" );
				var dialog = $('#webdav-dialog').dialog( {
					modal: true, 
					closeOnEscape: true,
					buttons: [ 
						{ text: ok_text, click: function() { $(this).toggleWebDAVLinkVisibility( true ); $(this).dialog( 'close' ); } },
						{ text: cancel_text, click: function() { $(this).dialog( 'close' ); } }
					]
				} );
				dialog.dialog( 'open' );
			} 
			
			if ( isEnabled || !showWarning ) {
				$(this).toggleWebDAVLinkVisibility( true );
			}
			
			return e.preventDefault ? e.preventDefault() : false;
		});

		var urls;
		$("meta[name='WEBDAVLINK_URLS']").each( function () { urls = unescape( this.content ); });
		
		if ( urls == null || urls == '' ) {
			// JQuery sometimes can't see the meta tag in IE
			if ( typeof(foswiki) != 'undefined' ) {
				urls = foswiki.getMetaTag( "WEBDAVLINK_URLS" );
			} else if ( typeof(twiki) != 'undefined' ) {
				urls = twiki.getMetaTag( "WEBDAVLINK_URLS" );
			}
			
			if ( urls == null || urls == '' ) {
				alert( "No WEBDAVLINK_URLS" );
				return;
			}
		}
        
		// Add an onclick handler to all anchor tags that match the spec.
		urls = new RegExp( "^(" + urls + ")" );
        $('a.webdav-entry').livequery( function(i) {
			var $this = $(this);
			if ( urls.test( this.href ) ) {			
				var dot = this.href.lastIndexOf( "." );
				if ( dot > 0 )
				{
					var apps, hasHandler = false;
					$( "meta[name='WEBDAVLINK_MSAPPS']" ).each( function() { apps = unescape( this.content ); } );
					apps = $.parseJSON( apps );
					for ( var app in apps ) {
						var exts = new RegExp( "\\.(" + apps[app] + ")$" );
						if ( exts.test( this.href ) ) {
							hasHandler = true;
							break;
						}
					}

					if ( !hasHandler )
					{
						var img = $this.find('img');
						var imgSrc = img.attr('src');
						var index = imgSrc.lastIndexOf( "/" );
						var newSrc = imgSrc.substring( 0, 1 + index ) + "icon_empty.png";
						img.attr( 'src', newSrc );
						$this.replaceWith( img );
					} else {
						$this.click( function(e) { return $this.webdav_open(e); } );
					}
				}
			}
        });
	});
})(jQuery);
