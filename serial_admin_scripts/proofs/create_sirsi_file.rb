require 'rsolr'
require 'date'
require './config_module'


include ConfigModule
args = get_vars('util.conf')


solr=RSolr.connect :url=>'http://0.0.0.0:8983/solr'

if ARGV[0] == "incremental" then
  search=solr.select :params=>{:qf => Date.today.to_s}
  filename = "#{args['sirsi_incremental']}"
elsif ARGV[0] == "full" then
  search=solr.select :params=>{:qf =>""}
  filename = "#{args['sirsi_full']}"
else
  puts "Please specify full or incremental extract."
  exit
end

records=search['response']['docs']
f=File.open("#{args['data_dir']}/#{filename}", "w")

records.each do |record|
 if record['issnPrint'] then
    issn = record['issnPrint'][0]
    open_url = "http://resolver.library.ualberta.ca/resolver?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_ver=Z39.88-2004&rfr_id=info%3Asid%2Fualberta.ca%3Aopac&rft.genre=journal&rft.issn=#{issn}&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004"
  elsif record['issnElectronic'] then
    issn = record['issnElectronic'][0]
    open_url =  "http://resolver.library.ualberta.ca/resolver?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_ver=Z39.88-2004&rfr_id=info%3Asid%2Fualberta.ca%3Aopac&rft.genre=journal&rft.issn=#{issn}&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004"
  end
  f.puts sirsi_record = "#{record['id']}|#{issn}||#{open_url}|#{record['dateStatement']}|false|free|"
end



