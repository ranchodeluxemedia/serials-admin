require './config_module.rb'
require './solr_record.rb'
require './solr_records.rb'

include ConfigModule
args = get_vars('util.conf')

#puts "Fetching previous day's data..."
#`ruby fetch_previous_sfx_data.rb`

#puts "Fetching today's data..."
#`ruby fetch_sfx_data.rb`

previous_records = SolrRecords.new("#{args['data_dir']}/#{args['previous_sfx_data']}")
previous_records.read_marc_records
current_records = SolrRecords.new("#{args['data_dir']}/#{args['sfx_data']}")
current_records.read_marc_records

puts "Previous:"
puts current_records.marc_records.size
puts "Current:"
puts previous_records.marc_records.size

previous_records.marc_records.each do |this|
  current_records.marc_records.each do |other|  #These nested loops will take forever - better off with a hash.
    if this.object_id == other.object_id then
      puts this==other
    end
  end
end




