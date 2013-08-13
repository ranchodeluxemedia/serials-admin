class SolrRecord
  attr_accessor \
    :object_id,
    :title,
    :issnPrint,
    :issnElectronic,
    :targets,
    :freeJournal,
    :place,
    :publisher,
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
    <field name=\"ua_freeJournal\">#{freeJournal}</field>\
    <field name=\"ua_place\">#{place}</field>\
    <field name=\"ua_publisher\">#{publisher}</field>\
    <field name=\"ua_language\">#{language}</field>\
    <field name=\"ua_catkey\">#{catkey}</field>\
    <field name=\"ua_sirsiPubDateNotes\">#{pubDateNotes}</field>\
    <field name=\"ua_singleTarget\">#{singleTarget}</field>\
    <field name=\"ua_noISSN\">#{noISSN}</field>\
    <field name=\"ua_updated\">#{updated}</field>\
    <field name=\"ua_bad_dates\">#{bad_dates}</field>\
    <field name=\"ua_bad_issn\">#{bad_issn}</field>\
    <field name=\"ua_bad_issn_statement\">#{bad_issn_statement}</field>\
    <field name=\"ua_no_url\">#{no_url}</field>\
    <field name=\"ua_holdings_comparison\">#{holdings_comparison}</field>\
    <field name=\"ua_dateStatement\">#{dateStatement}</field>\
    <field name=\"ua_inSFX\">true</field>"

    xml_record+=split_targets
    xml_record+="</doc>"
    xml_record.gsub("<<", "").gsub(">>", "")

  end

  private

  def split_targets
    temp_string=""
    ts=targets.split(",")
    ts.each do |t|
      temp_string+="<field name=\"ua_target\">#{t.strip}</field>"
    end
    temp_string
  end

  def noISSN?
    @issnPrint!="" || @issnElectronic!=""
  end

end
