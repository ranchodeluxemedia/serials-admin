require "marc"
require "pp"
require "./solr_record.rb"

class SolrRecords

  def initialize
    @matched_records = []
    @bad_dates = {}
    read_matched_records
    @marc_records = []
    read_marc_records
    puts @marc_records.size
    @solr_records = []
    create_solr_records
    @bad_issns = {}
    read_bad_issns
    process_additional_data
  end

  def read_matched_records
    File.open("data/matchissn.txt").each_line do |line|
      catkey = line.split("|").first
      issn = line.split("|")[2]
      statement = line.split("|").last
      @matched_records << issn if statement.include? "Pub Dates ok"
      @bad_dates[issn] = statement if statement.include? "Bad Pub dates"
    end
  end

  def read_marc_records
    reader = MARC::XMLReader.new("data/sfxdata.xml")
    for record in reader
      if record['022']
        @marc_records << record unless @matched_records.include? record['022']['a']
      end
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
      solr_record.freeJournal="temp"  # still working on the logic of this
      solr_record.place=marc_record['260']['a'] if marc_record['260']
      solr_record.publisher=marc_record['260']['b'] if marc_record['260']
      solr_record.language=language(marc_record)
      solr_record.pubDateNotes="temp" #from matchissn
      solr_record.dateStatement="temp" #from Jeremy's script
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
        puts solr_record.pubDateNotes
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

end
