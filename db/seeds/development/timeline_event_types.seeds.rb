def self.seed_image(type)
  File.open(File.join(Rails.root, "/app/assets/images/seeds/timeline_event_types/#{type}.png"))
end

timeline_event_types = [
  ['graduated', 'Governance', 'Graduated from Startup Village', "Our [team/team member] has graduated from Startup Village by [being hired/being acqui-hired/becoming sustainable/getting admission to higher studies/getting funded/joining an accelerator]. We're now an alumni, and happy to help other startups!\nProof: Of Graduation method. Offer Letter, Admission Letter, Letter of Intent to Acquire, Funding Proof, Accelerator Invitation Letter."],
  ['bank_loan', 'Governance', 'Received Bank Loan', "We've received a Bank Loan from [KSIDC/Federal Bank/...] to execute our project with very favourable repayment terms.\nProof: Email/Letter from Loan Agency. Bank Account Statement."],
  ['end_iteration', 'Product', 'End of Current Iteration', "We've worked hard on our product, and we're ready with [a new iteration]. Our primary learning from this iteration was [...].\nProof: Not Needed"],
  ['moved_to_idea_discovery', 'Governance', 'Moved to Idea Discovery Stage', "We have started brainstorming to narrow on the next big idea to work on.. \nProof: Not Needed"],
  ['moved_to_prototyping', 'Governance', 'Moved to Prototyping Stage', 'We have started work towards buidlding the first prototype of our [Product/Platform] .. Proof: Link to prototype drafts or demos'],
  ['product_launch', 'Product', 'Launched Product', 'Exciting news! We just launched our product. [Download it from the Play Store/Go here to see it]. Initial [downloads/usage] have been [great/ok/not so good!] Proof: Of Downloads & Usage']
]

timeline_event_types.each do |event_type|
  TimelineEventType.create!(
    key: event_type[0],
    role: event_type[1],
    title: event_type[2],
    sample_text: event_type[3],
    badge: seed_image(event_type[0])
  )
end
