require "marc"
require "pp"
require "./solr_record.rb"

class SolrRecords

  def initialize
    initialize_data
    read_matched_records
    read_marc_records
    puts @marc_records.size
    read_summary_holdings
    create_solr_records
    read_bad_issns
    process_additional_data
  end

public

  def write_solr_xml_file
    f=File.open("data/solr.xml", "w")
    f.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    f.puts "<add>"
    @solr_records.each do |record|
      f.puts record.to_xml
    end
    f.puts "</add>"
    f.close
  end


private

  def initialize_data
    @matched_records = []
    @bad_dates = {}
    @marc_records = []
    @solr_records = []
    @bad_issns = {}
    @catkeys = {}
    @summary_holdings = {}
  end

  def read_matched_records
    File.open("data/matchissn.txt").each_line do |line|
      catkey = line.split("|").first
      issn = line.split("|")[2]
      statement = line.split("|").last
      @catkeys[issn] = catkey
      @matched_records << issn if statement.include? "Pub Dates ok"
      @bad_dates[issn] = statement if statement.include? "Not updated"
    end
  end

  def read_marc_records
    reader = MARC::XMLReader.new("data/sfxdata.xml")
    for record in reader
        @marc_records << record
    end
  end

 def create_solr_records
    @marc_records.each do |marc_record|
      solr_record = SolrRecord.new
      solr_record.object_id=marc_record['090']['a'] if marc_record['090']
      solr_record.title=marc_record['245']['a'].gsub(">","").gsub("<", "") if marc_record['245']
      solr_record.issnPrint=marc_record['022']['a'] if marc_record['022']
      solr_record.issnElectronic=marc_record['776']['x'] if marc_record['776']
      solr_record.targets=parse_targets(marc_record)
      solr_record.singleTarget = single_target?(solr_record)
      if @summary_holdings[solr_record.object_id.to_s]
        solr_record.freeJournal=@summary_holdings[solr_record.object_id.to_s][:free]
        unless @summary_holdings[solr_record.object_id.to_s][:summary_holdings].include? "error"
          solr_record.dateStatement=@summary_holdings[solr_record.object_id.to_s][:summary_holdings] #from Jeremy's script
        end
      end
      solr_record.language=language(marc_record)
      solr_record.pubDateNotes="temp" #from matchissn
      solr_record.catkey=@catkeys[solr_record.issnPrint] if solr_record.issnPrint
      if marc_record['022'] && @matched_records.include?(marc_record['022']['a'])
        solr_record.updated="updated by sfx2sirsi"
      elsif marc_record['022'] && @bad_dates.include?(marc_record['022']['a'])
	solr_record.updated="processed by sfx2sirsi but not updated"
      else
        solr_record.updated="not processed by sfx2sirsi / not updated"
      end
      solr_record.bad_dates = "false"
      solr_record.bad_issn = "false"
      @solr_records << solr_record
    end
  end

  def process_additional_data
    @solr_records.each do |solr_record|
      if @bad_dates[solr_record.issnPrint] then
        solr_record.bad_dates = "true" 
        solr_record.pubDateNotes = @bad_dates[solr_record.issnPrint]
      end

      if @bad_issns[solr_record.issnPrint] then
        solr_record.bad_issn = "true"
        solr_record.bad_issn_statement = @bad_issns[solr_record.issnPrint]
      end
    end
  end

  def parse_targets(record)
    targets = record.find_all{|t| ('866') === t.tag}
    target_list = []
    targets.each{|t| target_list << t['x'].to_s }
    target_list.join(", ")
  end

  def language(record)
    record['008'].to_s[-5..-3] if record['008']
  end

  def single_target?(record)
    record.targets.split(",").size==1
  end

  def read_bad_issns
    File.open("data/badissn.txt").each_line do |line|
      line.gsub!("Bad issn ", "")
      issn = line.split("|").last
      @bad_issns[issn] = line
    end
  end

  def read_summary_holdings
    @summary_holdings = eval(File.open("data/summary_holdings").read) 
  end

end
