FactoryBot.define do
  factory :user do
    email { "jeff@example.com" }
    password  { "somehash" }
    username { 'jeff' }
    phone { 1234567890 }
  end
end