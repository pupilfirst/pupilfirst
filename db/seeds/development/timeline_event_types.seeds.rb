def self.seed_image(image_name)
  File.open(File.join(Rails.root, "/app/assets/images/seeds/timeline_event_types/#{image_name}.png"))
end

timeline_event_types = [
  ['graduated', 'Governance', 'Graduated from Startup Village', "Our [team/team member] has graduated from Startup Village by [being hired/being acqui-hired/becoming sustainable/getting admission to higher studies/getting funded/joining an accelerator]. We're now an alumni, and happy to help other startups!", 'Graduation method - Offer Letter, Admission Letter, Letter of Intent to Acquire, Funding Proof, Accelerator Invitation Letter.', nil, 'graduated'],
  ['bank_loan', 'Governance', 'Received Bank Loan', "We've received a Bank Loan from [KSIDC/Federal Bank/...] to execute our project with very favourable repayment terms.", 'Email/Letter from Loan Agency. Bank Account Statement.', nil, 'bank_loan'],
  ['end_iteration', 'Product', 'End of Current Iteration', "We've worked hard on our product, and we're ready with [a new iteration]. Our primary learning from this iteration was [...].", 'Proof: Not Needed', nil, 'end_iteration'],
  ['moved_to_idea_discovery', 'Governance', 'Moved to Idea Discovery Stage', 'We have started brainstorming to narrow on the next big idea to work on.', 'Not Needed', nil, 'moved_to_idea_discovery'],
  ['moved_to_prototyping', 'Governance', 'Moved to Prototyping Stage', 'We have started work towards buidlding the first prototype of our [Product/Platform].', 'Link to prototype drafts or demos', 'moved_to_idea_discovery,moved_to_customer_validation', 'moved_to_prototyping'],
  ['moved_to_customer_validation', 'Governance', 'Moved to Customer Validation Stage', "We've [moved/moved back] to the Customer Validation stage. [..]", 'If you have moved back, an End Iteration entry. If you have moved on from the Prototyping stage, an accepted "Finished Prototype Demo"', 'moved_to_prototyping', nil],
  ['product_launch', 'Product', 'Launched Product', 'Exciting news! We just launched our product. [Download it from the Play Store/Go here to see it]. Initial [downloads/usage] have been [great/ok/not so good!].', 'Of Downloads & Usage', nil, nil]
]

default_image = 'default'

timeline_event_types.each do |event_type|
  TimelineEventType.create!(
    key: event_type[0],
    role: event_type[1],
    title: event_type[2],
    sample_text: event_type[3],
    proof_required: event_type[4],
    suggested_stage: event_type[5],
    badge: seed_image(event_type[6] || default_image),
  )
end
