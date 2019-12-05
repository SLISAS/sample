FactoryBot.define do
  factory :user, class: User do
    name { "Example" }
    sequence(:email) { |n| "person#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    admin { false }

    factory :other_user do
      name { Faker::Name.name }
      email { Faker::Internet.email }
    end
  end
end
