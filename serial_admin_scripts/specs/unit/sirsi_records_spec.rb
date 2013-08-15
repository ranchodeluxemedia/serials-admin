require_relative "../../sirsi_only_records.rb"

describe "Sirsi Records" do

  before :each do
    @sirsi_records = SirsiOnlyRecords.new "data/notSFX.txt"
  end  

  it "should be an instance of SirsiOnlyRecords" do
    @sirsi_records.should be_an_instance_of SirsiOnlyRecords
  end

  it "should respond to write_xml_file" do
    @sirsi_records.should respond_to :write_xml_file
  end

  it "should have the correct xml representation" do
    correct_xml_records = File.open("data/sirsi.xml").read
    @sirsi_records.to_xml.should match correct_xml_records    
  end

end
