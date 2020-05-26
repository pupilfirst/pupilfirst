FactoryBot.define do
  # factory :timeline_event_owner do
  #   timeline_event
  #   founder
  #   latest
  #   # transient do
  #   #   owners
  #   # end
  #   # founder { oweners.present? }
  #   #
  #   #
  #   # trait(:latest) do
  #   #   latest { true }
  #   #   transient do
  #   #     owners
  #   #   end
  #   #
  #   #   after(:create) do |topic, evaluator|
  #   #     create :post, :first_post, topic: topic, creator: evaluator.creator
  #   #   end
  #   # end
  # end

  factory :timeline_event_owner do

    #   transient do
    #     owners { Founder.none }
    #     latest { false }
    #   end
    #
    #   if owners.present?
    #     owners.each do |owner|
    #       create(:timeline_event_owner, founder: owner, timeline_event: timeline_event, latest: latest)
    #     end
    #   else
    #     create(:timeline_event_owner, founder: owner, timeline_event: timeline_event, latest: latest)
    #   end
    # end
    timeline_event
    founders

    trait(:latest) do
      latest { true }
    end
  end
end
