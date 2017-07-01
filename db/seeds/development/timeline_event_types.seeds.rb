puts 'Seeding timeline_event_types'

def self.seed_image(image_name)
  File.open(File.join(Rails.root, "/spec/support/uploads/timeline_event_types/#{image_name}.png"))
end

timeline_event_types = [
  ['founder_update', 'Founder', 'Founder Update', "I've got a few things to share! [...]", nil],
  ['team_update', 'Product', 'Team Update', 'Anything else you want to talk about! Proof: Not needed.', nil],
  ['graduated', 'Product', 'Graduated from Startup Village', "Our [team/team member] has graduated from Startup Village by [being hired/being acqui-hired/becoming sustainable/getting admission to higher studies/getting funded/joining an accelerator]. We're now an alumni, and happy to help other startups!", 'Graduation method - Offer Letter, Admission Letter, Letter of Intent to Acquire, Funding Proof, Accelerator Invitation Letter.', 'graduated'],
  ['bank_loan', 'Product', 'Received Bank Loan', "We've received a Bank Loan from [KSIDC/Federal Bank/...] to execute our project with very favourable repayment terms.", 'Email/Letter from Loan Agency. Bank Account Statement.', 'bank_loan'],
  ['end_iteration', 'Product', 'End of Current Iteration', "We've worked hard on our product, and we're ready with [a new iteration]. Our primary learning from this iteration was [...].", 'Proof: Not Needed', 'end_iteration'],
  ['product_launch', 'Product', 'Launched Product', 'Exciting news! We just launched our product. [Download it from the Play Store/Go here to see it]. Initial [downloads/usage] have been [great/ok/not so good!].', 'Of Downloads & Usage', nil],
  ['team_formed', 'Product', 'Team Formed', 'We are a bunch of [Technology/Music/...] enthusiasts from [College/City] and we are excited to start! Our team has Name (Role), Name 2 (Role 2), ...', 'Not Needed', 'team_formation'],
  ['new_product_deck', 'Product', 'New Product Deck', 'We just updated our Product Deck, do take a look!', 'Link to new deck', 'idea'],
  ['one_liner', 'Product', 'Set New One-Liner', 'We have set a new one-line mission for our product! We want to [organize the worlds information/...]. We think this mission is great because [...].', 'Not Needed', 'mission'],
  ['joined_svco', 'Product', 'Joined SV.CO', 'We just registered our startup on SV.CO. Looking forward to an amazing learning experience', 'Proof: Not Needed', 'team_formation']
]

default_image = 'default'

timeline_event_types.each do |event_type|
  TimelineEventType.create!(
    key: event_type[0],
    role: event_type[1],
    title: event_type[2],
    sample_text: event_type[3],
    proof_required: event_type[4],
    badge: seed_image(event_type[5] || default_image),
  )
end
