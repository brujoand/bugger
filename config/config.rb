#! /usr/bin/env ruby

bugger_base = File.expand_path('..', File.dirname(__FILE__ ))

CONFIG = {
	'ruby_bin' => RbConfig.ruby,
	'bugger_base' => bugger_base,
	'bugger_lib' => bugger_base + '/lib',
	'bugger_db' => bugger_base + '/db/bug.db',
	'bugger_log' => '~/.bugger/bug.log',
	'bugger_intervall' => 900,
	'bugger_cocoa' => '/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog',
	'bugadm_plist' => '/Users/anders/Library/LaunchAgents/no.brujordet.bugger.plist'
}