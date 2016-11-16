require_relative 'helper'

after 'development:colleges' do
  puts 'Seeding batch_applicants'

  def applicant_defaults
    {
      name: Faker::Name.name,
      gender: Founder.valid_gender_values.sample,
      phone: "9876543#{100 + rand(100)}",
      college: College.order('RANDOM()').first,
      reference: BatchApplicant.reference_sources[0..-2].sample
    }
  end

  applicants = [
    { email: 'applicant+registered@gmail.com' },
    { email: 'applicant+paid@gmail.com' },
    { email: 'applicant+submitted@gmail.com' },
    { email: 'applicant+submitted+rejected@gmail.com' },
    { email: 'applicant+interview@gmail.com' },
    { email: 'applicant+interview+rejected@gmail.com'},
    { email: 'applicant+pre_selection@gmail.com'}
  ].map { |applicant| applicant.merge(applicant_defaults) }

  applicants.each do |applicant_attributes|
    BatchApplicant.where(applicant_attributes).first_or_create!
  end
end
