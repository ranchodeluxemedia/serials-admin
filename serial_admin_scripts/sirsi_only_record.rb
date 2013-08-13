require 'rexml/document'

class SirsiOnlyRecord
  # for journal records that are in Sirsi but not in SFX
 
  attr_accessor :issn, :catkey, :link_text

  def initialize(options={})
    @issn = options[:issn]
    @catkey = options[:catkey]
    @link_text = options[:link_text]
  end

  def to_xml
    "<doc><field name=\"id\">#{@catkey}</field><field name=\"ua_issnPrint\">#{@issn}</field><field name=\"ua_catkey\">#{@catkey}</field><field name=\"ua_link_text\">#{@link_text}</field><field name=\"ua_inSirsi\">true</field></doc>".gsub("&", "&amp;") 
  end
end
