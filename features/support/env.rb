require "cucumber/rspec/doubles"

require "shellwords"
require "tmpdir"

require "hq/grapher-icinga-perfdata/script"

Before do

	# temporary directory

	@olddir = Dir.pwd
	@tmpdir = Dir.tmpdir
	Dir.chdir @tmpdir

end

After do

	# clean up temporary directory

	Dir.chdir @olddir
	FileUtils.rm_rf @tmpdir

end
