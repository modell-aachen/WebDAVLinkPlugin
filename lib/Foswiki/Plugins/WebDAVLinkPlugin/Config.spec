#---+ Extensions
#---++ WebDAVLinkPlugin
# **STRING 120**
# |-separated list of URL roots for webdav servers. The first entry in this
# list will be used as the server in the "WebDAV" column in attachment tables
# when the "webdav" skin is in use.
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{URLs} = "";

# **PERL**
# Filename extensions that can be used with different
# Microsoft Office applications. Each key in this hash is the name of an
# <a href="http://msdn.microsoft.com/en-us/library/bb726436.aspx">)
# Office 2007 application object class</a>, followed by a full stop and the
# name of the collection field on that type of application, and maps to
# a string containing a perl regular expression used to match the file
# extensions for this application.
$Foswiki::cfg{Plugins}{WebDAVLinkPlugin}{MSApps} = {
    'Word.Documents' => 'doc|docx|docm|dotm',
    'PowerPoint.Presentations' => 'ppt|pptx|pptm|pot|potx|potm|ppam|ppsx|ppsm',
    'Excel.Workbooks' => 'xls|xlsx|xlsm|xlt|xltx|xltm|xlsb|xlam',
    'MSProject.Projects' => 'mpp'
};
