require "marc"
require_relative "./solr_record.rb"

class SolrRecords

  def initialize
    initialize_data
  end

public

  def write_solr_xml_file
    puts "Writing solr file."
    File.open("data/solr.xml", "w"){ |f| f.print self.to_xml }
  end

  def to_xml
    xml_record = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add>"
    @solr_records.each{ |record| xml_record+=record.to_xml }
    xml_record +="</add>"
  end

  def process_main_data
    read_data
    create_solr_records
  end

  def process_additional_data
    @solr_records.each do |solr_record|
      check_bad_dates(solr_record)
      check_bad_issns(solr_record)
    end
  end

private

  def check_bad_dates(solr_record)
    if @bad_dates[solr_record.issnPrint] then
      solr_record.bad_dates = "true"
      solr_record.pubDateNotes = @bad_dates[solr_record.issnPrint]
    end
  end

  def check_bad_issns(solr_record)
    if @bad_issns[solr_record.issnPrint] then
      solr_record.bad_issn = "true"
      solr_record.bad_issn_statement = @bad_issns[solr_record.issnPrint]
    end
  end

 def initialize_data
    @matched_records = []
    @bad_dates = {}
    @marc_records = []
    @solr_records = []
    @bad_issns = {}
    @catkeys = {}
    @summary_holdings = {}
  end

  def read_data
    read_matched_records
    read_marc_records
    read_summary_holdings
    read_bad_issns
  end


  def read_matched_records
    File.open("data/matchissn.txt").each_line do |line|
      catkey, issn, statement = line.split("|")
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
      solr_record.populate_with(marc_record)
      solr_record.add_summary_holdings(@summary_holdings[solr_record.object_id.to_s]) if @summary_holdings[solr_record.object_id.to_s]
      solr_record.catkey=@catkeys[solr_record.issnPrint] if solr_record.issnPrint
      parse_matched_records(marc_record, solr_record)
      @solr_records << solr_record.populate_with(marc_record) 
    end
  end

  def parse_matched_records(marc_record, solr_record)
    if marc_record['022'] && @matched_records.include?(marc_record['022']['a'])
      solr_record.updated="updated by sfx2sirsi"
    elsif marc_record['022'] && @bad_dates.include?(marc_record['022']['a'])
      solr_record.updated="processed by sfx2sirsi but not updated"
    else
      solr_record.updated="not processed by sfx2sirsi / not updated"
    end
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
