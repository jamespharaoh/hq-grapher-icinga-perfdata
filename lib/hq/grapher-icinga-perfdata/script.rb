require "rrd"
require "xml"

require "hq/tools/getopt"

module HQ
module GrapherIcingaPerfdata

class Script

	attr_accessor :args
	attr_accessor :status

	attr_accessor :stdout
	attr_accessor :stderr

	def main

		process_args

		read_config

		@args.each do
			|filename|
			process_file filename
		end

		@status = 0

	end

	def process_args

		@opts, @args =
			Tools::Getopt.process @args, [

			{ :name => :config,
				:required => true },

		]

	end

	def read_config

		config_doc =
			XML::Document.file @opts[:config]

		@config_elem =
			config_doc.root

		@daemon_elem =
			@config_elem.find_first("daemon")

		@mappings = Hash[
			@config_elem.find("mapping").map {
				|mapping_elem|
				[
					{
						host: mapping_elem["host"],
						service: mapping_elem["service"],
					},
					{
						name: mapping_elem["name"],
						values: mapping_elem.find("value").map {
							|value_elem|
							value_elem["name"]
						}
					},
				]
			}
		]

	end

	def process_file filename

		File.open filename, "r" do
			|file_io|

			while line = file_io.gets

				timestamp_str, host, service, data_str =
					line.split ",", 4

				timestamp = timestamp_str.to_i

				data = Hash[
					parse_data(data_str),
				]

				mapping_key = {
					host: host,
					service: service,
				}

				mapping = @mappings[mapping_key]

				next unless mapping

				RRD::Wrapper.update \
					"--daemon",
					"%s:%s" % [
						@daemon_elem["host"],
						@daemon_elem["port"],
					],
					"%s.rrd" % mapping[:name],
					[
						timestamp_str,
						* mapping[:values].map { |name| data[name] || "U" },
					].join(":")

			end

		end

	end

	def parse_data rest

		return [] if rest =~ /^\s*$/

		regexp =
			/^
				(?:
					([^' ]+)
				|
					'((?:[^']|'')*)'
				) =
				(-?\d+(?:\.[\d]+)?)
				(?:\S*)
				(?:\s(.+))?
			$/x

		match_data = regexp.match rest

		return nil unless match_data

		name = match_data[1] || match_data[2]
		name.gsub! "''", "'"

		value = match_data[3]

		new_rest = match_data[4]

		return [
			[ name, value ],
			* new_rest ? parse_data(new_rest) : [],
		]

	end

end

end
end
