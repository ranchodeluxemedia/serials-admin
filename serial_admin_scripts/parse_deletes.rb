require 'nokogiri'
require './solr_record.rb'
require './config_module.rb'

include ConfigModule
args = get_vars('util.conf')

def get_object_id(n)
  if n.attribute("tag") == "090"
    subfield = Nokogiri::XML(n.inner_xml).remove_namespaces!
    return subfield.xpath("/subfield").text
  else
    return nil
  end
end
 
previous_records = Nokogiri::XML::Reader(open("#{args['data_dir']}/#{args['previous_sfx_data']}"))
previous_record_ids = []
current_records = Nokogiri::XML::Reader(open("#{args['data_dir']}/#{args['sfx_data']}"))
current_record_ids = []

previous_records.each do |node|
  previous_record_ids << get_object_id(node) unless get_object_id(node).nil? || get_object_id(node) == ""
end

current_records.each do |node|
  current_record_ids << get_object_id(node) unless get_object_id(node).nil? || get_object_id(node) == ""
end

f = File.open("#{args['data_dir']}/#{args['deleted_records']}", "w")
f.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add>"

previous_record_ids.each do |id|
  if current_record_ids.include?(id) then
    f.puts "<doc><field name=\"id\">#{id}</field><field name=\"deleted\">true</field></doc>"
  end
end

f.puts "</add>"
f.close
