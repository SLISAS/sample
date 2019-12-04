FactoryBot.define do
  factory :user_post, class: Micropost do
    content { Faker::Lorem.sentence(5) }
    association :user, factory: :user

    trait :today do
      created_at { "Tue, 03 Dec 2019 07:01:26 UTC +00:00" }
    end

    trait :yesterday do
      created_at { "Tue, 02 Dec 2019 07:01:26 UTC +00:00" }
    end
  end
end
