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
    :matched,
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
    <field name=\"title\">#{title}</field>\
    <field name=\"issnPrint\">#{issnPrint}</field>\
    <field name=\"issnElectronic\">#{issnElectronic}</field>\
    <field name=\"freeJournal\">#{freeJournal}</field>\
    <field name=\"place\">#{place}</field>\
    <field name=\"publisher\">#{publisher}</field>\
    <field name=\"language\">#{language}</field>\
    <field name=\"catkey\">#{catkey}</field>\
    <field name=\"sirsiPubDateNotes\">#{pubDateNotes}</field>\
    <field name=\"singleTarget\">#{singleTarget}</field>\
    <field name=\"noISSN\">#{noISSN}</field>\
    <field name=\"matched\">#{matched}</field>\
    <field name=\"bad_dates\">#{bad_dates}</field>\
    <field name=\"bad_issn\">#{bad_issn}</field>\
    <field name=\"bad_issn_statement\">${bad_issn_statement}</field>\
    <field name=\"no_url\">#{no_url}</field>\
    <field name=\"holdings_comparison\">#{holdings_comparison}</field>\
    <field name=\"dateStatement\">#{dateStatement}</field>\
    <field name=\"inSFX\">true</field>"

    xml_record+=split_targets
    xml_record+="</doc>"

  end

  private

  def split_targets
    temp_string=""
    ts=targets.split(",")
    ts.each do |t|
      temp_string+="<field name=\"target\">#{t.strip}</field>"
    end
    temp_string
  end

  def noISSN?
    @issnPrint!="" || @issnElectronic!=""
  end

end
