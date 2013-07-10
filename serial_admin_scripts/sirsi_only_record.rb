class SirsiOnlyRecord
  # for journal records that are in Sirsi but not in SFX
 
  attr_accessor :issn, :catkey, :link_text

  def initialize(options={})
    @issn = options[:issn]
    @catkey = options[:catkey]
    @link_text = options[:link_text]
  end

  def to_xml
    xml_record = "<doc><field name=\"id\">#{@catkey}</field><field name=\"issn\">#{@issn}</field><field name=\"catkey\">#{@catkey}</field><field name=\"link_text\">#{@link_text}</field><field name=\"inSirsi\">true</field></doc>"
  end
end
