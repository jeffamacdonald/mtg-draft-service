FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "jeff#{n}@example.com" }
    password  { "somehash" }
    sequence(:username) { |n| "jeff#{n}" }
    phone { "5555555555" }
  end
end