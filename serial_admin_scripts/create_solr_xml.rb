require './config_module.rb'
require './solr_records.rb'
require './sirsi_records.rb'

include ConfigModule
args = get_vars('util.conf')

# break into module or something when refactoring
def process_noissn_records
  of = File.open("data/titles.xml", "w")
  of.puts '<?xml version="1.0" encoding="UTF-8"?><add>'
  seed = 99999
  offset = 0
  File.open("data/noissn.txt").each_line do |title|
    clean_title = title.chomp.gsub("<", "(").gsub(">", ")")
    of.puts "<doc><field name=\"id\">#{seed}#{offset}</field><field name=\"ua_title\">#{clean_title}</field><field name=\"ua_noIssn\">true</field></doc>".gsub("&", "&amp;")
    offset+=1
  end
  of.puts "</add>"
  of.close
end


# main line
data = ARGV[0] ||= "#{args['data_dir']}/#{args['sfx_data']}"
mode = ARGV[1] ||= :full

# break these into rake tasks
solr_records = SolrRecords.new
solr_records.process_main_data
solr_records.process_additional_data
solr_records.write_solr_xml_file
#sirsi_records = SirsiRecords.new("data/notSFX.txt")
#sirsi_records.write_xml_file
#process_noissn_records


  




