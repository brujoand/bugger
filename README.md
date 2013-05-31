Bugger
======

A simple task logger (curryntly only) for osx

As often as you feel is needed, by default every 15m, a notification shows your current task and time spent.
You can activate the notification to add a new current task and the last will be ended.
Then you can get a rapport -> Profit.

Installation
============

Get CocoaDialog from http://mstratman.github.io/cocoadialog/ and install it. (Temporary gui)

gem install terminal-notifier 
gem install SQLite3
gem install launchy

./bugadm install

And you are good to go!

Usage
=====
You should add bugadm to path, then:
bugadm (install|load|unload|reload|status|prompt|notify|rapport)

bugadm (prompt|rapport) should cover your basic needs.

TODO
====

- [x] Db rewrite to BCNF and use unixtime in stead of DateTime
- [ ] Add support for keywords
- [x] Take sleep/poweroff into account
- [x] Account for idletime
- [ ] Make platform independent

