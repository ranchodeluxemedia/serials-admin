require './config_module.rb'
require './solr_records.rb'

include ConfigModule
args = get_vars('util.conf')

# main line
data = ARGV[0] ||= "#{args['data_dir']}/#{args['sfx_data']}"
mode = ARGV[1] ||= :full
options = {:filename=>data, :mode =>mode}

solr_records = SolrRecords.new

solr_records.write_solr_xml_file


