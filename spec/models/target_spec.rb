require 'rails_helper'

describe Target do
  subject { create :target }

  before do
    allow(PublicSlackTalk).to receive(:post_message)
  end

  describe '#pending?' do
    context 'when target is in pending status' do
      it 'returns true' do
        expect(subject.pending?).to eq(true)
      end
    end

    context 'when target is not in pending status' do
      let(:subject) { create :target, status: Target::STATUS_DONE }

      it 'returns false' do
        expect(subject.pending?).to eq(false)
      end
    end
  end

  describe '#crucial_revision?' do
    context 'when a crucial target field is updated' do
      it 'returns true' do
        subject.due_date = 1.month.from_now
        expect(subject.crucial_revision?).to eq(true)
      end
    end

    context 'when a non-crucial target field is updated' do
      it 'returns false' do
        subject.role = Target::ROLE_FOUNDER
        expect(subject.crucial_revision?).to eq(false)
      end
    end
  end

  describe '#details_as_slack_message' do
    it 'contains target details' do
      slack_message = subject.details_as_slack_message

      # default details
      expect(slack_message).to include("#{subject.assigner.name} has assigned ")
      expect(slack_message).to include(ApplicationController.helpers.strip_tags(subject.description))

      # conditional details
      expect(slack_message).to include("<#{subject.resource_url}|a useful link>") # already set from factory
      expect(slack_message).to_not include("due date to complete this target is") # no due date yet
    end

    context 'when due date is available' do
      subject { create :target, due_date: 1.week.from_now }

      it 'contains due date' do
        expect(subject.details_as_slack_message).to include(subject.due_date.strftime('%A, %d %b %Y %l:%M %p'))
      end
    end
  end

  describe '#revision_as_slack_message' do
    context 'when title is changed' do
      it 'contains the new title' do
        subject.title = 'New Title'
        expect(subject.revision_as_slack_message).to include("revised title is: New Title")
      end
    end
    context 'when description is changed' do
      it 'contains the new description' do
        subject.description = '<div>revised description<div>' # to ensure html tags are stripped
        expect(subject.revision_as_slack_message).to include("description now reads: \"revised description\"")
      end
    end
    context 'when due date is changed' do
      it 'contains the new due date' do
        subject.due_date = 1.week.from_now
        expect(subject.revision_as_slack_message).to include("due date has been modified to *#{subject.due_date.strftime('%A, %d %b %Y %l:%M %p')}*")
      end
    end
  end
end
