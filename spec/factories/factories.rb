FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:code) { |n| "USR#{n.to_s.padded(3)}" }
    password { 'password123' }
    directive { 0 }
  end

  factory :item do
    sequence(:name) { |n| "Item #{n}" }
    sequence(:code) { |n| "ITM#{n.to_s.padded(3)}" }
  end

  factory :section do
    sequence(:name) { |n| "Section #{n}" }
    warehouse
  end

  factory :warehouse do
    sequence(:name) { |n| "Warehouse #{n}" }
  end

  factory :stock do
    item
    section
    status { 'available' }
  end

  factory :input_report do
    user
    output_report
    date { Date.current }
    status { 'pending' }
  end

  factory :output_report do
    user
    date { Date.current }
    status { 'pending' }
  end

  factory :input_report_stock do
    input_report
    stock
    section
  end

  factory :output_report_stock do
    output_report
    stock
    section
  end
end 