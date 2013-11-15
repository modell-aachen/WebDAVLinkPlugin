# See bottom of file for license and copyright details

package Foswiki::Plugins::WebDAVLinkPlugin::JQueryPlugin;

use strict;
use base 'Foswiki::Plugins::JQueryPlugin::Plugin';
use Assert;

our $VERSION = '$Rev: 1206 $';
our $RELEASE = '1.6.0-/jidQrcaozxnxTDSHEh3qA';

sub new {
    my $class = shift;
    my $session = shift || $Foswiki::Plugins::SESSION;
    my $src = (DEBUG) ? '_src' : '';

    my $this = bless($class->SUPER::new(
        $session,
        name => 'webdavlink',
        version => '1.1',
        author => 'Crawford Currie',
        homepage => '',
        puburl => '%PUBURLPATH%/%SYSTEMWEB%/WebDAVLinkPlugin',
        javascript => [ "webdavlink$src.js" ],
       ), $class);

    $this->{summary} = <<'HERE';
Plugin supports the opening of Web DAV hosted documents in associated
native applications.
HERE

    return $this;
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
