require_relative "../../sirsi_only_record.rb"

describe "Sirsi Only Record" do

  before :each do
    options = {:issn=>"0001-0001", :catkey=>"55555", :link_text=>"University of Alberta Access"}
    @sirsi_record = SirsiOnlyRecord.new options
  end

  it "should be an instance of SirsiOnlyRecord" do
    @sirsi_record.should be_an_instance_of SirsiOnlyRecord
  end

  it "should have an xml representation" do
    @sirsi_record.should respond_to :to_xml
  end

  it "should have the correct xml representation" do
    correct_xml = "<doc><field name=\"id\">55555</field><field name=\"ua_issnPrint\">0001-0001</field><field name=\"ua_catkey\">55555</field><field name=\"ua_link_text\">University of Alberta Access</field><field name=\"ua_inSirsi\">true</field></doc>"
    @sirsi_record.to_xml.should match correct_xml
  end
end
