TracePing
=========

TracePing is a mod for smokeping that adds traceroute output to the output for a node.

  - TracePing uses it's own daemon for collecting information
  - TracePing uses a (very simple) SQL backend for storing data
  - TracePing is a bit of a hack.


Prerequisites
-------------

FastCGI perl interface.
Install with `yum install perl-CGI-fast`


Installation
--------------

Copy traceping.cgi to live along side smokeping.cgi & chmod 0755

```
cp smokeping.cgi /opt/smokeping/bin/traceping.cgi
chmod 0755 /opt/smokeping/bin/traceping.cgi
```

Add fgci script in www root


Modify your basepage.html file (generally in /opt/smokeping/etc) and add the traceping.js script
Source should look like:
```
<script src="js/prototype.js" type="text/javascript"></script>
<script src="js/scriptaculous/scriptaculous.js?load=builder,effects,dragdrop" type="text/javascript"></script>
<script src="js/cropper/cropper.js" type="text/javascript"></script>
<script src="js/smokeping.js" type="text/javascript"></script>
// Added script
<script src="js/traceping.js" type="text/javascript"></script>
```


```
cp /etc/smokeping/basehtml.html /etc/smokeping/basehtml.html.bak
cp basehtml.html /etc/smokeping/basehtml
```

Create the sqlite database and import the dump

```
sqlite3 test.sqlite < schema.sqlite
```

Edit the $dsn variables in traceping.cgi and traceping_daemon.pl to match your databases.

Install the POE perl module (may exist in OS repos!)

```
most distros: cpan POE DBI DBD::SQLite

ubuntu/debian: sudo apt-get install libdbi-perl libpoe-perl libdbd-sqlite3-perl libpoe-perl
RHEL/Centos 7 with EPEL repository: yum install perl-DBD-SQLite
RHEL/CentOS 8: dnf install cpan && cpan POE
```

Modify paths to smokeping config and database in traceping_daemon.pl

License
--------------

Licensed under a BSD license
```

Development funded by [Rack911](http://rack911.com)
