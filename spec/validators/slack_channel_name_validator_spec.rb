require 'rails_helper'

class SlackChannelNameValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :slack_channel

  validates :slack_channel, slack_channel_name: true
end

describe SlackChannelNameValidator do
  subject { SlackChannelNameValidatorMock.new(slack_channel: channel) }

  context 'when channel is #general' do
    let(:channel) { '#general' }

    it { is_expected.to be_valid }
  end

  context 'when channel name is as short as it can be' do
    let(:channel) { '#g' }

    it { is_expected.to be_valid }
  end

  context 'when channel name is as long as it can be' do
    let(:channel) { '#aslongasitcanbe____21' }

    it { is_expected.to be_valid }
  end

  context 'when channel name is blank' do
    let(:channel) { '#' }

    it { is_expected.to_not be_valid }
  end

  context 'when channel name is too long' do
    let(:channel) { '#longerthanitshouldbe22' }

    it { is_expected.to_not be_valid }
  end

  context 'when channel name contains uppercase letters' do
    let(:channel) { '#General' }

    it { is_expected.to_not be_valid }
  end

  context 'when channel name does not start with a #' do
    let(:channel) { 'general' }

    it { is_expected.to_not be_valid }
  end

  context 'when channel name contains spaces' do
    let(:channel) { '#hello world' }

    it { is_expected.to_not be_valid }
  end
end
