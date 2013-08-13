require './config_module.rb'
require './solr_records.rb'
require './sirsi_only_records.rb'

include ConfigModule
args = get_vars('util.conf')

# main line
data = ARGV[0] ||= "#{args['data_dir']}/#{args['sfx_data']}"
mode = ARGV[1] ||= :full

#solr_records = SolrRecords.new

#solr_records.write_solr_xml_file

sirsi_records = SirsiOnlyRecords.new("data/notSFX.txt")



