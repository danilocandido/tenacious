FactoryGirl.define do
  factory :inventory_user do
    association :user, factory: :user
    association :inventory, factory: :inventory

    trait :confirmed do
      confirmed_at Time.now
    end
  end
end
