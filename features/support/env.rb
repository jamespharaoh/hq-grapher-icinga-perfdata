require "cucumber/rspec/doubles"

require "hq/cucumber/command"
require "hq/cucumber/temp-dir"

require "rrd"

require "hq/grapher-icinga-perfdata/script"

$commands["hq-grapher-icinga-perfdata"] =
	HQ::GrapherIcingaPerfdata::Script
