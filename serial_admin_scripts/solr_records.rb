require './solr_record.rb'
require 'open-uri'
require 'nokogiri'
require 'marc'
require 'date'
require 'digest/sha1'

class SolrRecords
  include ConfigModule

  attr_accessor :solr_records, :marc_records, :previous_marc_records, :hash_list, :previous_hash_list, :matched_records, :not_in_sirsi_records, :date_statements

  def initialize(options={})
    filename = options[:filename]
    mode = options[:mode]
    @args = get_vars('util.conf')
    # mode = full or incremental - use the hash methods for incremental and showstopper
   
    initialize_arrays
    
    update(filename, mode) 
  end

  def write_solr_xml_file
    f=File.open("#{@args['data_dir']}/#{@args['solr_xml']}", "w")
    f.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    f.puts "<add>"
    solr_records.each do |record|
      f.puts record.to_xml
    end
    f.puts "</add>"
    f.close
  end

  private

  def initialize_arrays
    @solr_records = []
    @marc_records = []
    @previous_marc_records = []
    @hash_list = {}
    @previous_hash_list = {}
    @matched_records = {}
    @not_in_sirsi_records = {}
    @date_statements = []
  end

  def update(filename, mode)
    read_marc_records(filename)
    create_solr_records
    read_previous_hashes
    create_hashes
    unless (previous_hash_list.eql? hash_list) && (mode=="incremental") then
      read_matchissn_records
      read_not_in_sirsi_records
      get_date_statements
      enrich_solr_records
      add_date_statements
      supply_alternate_titles
      write_hash_file
    else
      puts "Nothing to do."
    end
  end
  
  def read_marc_records(filename)
    reader = MARC::XMLReader.new(filename)
    for record in reader
      marc_records << record
    end
  end

  # These two methods can be refactored as they're near-duplicates.
  def read_matchissn_records
    File.open("#{@args['data_dir']}/#{@args['matchissn']}").each_line do |line|
      split_rec = line.split("|")
      match = Struct.new :catkey, :issn, :display_issn, :pubDateNote
      m = match.new(split_rec.first, split_rec[1].strip.downcase, split_rec[2]i.strip.downcase, split_rec[3])
      matched_records[m.display_issn] = m
    end
  end

  def read_not_in_sirsi_records
    File.open("#{@args['data_dir']}/#{@args['not_sirsi_file']}").each_line do |line|
      split_rec = line.split("|")
      match = Struct.new :object_id, :issn, :open_url, :okinsirsi
      m = match.new(split_rec.first, split_rec[1], split_rec[2], split_rec[3]) 
      not_in_sirsi_records[m.object_id] = m
    end
  end

  def get_date_statements
    File.open("#{@args['data_dir']}/#{@args['date_statements']}").each_line do |line|
      elements = {:object_id=>line.split("--").first.strip, :date_statement=>line.split("--")[1].strip}
      date_statements << elements
    end
  end

  def create_solr_records
    marc_records.each do |marc_record|
      solr_record = SolrRecord.new
      solr_record.object_id=marc_record['090']['a'] if marc_record['090']
      solr_record.okinsirsi="temp" #from notSIR
      solr_record.title=marc_record['245']['a'].gsub(">","").gsub("<", "") if marc_record['245']
      solr_record.issnPrint=marc_record['022']['a'] if marc_record['022']
      solr_record.issnElectronic=marc_record['776']['x'] if marc_record['776']

      solr_record.targets=parse_targets(marc_record)
      solr_record.singleTarget = single_target?(solr_record)
      
      solr_record.freeJournal="temp"  # still working on the logic of this
      solr_record.place=marc_record['260']['a'] if marc_record['260']
      solr_record.publisher=marc_record['260']['b'] if marc_record['260']

      solr_record.cat=categories(marc_record)
      solr_record.subcat=categories(marc_record, 'x')

      solr_record.language=language(marc_record)

      solr_record.catkey="temp" #marc_record['010']['a'].strip if marc_record['010']
      puts "#{solr_record.catkey}: #{solr_record.title}"
      solr_record.pubDateNotes="temp" #from matchissn
      solr_record.multiCatKey="false" #in matchissn - needs regexp
      solr_record.alternateCatKey=""
      solr_record.dateStatement="temp" #from Jeremy's script
      unless previous_hash_list.nil? || previous_hash_list.size==0 then 
        if previous_hash_list[solr_record.object_id] != hash_list[solr_record.object_id] then
          solr_records << solr_record
        end
      else
        solr_records << solr_record
      end
    end
  end

  def language(record)
    record['008'].to_s[-5..-3] if record['008'] 
  end

  def single_target?(record)
    record.targets.split(",").size==1
  end

  def parse_targets(record)
    targets = record.find_all{|t| ('866') === t.tag}
    target_list = []
    targets.each{|t| target_list << t['x'].to_s }
    target_list.join(", ")
  end

  def categories(record, mode='a')
    subjects=record.find_all{|s| ('650') === s.tag}
    subject_list = []
    subjects.each{ |s| subject_list << s[mode].to_s}
    subject_list.join(", ")
  end

  def enrich_solr_records
    solr_records.each do |record|
      record.catkey = matched_records[record.issnPrint].catkey
      record.pubDateNotes = matched_records[record.issnPrint].pubDateNote
      if matched_records[record.issnPrint].issn =~ /s\d{4}-\d{4}/ then record.multiCatKey=matched_records[issnPrint].issn end
      if not_in_sirsi_records[record.object_id] then 
        record.okinsirsi="true"
        record.alternateCatKey = not_in_sirsi_records[record.object_id].okinsirsi
      end
    end
  end

  def add_date_statements
    solr_records.each do |record|
      date_statements.each do |date|
        if record.object_id == date[:object_id] then record.dateStatement=date[:date_statement] end
      end
    end
  end
 

  def supply_alternate_titles
    solr_records.each do |record|
      puts record.catkey
      if record.catkey!="temp" then
        record.previousTitle = fetch_previous_title(record.catkey)
        record.laterTitle = fetch_later_title(record.catkey)
      end
    end
  end

  def fetch_previous_title(catkey)
    previous_title=""

    puts "#{@args['web_services_path']}=Primo&marcEntryFilter=FULL&titleID=#{catkey}"
    doc = Nokogiri::XML(open("#{@args['web_services_path']}=Primo&marcEntryFilter=FULL&titleID=#{catkey}"))
    marc_elements = doc.xpath("//sirsi:MarcEntryInfo", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard")
    marc_elements.each do |record|
      field = record.xpath("sirsi:entryID", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard").text

      if field == "780" then
        previous_title = record.xpath("sirsi:text", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard").text
      end
    end
    previous_title
  end
  
  def fetch_later_title(catkey)
    later_title=""
    puts "#{@args['web_services_path']}=Primo&marcEntryFilter=FULL&titleID=#{catkey}"
    doc = Nokogiri::XML(open("#{@args['web_services_path']}=Primo&marcEntryFilter=FULL&titleID=#{catkey}"))
    marc_elements = doc.xpath("//sirsi:MarcEntryInfo", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard")
    marc_elements.each do |record|
      field = record.xpath("sirsi:entryID", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard").text

        if field == "785" then
          later_title = record.xpath("sirsi:text", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard").text
        end
    end
    later_title
  end

  def create_hashes
    solr_records.each do |record|
      hash_list[record.object_id]=Digest::SHA1::hexdigest(record.to_xml) 
    end
  end

  def read_previous_hashes
    File.open("#{@args['data_dir']}/#{@args['hashes']}").each_line do |line|
      previous_hash_list[line.split(":").first.strip]=line.split(":").last.strip
    end
    previous_hash_list.each do |key,value|
      puts "#{key} is #{value}"
    end
  end

  def compare_hashes
    hash_list.eql? previous_hash_list
  end

  def write_hash_file
    f = File.open("#{@args['data_dir']}/#{@args['hashes']}", "w")
    hash_list.each do |key,value|
      f.puts "#{key}: #{value}"
    end
    f.close
  end

end
