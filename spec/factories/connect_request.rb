FactoryBot.define do
  factory :connect_request do
    connect_slot
    startup
    questions { "These\nare some\nquestions" }
  end
end
