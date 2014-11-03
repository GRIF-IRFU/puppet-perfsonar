puppet-perfsonar
================

puppet module that will configure a personar PS host.

Requirements :
==============

This module (in fact: perfsonar) requires that your host is correctly setup.
Especially, it will not attempt to :
- change your NTP settings
- change your network settings
- change any kernel setting

How to use :
============

Make sure you setup an epel repository on the host before starting. 
This is required for ps-PS 3.4+ wich requires nagios-plugins-all

If using a puppet master : simply include "::perfsonar" in one of your manifests AND add mandatory params in hiera, or call the class with the params.

For people not using any puppetmaster:
- yum install puppet
- git clone this repo + cd into this repo
- puppet apply --modulepath="."  -v -e 'class {::perfsonar : web_pass => "sha1stuff", admin_email=>"me@blah", ...}' 

Mandatory params currently are (see init.pp) :
- web admin password
- mesh list (not really mandatory though, but untested with no mesh...)
- administrative information

firewall configuration changes can only be done using hiera, at the moment, or by editing the params.pp class.

Administrative information is mandatory in the module, but community description was skipped on purpose : 
you can still add communities using the web interface, those won't be erased even if configured in the same config file.

Supported perfsonar versions :
==============================

None ;)

This actually works with perfsonar PS 3.4. This will change with time, as perfsonar updates may break backward compatibility.
We will probably create git branches or tags - one per perfsonar version - to keep track of changes, even if installing psPS 3.2 might 
not be wise nor easy when 3.4 is in the wild since everything is in the same repository. 

Todo :
======
Things currently not supported by this module:
- specific daemon configuration (bwctl/owamp) for those willing to customize firewall ports and thread numbers. Maybe later.

Puppet Dependencies
===================

This module depends on :

- dependency 'puppetlabs/firewall', ''
- dependency 'puppetlabs/stdlib', ''

Supported OSes
==============
Officially, none ;)

Unofficially, this seems to be working well on SL 6.5 x86_64 hosts kickstarted with foreman. No need for any specific kickstart template.

Notes
=====

IPv6 is untested at the moment, but ipv6 firewall seems to be in place.

Beware that the default policy usually is "ACCEPT", we don't change that neither for IPv4 nor IPv6.