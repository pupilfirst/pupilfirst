require 'rails_helper'

class EmailValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email

  validates :email, email: true
end

describe EmailValidator do
  subject { EmailValidatorMock.new(email: email) }

  context 'when email is valid' do
    let(:email) { 'test@example.com' }

    it { is_expected.to be_valid }
  end

  context 'when email has invalid format' do
    let(:email) { 'foobar' }

    it { is_expected.to_not be_valid }
  end

  context 'when the email is too long' do
    let(:seed) { 'abcdefghijklmnopqrstuvwxyz' }
    let(:email) { "#{seed * 9}@#{seed}.com" }

    it { is_expected.to_not be_valid }
  end
end
