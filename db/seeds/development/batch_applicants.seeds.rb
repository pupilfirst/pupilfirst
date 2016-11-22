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
    { email: 'applicant+interview+rejected@gmail.com' },
    { email: 'applicant+pre_selection@gmail.com', fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE },
    { email: 'applicant+closed@gmail.com', fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE }
  ].map { |applicant| applicant.merge(applicant_defaults) }

  applicants.each do |applicant_attributes|
    BatchApplicant.where(applicant_attributes).first_or_create!
  end

  coapplicants = [
    { email: 'coapplicant+pre_selection@gmail.com', fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE },
    { email: 'coapplicant+closed@gmail.com', fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE }
  ].map { |applicant| applicant.merge(name: Faker::Name.name) }

  coapplicants.each do |applicant_attributes|
    BatchApplicant.where(applicant_attributes).first_or_create!
  end

  # Prep the closed stage applicants with even more info.
  def add_applicant_profile(applicant)
    image_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg'))
    address = [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")

    applicant.update(
      fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE,
      role: Founder.valid_roles.sample,
      gender: Founder.valid_gender_values.sample,
      born_on: Date.parse('1990-01-01'),
      parent_name: Faker::Name.name,
      permanent_address: address,
      address_proof: File.open(image_path),
      current_address: address,
      phone: (9_876_543_000 + rand(999)).to_s,
      id_proof_type: BatchApplicant::ID_PROOF_TYPES.sample,
      id_proof_number: Faker::Internet.password,
      id_proof: File.open(image_path)
    )
  end

  %w(applicant+closed@gmail.com coapplicant+closed@gmail.com).each do |closed_applicant_email|
    closed_applicant = BatchApplicant.where(email: closed_applicant_email).first
    add_applicant_profile(closed_applicant)
  end
end
