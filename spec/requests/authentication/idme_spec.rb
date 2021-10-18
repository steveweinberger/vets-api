# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticating through ID.me', type: :request, js: true do
  context 'loa1 user' do
    it 'will authenticate user successfully' do
      get '/v1/sessions/idme/new'
      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(body)
      form = doc.at_css('[id="saml-form"]')

      url = form.attributes['action'].value
      form_inputs = form.children.select { |child| child.name == 'input' }
      params_hash = form_inputs.each_with_object({}) do |input, hsh|
                      hsh[input.attributes['name'].value] = input.attributes['value'].value
                    end

      binding.pry
      post url, params: params_hash.merge
    end
  end
end


curl 'https://sqa.eauth.va.gov/isam/sps/saml20idp/saml20/login' \
  -H 'Connection: keep-alive' \
  -H 'Cache-Control: max-age=0' \
  -H 'sec-ch-ua: "Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Origin: https://staging-api.va.gov' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Sec-Fetch-Site: same-site' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Referer: https://staging-api.va.gov/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H $'Cookie: TS0114998c=0119a2687f566b2876d50dfadfb85ab20f0b1d11b2fe1565716c75fc6e69ed399b5e55a918d781bf71dd1605fb24832ac245cbdfd9; PD_STATEFUL_f126d47c-07d5-11ea-bd57-001dd800a325=%2Fisam; TS015b3c81=01874af5a4c91ed2a486fe956ee08176e9d013c4977f236be6b9e4d507fb9c4a608515be75d38c24c9214df30f753098831ff7dd8b; TS01a556e5=0119a2687fa5722f72b42a2be043132044a703471c7f2cd920a862c1dea2adb552fdd4964ec37e1a6c1a0c8da45c616a7f276498b9; JSESSIONID=CA974B977B1FC26457F1E1FE31475126; COOKIE_SUPPORT=true; GUEST_LANGUAGE_ID=en_US; VSERVER=LR_602; ROUTEID=.02; dtCookie=v_4_srv_21_sn_A8E9AFA9B106225809AB96B233C4E048_perc_100000_ol_0_mul_1_app-3Aa0f724a4e525a3e3_1; TS014670a6=01c8917e48c0ed843be5c7929fc6f992a1b9e4aade86b81754ad225dd89e5dc6bef5532e4f8f85e3002e0db7d3505868d924620adf; TS01b45679=0119a2687fa1c13b2f9f2e3194d078e40ce4442609e84de29031d73b3361616924dae7ca2c93c7ac63a2fb4d12ffcd152b9877b8b8; AMWEBJCT\u0021%2Fisam\u0021AACJSESSIONID=0000mXzu9r6vCM4LYwW98K0VX4q:7b84e5de-22a7-4ec5-ac03-e83548784ddb; AMWEBJCT\u0021%2Fisam\u0021https%3A%2F%2Fsqa.eauth.va.gov%2Fisam%2Fsps%2Fsaml20idp%2Fsaml20FIMSAML20=uuid4349c508-43c8-4bb2-8a3e-35de4ffa96f2; TS01a7b184=0119a2687f4ff5b9cd6478e92ca6793c8d424c7bc891e35e6d36a7cc2c43f38220d307b23c41746a84e81f45da60e8ac829d6ba33b; PD-S-SESSION-ID=0_CTvz7H/jG5HHcaGj4Mbds9OrFxz5Do5uBjImJp3/KpPkCflE/3E=_AAAAAQA=_2CG+7026HYfDXlNs1Mhm6x0mwBI=; AMWEBJCT\u0021%2Fisam\u0021uuid7042d49f-016e-1509-a709-c55fd574c373Wayf=https://api.idmelabs.com; AMWEBJCT\u0021%2Fisam\u0021https%3A%2F%2Fsqa.eauth.va.gov%2Fisam%2Fsps%2Fsaml20sp%2Fsaml20FIMSAML20=uuid8daca5e8-bddb-49c7-b34e-63e50a72e1e4; __Secure-BIGipServer=\u0021GTjAjZUboq88+nZ7ksOerefD36w963bXzu/hznSBDF+O6rdp4PItnaQOO3ffzhWMRve/eu9j5PYUMQ==; vagov_saml_request_staging=%7B%22timestamp%22%3A%222021-10-18T18%3A09%3A42%2B00%3A00%22%2C%22transaction_id%22%3A%224a6089cd-6036-4099-98e0-f17b3a18f99e%22%2C%22saml_request_id%22%3A%22_df11a8fd-0168-419d-b644-39b8538a702e%22%2C%22saml_request_query_params%22%3A%7B%7D%7D' \
  --data-raw 'SAMLRequest=PHNhbWxwOkF1dGhuUmVxdWVzdCBBc3NlcnRpb25Db25zdW1lclNlcnZpY2VVUkw9J2h0dHBzOi8vc3RhZ2luZy1hcGkudmEuZ292L3YxL3Nlc3Npb25zL2NhbGxiYWNrJyBEZXN0aW5hdGlvbj0naHR0cHM6Ly9zcWEuZWF1dGgudmEuZ292L2lzYW0vc3BzL3NhbWwyMGlkcC9zYW1sMjAvbG9naW4nIEZvcmNlQXV0aG49J3RydWUnIElEPSdfZGYxMWE4ZmQtMDE2OC00MTlkLWI2NDQtMzliODUzOGE3MDJlJyBJc3N1ZUluc3RhbnQ9JzIwMjEtMTAtMThUMTg6MDk6NDJaJyBWZXJzaW9uPScyLjAnIHhtbG5zOnNhbWw9J3VybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24nIHhtbG5zOnNhbWxwPSd1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6cHJvdG9jb2wnPjxzYW1sOklzc3Vlcj5odHRwczovL3Nzb2Utc3Atc3RhZ2luZy52YS5nb3Y8L3NhbWw6SXNzdWVyPjxzYW1scDpOYW1lSURQb2xpY3kgQWxsb3dDcmVhdGU9J3RydWUnIEZvcm1hdD0ndXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6MS4xOm5hbWVpZC1mb3JtYXQ6ZW1haWxBZGRyZXNzJy8%2BPHNhbWxwOlJlcXVlc3RlZEF1dGhuQ29udGV4dCBDb21wYXJpc29uPSdleGFjdCc%2BPHNhbWw6QXV0aG5Db250ZXh0Q2xhc3NSZWY%2BaHR0cDovL2lkbWFuYWdlbWVudC5nb3YvbnMvYXNzdXJhbmNlL2xvYS8xL3ZldHM8L3NhbWw6QXV0aG5Db250ZXh0Q2xhc3NSZWY%2BPHNhbWw6QXV0aG5Db250ZXh0Q2xhc3NSZWY%2BaHR0cHM6Ly9lYXV0aC52YS5nb3YvY3NwP1NlbGVjdD1pZG1lMzwvc2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj48L3NhbWxwOlJlcXVlc3RlZEF1dGhuQ29udGV4dD48L3NhbWxwOkF1dGhuUmVxdWVzdD4%3D&RelayState=%7B%22originating_request_id%22%3A%2236bef101-cf76-4b33-b2fd-85b5e2dfdd6b%22%2C%22type%22%3A%22idme%22%7D' \
  --compressed
