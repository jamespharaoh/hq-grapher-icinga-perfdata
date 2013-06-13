# stub rrd update and capture data

Before do

	@rrd_updates = []

	RRD::Wrapper.stub(:update) do
		|*args|
		@rrd_updates << args.join(" ")
	end

end

Then /^it should submit the following data:$/ do
	|data_string|
	@rrd_updates.should == data_string.split("\n")
end
