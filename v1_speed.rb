require 'json'
pdf_file = ARGV[1].to_s
metadata = ARGV[0].to_s
num_times = ARGV[2].to_i
pids = []
directory = File.join(Dir.pwd, "v1")
Dir.mkdir(directory, 0700) rescue nil
command = <<EOF
curl -v -L -X POST 'https://dev-api.va.gov/services/vba_documents/v1/uploads/' -H 'apikey: mulgyIRUpqY8SeJoM89e3t2iZucbZVSH'
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
    File.write("#{directory}/body_#{i}", response.body+ "\n")
    File.write("#{directory}/status_#{i}", response.status.to_s + "\n")
    File.write("#{directory}/time_#{i}", "I took #{t2 - t1} seconds\n")  end
end
puts "Waiting"
pids.each { |pid| Process.waitpid(pid) } # wait for my children to completeputs "Summary:"
puts "Done!"
puts "Wrote to #{directory}"
