class SolrRecord
  attr_accessor \
    :object_id,
    :okinsirsi,
    :title,
    :issnPrint,
    :issnElectronic,
    :targets,
    :freeJournal,
    :place,
    :publisher,
    :cat,
    :subcat,
    :language,
    :catkey,
    :pubDateNotes,
    :multiCatKey,
    :dateStatement,
    :alternateCatKey,
    :previousTitle,
    :laterTitle,
    :singleTarget,
    :noISSN 
    :hash

  def to_xml

    xml_record = "<doc><field name=\"id\">#{object_id}</field>\
    <field name=\"okinsirsi\">#{okinsirsi}</field>\
    <field name=\"title\">#{title}</field>\
    <field name=\"issnPrint\">#{issnPrint}</field>\
    <field name=\"issnElectronic\">#{issnElectronic}</field>\
    <field name=\"freeJournal\">#{freeJournal}</field>\
    <field name=\"place\">#{place}</field>\
    <field name=\"publisher\">#{publisher}</field>\
    <field name=\"language\">#{language}</field>\
    <field name=\"catkey\">#{catkey}</field>\
    <field name=\"sirsiPubDateNotes\">#{pubDateNotes}</field>\
    <field name=\"multiCatKey\">#{multiCatKey}</field>\
    <field name=\"alternateCatKey\">#{alternateCatKey}</field>\
    <field name=\"dateStatement\">#{dateStatement}</field>\
    <field name=\"previousTitle\">#{previousTitle}</field>\
    <field name=\"laterTitle\">#{laterTitle}</field>\
    <field name=\"singleTarget\">#{singleTarget}</field>\
    <field name=\"noISSN\">#{noISSN?}</field>\
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
