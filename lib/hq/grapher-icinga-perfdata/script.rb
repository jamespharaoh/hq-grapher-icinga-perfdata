require "rrd"
require "xml"

require "hq/tools/base-script"
require "hq/tools/getopt"

module HQ
module GrapherIcingaPerfdata

class Script < Tools::BaseScript

	def main

		@status = 0

		process_args

		read_config

		@args.each do
			|filename|
			process_file filename
		end

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

			line_number = -1

			while line = file_io.gets

				line_number = line_number + 1

				timestamp_str, host, service, data_str =
					line.split ",", 4

				timestamp = timestamp_str.to_i

				data_array = parse_data data_str

				unless data_array

					@stderr.puts "Ignoring invalid data on line %s: %s" % [
						line_number + 1,
						line.strip,
					]

					@status = 10

					next

				end

				data = Hash[data_array]

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

		# empty string is easy

		return [] if rest =~ /^\s*$/

		# get next lot of data using regex

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

		return false unless match_data

		name = match_data[1] || match_data[2]
		name.gsub! "''", "'"

		value = match_data[3]

		new_rest = match_data[4] || ""

		# parse rest of string recursively

		new_rest_parsed =
			parse_data new_rest

		return false \
			unless new_rest_parsed

		# and return

		return [
			[ name, value ],
			* new_rest_parsed,
		]


	end

end

end
end
