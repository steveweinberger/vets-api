require "uri"
require "net/http"
metadata = ARGV[0].to_s
pdf = ARGV[1].to_s
raise "I can not find #{metadata}" unless File.exist?(metadata)
raise "I can not find #{pdf}" unless File.exist?(pdf)
url = URI("https://dev-api.va.gov/services/vba_documents/v2/uploads/submit")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true
request = Net::HTTP::Post.new(url)
request["apikey"] = "mulgyIRUpqY8SeJoM89e3t2iZucbZVSH"
request["Cookie"] = "TS016f4012=01c8917e48a0e98bbf7907f5de00bc23de968d681c87098af0bf1fefdd2cb92236a39e685c4708b9d1c5a7e938b5def5925f50c882"
form_data = [['metadata', File.open(metadata)],['content', File.open(pdf)],['attachment1', File.open(pdf)],['attachment2', File.open(pdf)]]
request.set_form form_data, 'multipart/form-data'
t1 = Time.now
response = https.request(request)
t2 = Time.now
puts response.read_body
puts "I took #{t2-t1} seconds"