Given /^a file "(.*?)":$/ do
	|file_name, file_contents|

	File.open file_name, "w" do
		|file_io|
		file_io.print file_contents
	end

end

When /^I run hq-grapher-icinga-perfdata "(.*?)"$/ do
	|args_string|

	@script = HQ::GrapherIcingaPerfdata::Script.new
	@script.args = Shellwords.split args_string

	@rrd_updates = []
	RRD::Wrapper.stub(:update) do
		|*args|
		@rrd_updates << args.join(" ")
	end

	@script.main

end

Then /^it should submit the following data:$/ do
	|data_string|
	@rrd_updates.should == data_string.split("\n")
end
