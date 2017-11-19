FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    sequence(:username) { |n| "#{Faker::Internet.user_name}#{n}" }

    trait :confirmed do
      confirmed_at Time.now
    end
  end
end
