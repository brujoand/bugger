Bugger
======

A simple task logger for osx

As often as you feel is needed, by default every 15m, a notification shows your current task and time spent.
You can activate the notification to add a new current task and the last will be ended.
Then you can get a rapport -> Profit.

# Installation OSX

```
$ [sudo] brew install qt
$ [sudo] gem install qtbindings
$ [sudo] gem install terminal-notifier
$ [sudo] gem install SQLite3
$ [sudo] gem install launchy
$ ./bugadm install
```

And you are good to go!

# Usage

You should add bugadm to path, then:
bugadm (install|load|unload|reload|status|prompt|notify|rapport)

bugadm (prompt|rapport) should cover your basic needs.

# TODO

- [x] Db rewrite to BCNF and use unixtime instead of DateTime
- [ ] Add support for keywords
- [x] Take sleep/poweroff into account
- [x] Account for idletime
- [ ] Allow task switching from cli/githooks



# The new flow

launchctl set intervall to 180 (3min)
check if we have an active task, if not check for idle then check if we need to notify (15min)
  -> result is always at least on of the three, or at most all of them. # This is where the bugs live 
idletask can be active even if another task is active
we should be able to autocomplete with qt now.
maybe use mongodb? # why?




