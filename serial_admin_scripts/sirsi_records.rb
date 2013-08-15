require_relative './sirsi_record.rb'
require_relative './config_module.rb'

class SirsiRecords
  include ConfigModule

  attr_accessor :sirsi_records

  def initialize(infile)
    @args = get_vars('util.conf')
    @filename = infile
    read_not_in_sfx_file
  end

  def write_xml_file
    puts @sirsi_records.size
    f=File.open("#{@args['data_dir']}/#{@args['sirsi_xml']}", "w")
    f.print to_xml
    f.close
  end

  def to_xml
    xml_records = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    xml_records += "<add>"
    @sirsi_records.each do |record|
      xml_records += record.to_xml
    end
    xml_records+="</add>"
  end

  private 

  def read_not_in_sfx_file
    @sirsi_records = []
    File.open(@filename).each_line do |line|
      line = line.gsub("\n", "").gsub("\r", "")
      split_rec = line.split("|")
      rec = {:issn=>split_rec.first, :catkey=>split_rec[2], :link_text=>split_rec[3]}
      sirsi_record = SirsiRecord.new(rec)
      @sirsi_records << sirsi_record
    end
  end
end
