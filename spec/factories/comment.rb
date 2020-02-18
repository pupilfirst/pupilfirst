FactoryBot.define do
  factory :comment do
    value { Faker::Lorem.sentences(number: 2).join(" ") }

    # required: commentable
    # required: creator
    # optional: editor
    # optional: archiver
    # optional: archived
  end
end
