# See bottom of file for license and copyright details

package Foswiki::Plugins::WebDAVLinkPlugin;

use strict;
use Assert;

use JSON ();

use Foswiki ();
use Foswiki::Func ();

our $VERSION = '$Rev: 1206 $';
our $RELEASE = '1.6.0-/jidQrcaozxnxTDSHEh3qA';
our $SHORTDESCRIPTION = 'Automatically open links to !WebDAV resources in local applications';
our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    Foswiki::Func::registerTagHandler('WEBDAVFOLDERURL', \&_WEBDAVFOLDERURL);

    my $webdav_urls = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{URLs};
    if ($webdav_urls) {
        $webdav_urls = Foswiki::urlEncode($webdav_urls);
        my $usejqp = 0;

        if (eval "use Foswiki::Plugins::JQueryPlugin; 1;" &&
              defined &Foswiki::Plugins::JQueryPlugin::registerPlugin) {

            # Register our jQuery plugin
            Foswiki::Plugins::JQueryPlugin::registerPlugin(
                'webdavlink',
                'Foswiki::Plugins::WebDAVLinkPlugin::JQueryPlugin');
            $usejqp = 1;
        }

        my $ms_apps = Foswiki::urlEncode(JSON::to_json(
            $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{MSApps} || ''));

	my $ok_text = "OK";
	my $cancel_text = "Cancel";

       # utf8::downgrade($zone) if utf8::is_utf8($zone); # see Item9130
        Foswiki::Func::addToHEAD('WEBDAVLINKPLUGIN', <<STUFF );
<meta name="WEBDAVLINK_URLS" content="$webdav_urls" />
<meta name="WEBDAVLINK_MSAPPS" content="$ms_apps" />
<meta name="WEBDAVLINK_OK_TEXT" content="%MAKETEXT{$ok_text}%" />
<meta name="WEBDAVLINK_CANCEL_TEXT" content="%MAKETEXT{$cancel_text}%" />
STUFF
        # Create the plugin so we get the JS added to the header of
        # whatever page we are viewing.
        if ($usejqp) {
            Foswiki::Plugins::JQueryPlugin::createPlugin('webdavlink');
        } else {
	    # ASSUME THIS IS TWIKI!! Don't rely on the JQueryPlugin
            Foswiki::Func::addToHEAD(
		'WEBDAVLINKPLUGIN_JS', <<STUFF, "JQUERYPLUGIN");
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/WebDAVLinkPlugin/jquery-1.1.3.js"></script>
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/WebDAVLinkPlugin/jquery.livequery-1.0.3.js"></script>
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/WebDAVLinkPlugin/webdavlink_src.js"></script>
STUFF
        }
    } else {
        die "{Plugins}{WebDAVLinkPlugin}{URLs} must be defined and non-empty";
    }
    return 1;
}

sub _WEBDAVFOLDERURL {
    my @webdav_urls = split(
        /\|/, $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{URLs});
    $webdav_urls[0] =~ s/\/*$//;    #remove trailing slash
    return $webdav_urls[0];
}

1;
__END__

Copyright (C) 2009-2012 WikiRing http://wikiring.com

This program is licensed to you under the terms of the GNU General
Public License, version 2. It is distributed in the hope that it will
be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.

This software cost a lot in blood, sweat and tears to develop, and
you are respectfully requested not to distribute it without purchasing
support from the authors (available from webdav@c-dot.co.uk). By working
with us you not only gain direct access to the support of some of the
most experienced Foswiki developers working on the project, but you are
also helping to make the further development of open-source Foswiki
possible. 

Author: Crawford Currie http://c-dot.co.uk
