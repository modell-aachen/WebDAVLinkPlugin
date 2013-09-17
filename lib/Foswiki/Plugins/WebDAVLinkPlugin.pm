# See bottom of file for license and copyright details

package Foswiki::Plugins::WebDAVLinkPlugin;

use strict;
use Assert;

use Error;
use JSON ();

use Foswiki ();
use Foswiki::Func ();

use Filesys::Virtual::Locks ();

our $VERSION = '1.6.2.10';
our $RELEASE = '1.6.2.10';
our $SHORTDESCRIPTION = 'Automatically open links to !WebDAV resources in local applications';
our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
  my ( $topic, $web, $user, $installWeb ) = @_;

  my $session = $Foswiki::Plugins::SESSION;
  my $request = $session->{request};
  my $path =  Encode::decode_utf8( $request->uri() );

  Foswiki::Func::registerTagHandler('WEBDAVFOLDERURL', \&_WEBDAVFOLDERURL);
  Foswiki::Func::registerTagHandler('WEBDAVICON', \&_WEBDAVICON);

  # Fix VirtualHosting
  my $server = $session->{urlHost};
  $server = $Foswiki::cfg{DefaultUrlHost} unless $server;

  # Fix WebDAV -> FQDN -> NetBIOS
  if ( $server =~ m|(http[s]?://)([\w_-]+)\..+| ) {
    $server = $1 . $2;
  }

  my $webdav_location = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{Location};
  my $webdav_url = "$server$webdav_location";
  if ( $webdav_location && $server ) {
    $webdav_url = Foswiki::urlEncode( $webdav_url );
    my $usejqp = 0;

    if ( eval "use Foswiki::Plugins::JQueryPlugin; 1;" &&
      defined &Foswiki::Plugins::JQueryPlugin::registerPlugin ) {

        # Register our jQuery plugin
        Foswiki::Plugins::JQueryPlugin::registerPlugin(
          'webdavlink',
          'Foswiki::Plugins::WebDAVLinkPlugin::JQueryPlugin');
        $usejqp = 1;
      }

      my $alwaysEnabled = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{AlwaysEnabled} || 0;
      my $webFolderLinkVisible = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{WebFolderLinkVisible} || 0;
      my $showWarning = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{ShowWarning} || 0;

      my $ms_apps = Foswiki::urlEncode(JSON::to_json(
        $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{MSApps} || ''));

      my $ok_text = "OK";
      my $cancel_text = "Cancel";

      # utf8::downgrade($zone) if utf8::is_utf8($zone); # see Item9130
      Foswiki::Func::addToHEAD('WEBDAVLINKPLUGIN', <<STUFF );
<meta name="WEBDAVLINK_URL" content="$webdav_url" />
<meta name="WEBDAVLINK_MSAPPS" content="$ms_apps" />
<meta name="WEBDAVLINK_OK_TEXT" content="%MAKETEXT{$ok_text}%" />
<meta name="WEBDAVLINK_CANCEL_TEXT" content="%MAKETEXT{$cancel_text}%" />
<meta name="WEBDAVLINK_ALWAYS_ENABLED" content="$alwaysEnabled" />
<meta name="WEBDAVLINK_SHOW_FOLDER_LINK" content="$webFolderLinkVisible" />
<meta name="WEBDAVLINK_SHOW_WARNING" content="$showWarning" />
STUFF
      # Create the plugin so we get the JS added to the header of
      # whatever page we are viewing.
      if ( $usejqp ) {
        Foswiki::Plugins::JQueryPlugin::createPlugin('cookie');
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
      die "{Plugins}{WebDAVLinkPlugin}Location} must be defined and non-empty";
  }

  return 1;
}

sub _WEBDAVFOLDERURL {
  my $server = $Foswiki::cfg{DefaultUrlHost};
  my $location = $Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{Location};
  #remove trailing slash
  $location =~ s/\/*$//;
  $server =~ s/\/*$//;
  return "$server$location";
}

sub _WEBDAVICON {
  my( $session, $params, $topic, $web, $topicObject ) = @_;

  my $fileName = $params->{_DEFAULT};
  my $db = _GETDB();
  return "icon_edit.png" unless $fileName && $db;

  my $davURL = _WEBDAVFOLDERURL;
  my $path = "$davURL/$web/$topic" . "_files/$fileName";
  $path =~ s/^((http[s]?):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/$4$6/;
  my @locks = $db->getLocks( $path, 0 );

  foreach my $lock (@locks) {
    next unless $lock->{exclusive};
    return "icon_locked.png" if $lock->{path} eq $path;
  }

  return "icon_edit.png";
}

sub _GETDB {
  my $db;

  eval {
    my $path = Foswiki::Func::getWorkArea( 'FilesysVirtualPlugin' ) . '/lockdb';
    $db = new Filesys::Virtual::Locks( $path );
  };

  return $db if $db;
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
