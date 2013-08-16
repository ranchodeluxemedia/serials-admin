class SolrRecord
  attr_accessor \
    :object_id,
    :title,
    :issnPrint,
    :issnElectronic,
    :targets,
    :freeJournal,
    :language,
    :catkey,
    :pubDateNotes,
    :singleTarget,
    :updated,
    :bad_dates,
    :bad_issn,
    :bad_issn_statement,
    :noISSN,
    :no_url,
    #:has_related_records,
    :dateStatement,
    :holdings_comparison

  def to_xml
 
    xml_record = "<doc><field name=\"id\">#{object_id}</field>\
    <field name=\"ua_object_id\">#{object_id}</field>\
    <field name=\"ua_title\">#{title}</field>\
    <field name=\"ua_issnPrint\">#{issnPrint}</field>\
    <field name=\"ua_issnElectronic\">#{issnElectronic}</field>\
    <field name=\"ua_freeJournal\">#{free_or_restricted?}</field>\
    <field name=\"ua_language\">#{language}</field>\
    <field name=\"ua_catkey\">#{catkey}</field>\
    <field name=\"ua_singleTarget\">#{singleTarget}</field>\
    <field name=\"ua_noISSN\">#{noISSN?}</field>\
    <field name=\"ua_updated\">#{updated}</field>\
    <field name=\"ua_bad_dates\">#{bad_dates}</field>\
    <field name=\"ua_bad_issn\">#{bad_issn}</field>\
    <field name=\"ua_bad_issn_statement\">#{bad_issn_statement}</field>\
    <field name=\"ua_no_url\">#{no_url}</field>\
    <field name=\"ua_holdings_comparison\">#{holdings_comparison}</field>\
    <field name=\"ua_dateStatement\">#{dateStatement}</field>"

    xml_record+=split_targets
    xml_record+=pubDateNotes?
    xml_record+="</doc>"
    xml_record.gsub("<<", "").gsub(">>", "")

  end

  def populate_with(marc_record)
    self.object_id=marc_record['090']['a'] if marc_record['090']
    self.title=marc_record['245']['a'].gsub(">","").gsub("<", "") if marc_record['245']
    self.issnPrint=marc_record['022']['a'] if marc_record['022']
    self.issnElectronic=marc_record['776']['x'] if marc_record['776']
    self.pubDateNotes="temp" #from matchissn
    self.bad_dates = "false"
    self.bad_issn = "false"
    @targets=parse_targets(marc_record)
    self.singleTarget = single_target?
    self.language=get_language(marc_record)
    self
  end

  def add_summary_holdings(summary_holdings_statement)
    self.freeJournal=summary_holdings_statement[:free]
    unless summary_holdings_statement[:summary_holdings].include? "error"
      self.dateStatement=summary_holdings_statement[:summary_holdings]
    end
  end


  private

  def split_targets
    temp_string=""
    ts=@targets.split(",")
    ts.each do |t|
      temp_string+="<field name=\"ua_target\">#{t.strip}</field>"
    end
    temp_string
  end

  def noISSN?
    @issnPrint.nil? && @issnElectronic.nil?
  end

  def pubDateNotes?
    if pubDateNotes=="temp"
      ""
    else
      "<field name=\"ua_sirsiPubDateNotes\">#{pubDateNotes}</field>" unless pubDateNotes=="temp"
    end
  end

  def free_or_restricted?
    freeJournal || "restricted"
  end

 def parse_targets(record)
    tgts = record.find_all{|t| ('866') === t.tag}
    target_list = []
    tgts.each{|t| target_list << t['x'].to_s }
    target_list.join(", ")
  end

  def get_language(record)
    record['008'].to_s[-5..-3] if record['008']
  end

  def single_target?
    @targets.split(",").size==1
  end

end
