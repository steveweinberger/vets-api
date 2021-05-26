# sample invocation
# ruby v2_speed.rb ./modules/vba_documents/spec/fixtures/valid_metadata.json ./modules/vba_documents/spec/fixtures/valid_doc.pdf 10 sandbox zxGIWB0sgDaaCaNxyvXES1ZKHUX3L2ZM
require 'json'
pdf_file = ARGV[1].to_s
metadata = ARGV[0].to_s
num_times = ARGV[2].to_i
env = ARGV[3].to_s
api_key = ARGV[4].to_s

pids = []
directory = File.join(Dir.pwd, "v1")
Dir.mkdir(directory, 0700) rescue nil
command = <<EOF
curl -v -L -X POST 'https://#{env}-api.va.gov/services/vba_documents/v1/uploads/' -H 'apikey: #{api_key}'
EOF

num_times.times do |i|
  pids << fork do

    curl = `#{command}`
    hash = JSON.parse curl
    url = hash['data']['attributes']['location']
    puts '------------------------------------------'
    puts url
    puts '------------------------------------------'
    require 'faraday'
    URL = url

    puts "I found #{pdf_file}, #{File.exists?(pdf_file)}"

    pdf1 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
    pdf2 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
    pdf3 = Faraday::UploadIO.new(pdf_file, 'application/pdf')
    metadata = Faraday::UploadIO.new(metadata.to_s, 'application/json')

    conn = Faraday.new(url: URL) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    payload = {metadata: metadata, content: pdf1, attachment1: pdf2, attachement2: pdf3}

    t1 = Time.now
    puts "Starting put...."
    response = conn.put('', payload)
    t2 = Time.now
    puts response.body
    puts response.status
    File.write("#{directory}/start_time_#{i}", t1.to_s + "\n")
    File.write("#{directory}/end_time_#{i}", t2.to_s + "\n")
    File.write("#{directory}/body_#{i}", response.body+ "\n")
    File.write("#{directory}/status_#{i}", response.status.to_s + "\n")
    File.write("#{directory}/time_#{i}", "I took #{t2 - t1} seconds\n")
    File.write("#{directory}/url_#{i}", "#{url}\n")
  end
end
puts "Waiting"
pids.each { |pid| Process.waitpid(pid) } # wait for my children to complete
puts "Done!"
puts "Wrote to #{directory}"
