require 'rails_helper'

class MobileNumberValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :phone

  validates :phone, mobile_number: true
end

describe MobileNumberValidator do
  subject { MobileNumberValidatorMock.new(phone: mobile_number) }

  context 'when mobile number is +67712345' do
    let(:mobile_number) { '+67712345' } # Solomon Islands
    it { is_expected.to be_valid }
  end

  context 'when mobile number is 9876543210' do
    let(:mobile_number) { '9876543210' }
    it { is_expected.to be_valid }
  end

  context 'when mobile number is +919876543210' do
    let(:mobile_number) { '+919876543210' }
    it { is_expected.to be_valid }
  end

  context 'when mobile number is 5555551234' do
    let(:mobile_number) { '5555551234' }
    it { is_expected.to be_valid }
  end

  context 'when mobile number is +15555551234' do
    let(:mobile_number) { '5555551234' }
    it { is_expected.to be_valid }
  end

  context 'when mobile number is 1234567890123456' do
    let(:mobile_number) { '1234567890123456' }
    it { is_expected.to be_valid }
  end

  context 'when mobile number is 12345678901234567' do
    let(:mobile_number) { '12345678901234567' }
    it { is_expected.to_not be_valid } # Too long
  end

  context 'when mobile number is 1234567' do
    let(:mobile_number) { '1234567' }
    it { is_expected.to_not be_valid } # Too short
  end
end
