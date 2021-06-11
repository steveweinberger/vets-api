FactoryBot.define do
  factory :login_trace do
    account_id { 1 }
    idp { 1 }
    ip_address { "MyString" }
    started_at { "2021-06-03 10:53:43" }
    completed_at { "2021-06-03 10:53:43" }
  end
end
