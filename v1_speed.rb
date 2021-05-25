require 'json'

command =  <<EOF
curl -v -L -X POST 'https://dev-api.va.gov/services/vba_documents/v1/uploads/' -H 'apikey: mulgyIRUpqY8SeJoM89e3t2iZucbZVSH'
EOF


curl = `#{command}`
hash = JSON.parse curl
url = hash['data']['attributes']['location']
puts '------------------------------------------'
puts url
puts '------------------------------------------'
require 'faraday'
URL = url

pdf_file = ARGV[1].to_s
puts "I found #{pdf_file}, #{File.exists?(pdf_file)}"

pdf1 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
pdf2 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
pdf3 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
metadata = Faraday::UploadIO.new(ARGV[0].to_s, 'application/json')

conn = Faraday.new(url: URL) do |faraday|
  faraday.request :multipart
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter

end

payload = { metadata: metadata, content: pdf1, attachment1: pdf2, attachement2: pdf3}

t1 = Time.now
puts "Starting put...."
response = conn.put('', payload)
t2 = Time.now
puts response.body
puts response.status
print "I took #{t2- t1} seconds"