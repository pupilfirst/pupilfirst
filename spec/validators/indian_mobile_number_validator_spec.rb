require 'rails_helper'

class IndianMobileNumberValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :phone

  validates :phone, indian_mobile_number: true
end

describe IndianMobileNumberValidator do
  subject { IndianMobileNumberValidatorMock.new(phone: mobile_number) }

  context 'when mobile number is 9876543210' do
    let(:mobile_number) { '9876543210' }

    it { is_expected.to be_valid }
  end

  context 'when mobile number is 8876543210' do
    let(:mobile_number) { '8876543210' }

    it { is_expected.to be_valid }
  end

  context 'when mobile number is 7876543210' do
    let(:mobile_number) { '7876543210' }

    it { is_expected.to be_valid }
  end

  context 'when mobile number is 787654321' do
    let(:mobile_number) { '787654321' }

    it { is_expected.to_not be_valid }
  end

  context 'when mobile number is 78765432100' do
    let(:mobile_number) { '78765432100' }

    it { is_expected.to_not be_valid }
  end

  context 'when mobile number is 6789054321' do
    let(:mobile_number) { '6789054321' }

    it { is_expected.to_not be_valid }
  end

  context 'when mobile number is +919876543210' do
    let(:mobile_number) { '+919876543210' }

    it { is_expected.to_not be_valid }
  end
end
