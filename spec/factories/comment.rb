FactoryBot.define do
  factory :comment do
    value { Faker::Lorem.sentences(2).join(" ") }

    # required: commentable
    # required: creator
    # optional: editor
    # optional: archiver
    # optional: archived
  end
end
