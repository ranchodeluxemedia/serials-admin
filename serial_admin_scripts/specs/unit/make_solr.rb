require_relative "../../solr_records.rb"

s=SolrRecords.new
s.process_main_data
s.write_solr_xml_file
