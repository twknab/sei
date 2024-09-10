# frozen_string_literal: true

FactoryBot.define do
  factory :college do
    name { Faker::University.name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    college_board_code { Faker::Number.number(digits: 6) }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
