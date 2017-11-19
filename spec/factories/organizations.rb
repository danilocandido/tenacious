FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "#{Faker::Name.first_name}#{n}" }
    association :owner, factory: :user
  end
end
