FactoryGirl.define do
  factory :inventory do
    sequence(:name) { |n| "#{Faker::Name.first_name}#{n}" }
    description { Faker::Lorem.sentence }
    association :owner, factory: [:user, :organization].sample
  end
end
