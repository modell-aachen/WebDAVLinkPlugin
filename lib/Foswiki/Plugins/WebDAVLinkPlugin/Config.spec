#---+ Extensions
#---++ WebDAVLinkPlugin

# **BOOLEAN**
# Always show edit icons (for supported files)
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{AlwaysEnabled} = 1;

# **BOOLEAN**
# Shows a link to open the current topic's attachments as a WebDAV folder (IE only)
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{WebFolderLinkVisible} = 0;

# **BOOLEAN**
# Turn on/off warning messages on edit actions
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{ShowWarning} = 0;

# **STRING**
# Location for which the webserver exports the WebDAV extension
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{Location} = "/dav";

# **PERL**
# Filename extensions that can be used with different
# Microsoft Office applications. Each key in this hash is the name of an
# <a href="http://msdn.microsoft.com/en-us/library/bb726436.aspx">)
# Office 2007 application object class</a>, followed by a full stop and the
# name of the collection field on that type of application, and maps to
# a string containing a perl regular expression used to match the file
# extensions for this application.
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{MSApps} = {
    'Word.Documents' => 'doc|docx|docm|dot|dotm|dotx',
    'PowerPoint.Presentations' => 'ppt|pptx|pptm|pot|potx|potm|ppam|ppsx|ppsm|sldx|sldm|thmx',
    'Excel.Workbooks' => 'xls|xlsx|xlsm|xlt|xltx|xltm|xlsb|xlam'
};
