require_relative "../../sirsi_records.rb"

describe "Sirsi Records" do

  before :each do
    @sirsi_records = SirsiRecords.new "data/notSFX.txt"
  end  

  it "should be an instance of SirsiRecords" do
    @sirsi_records.should be_an_instance_of SirsiRecords
  end

  it "should respond to write_xml_file" do
    @sirsi_records.should respond_to :write_xml_file
  end

  it "should have the correct xml representation" do
    correct_xml_records = File.open("data/sirsi.xml").read
    @sirsi_records.to_xml.should eq correct_xml_records    
  end

end
