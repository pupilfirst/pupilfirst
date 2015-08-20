def self.seed_image(type)
  File.open(File.join(Rails.root, "/app/assets/images/seeds/timeline_event_types/#{type}.png"))
end

timeline_event_types = [
  ['graduated', 'Graduated from Startup Village', "Our [team/team member] has graduated from Startup Village by [being hired/being acqui-hired/becoming sustainable/getting admission to higher studies/getting funded/joining an accelerator]. We're now an alumni, and happy to help other startups!\nProof: Of Graduation method. Offer Letter, Admission Letter, Letter of Intent to Acquire, Funding Proof, Accelerator Invitation Letter."],
  ['bank_loan', 'Received Bank Loan', "We've received a Bank Loan from [KSIDC/Federal Bank/...] to execute our project with very favourable repayment terms.\nProof: Email/Letter from Loan Agency. Bank Account Statement."],
  ['end_iteration', 'End of Current Iteration', "We've worked hard on our product, and we're ready with [a new iteration]. Our primary learning from this iteration was [...].\nProof: Not Needed"]
]

timeline_event_types.each do |event_type|
  TimelineEventType.create!(
    key: event_type[0],
    title: event_type[1],
    sample_text: event_type[2],
    badge: seed_image(event_type[0])
  )
end
