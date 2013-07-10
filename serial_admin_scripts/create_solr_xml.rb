require './config_module.rb'
require './solr_records.rb'
require './sirsi_only_records.rb'

include ConfigModule
args = get_vars('util.conf')

# main line
data = ARGV[0] ||= "#{args['data_dir']}/#{args['sfx_data']}"
mode = ARGV[1] ||= :full
options = {:filename=>data, :mode =>mode}

solr_records = SolrRecords.new(options)

solr_records.write_solr_xml_file

#sirsi_only_records = SirsiRecords.new("#{args['data_dir']}/#{args['notsfx']}")

#sirsi_only_records.read_not_in_sfx_file

#sirsi_only_records.write_xml_file

