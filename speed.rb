#!/usr/bin/ruby
require 'faraday'

#curl -v -L -X POST 'https://dev-api.va.gov/services/vba_documents/v2/uploads/submit' -F 'metadata="{\"veteranFirstName\": \"Matsumoto\",\"veteranLastName\": \"Test\",\"fileNumber\": \"012345678\",\"zipCode\": \"97202\",\"source\": \"MyVSO\",\"docType\": \"21-22\"}";type=application/json' -F 'content=@"1.pdf"' -F 'attachment1=@"v1.pdf"' -F 'attachment2=@"v1.pdf"' -F 'attachment3=@"v1.pdf"'
url = 'https://dev-api.va.gov/services/vba_documents/v2/uploads'
pdf = Faraday::UploadIO.new('./v1.pdf')
metadata = Faraday::UploadIO.new('./valid_metadata.json')

conn = Faraday.new(url: URL) do |faraday|
  faraday.request :multipart #make sure this is set before url_encoded
  faraday.request :url_encoded
  faraday.adapter Faraday.default_adapter
end

payload = { metadata: metadata, content:pdf, attachment1: pdf, attachement2: pdf, attachment3: pdf }

t1 = Time.now
conn.post('/submit', payload)
t2 = Time.now
print "I took #{t2- t1} seconds"