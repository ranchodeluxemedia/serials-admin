require "marc"
require_relative "../../solr_record.rb"

describe "Solr Record" do

  before :each do
    @solr_record = SolrRecord.new 
    @solr_record.object_id="90000000001"
    @solr_record.title="Test Title"
    @solr_record.issnPrint="0001-0001"
    @solr_record.issnElectronic="0002-0002"
    @solr_record.targets="Elsevier, JSTOR, ProQuest"
    @solr_record.freeJournal="restricted"
    @solr_record.language="eng"
    @solr_record.catkey="123456"
    @solr_record.pubDateNotes="Pub Dates ok"
    @solr_record.singleTarget="false"
    @solr_record.updated="updated by sfx2sirsi"
    @solr_record.bad_dates="false"
    @solr_record.bad_issn="false"
    @solr_record.bad_issn_statement=""
    @solr_record.noISSN="false"
    @solr_record.no_url=""
    #@solr_record.has_related_records="no"
    @solr_record.dateStatement="(1990)-"
    @solr_record.holdings_comparison=""
  end

  it "should be an instance of SolrRecord" do
    @solr_record.should be_an_instance_of SolrRecord
  end

  it "should populate from a marc record" do
    reader = MARC::XMLReader.new("data/sfxdata.xml")
    marc_records = []
    for record in reader
        marc_records << record
    end
    solr_from_marc = SolrRecord.new
    solr_from_marc.populate_with(marc_records.first)
    solr_from_marc.object_id.should_not be_empty
    solr_from_marc.title.should_not be_empty
  end

  it "should have an xml representation" do
    @solr_record.should respond_to :to_xml
  end

  it "should have the correct xml representation" do
    correct_xml = '<doc><field name="id">90000000001</field><field name="ua_object_id">90000000001</field><field name="ua_title">Test Title</field><field name="ua_issnPrint">0001-0001</field><field name="ua_issnElectronic">0002-0002</field><field name="ua_freeJournal">restricted</field><field name="ua_language">eng</field><field name="ua_catkey">123456</field><field name="ua_singleTarget">false</field><field name="ua_noISSN">false</field><field name="ua_updated">updated by sfx2sirsi</field><field name="ua_bad_dates">false</field><field name="ua_bad_issn">false</field><field name="ua_bad_issn_statement"></field><field name="ua_no_url"></field><field name="ua_holdings_comparison"></field><field name="ua_dateStatement">(1990)-</field><field name="ua_target">Elsevier</field><field name="ua_target">JSTOR</field><field name="ua_target">ProQuest</field><field name="ua_sirsiPubDateNotes">Pub Dates ok</field></doc>'
    @solr_record.to_xml.gsub(" ", "").should eq correct_xml.gsub(" ", "")
  end
end
