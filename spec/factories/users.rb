FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:code) { |n| "USR#{n.to_s.padded(3)}" }
    password { 'password123' }
    directive { 0 }
  end
end 