require_relative "../../solr_records.rb"

describe SolrRecords do

  before :each do
    @solr_records = SolrRecords.new    
  end

  it "should be an instance of SolrRecords" do
    @solr_records.should be_an_instance_of SolrRecords
  end

  it "should respond to to_xml" do
    @solr_records.should respond_to :to_xml
  end 

  it "should create records" do
    @solr_records.process_main_data
    @solr_records.to_xml.should_not be_empty
    @solr_records.to_xml.should include("id")
    @solr_records.to_xml.should include("object_id")
  end

  it "should respond to write_solr_xml_file" do
    @solr_records.should respond_to :write_solr_xml_file
  end

  it "should produce a correct solr xml file" do
    correct_xml = File.open("data/correct.xml").read
    @solr_records.process_main_data
    @solr_records.to_xml.should eq correct_xml
  end
  
end
