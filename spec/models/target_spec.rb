require 'rails_helper'

describe Target do
  let(:subject) { create :target }

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
      let(:subject) { create :target, status: 'done' }

      it 'returns false' do
        expect(subject.pending?).to eq(false)
      end
    end
  end

  describe '#notify_new_target' do
    context 'when a new target is created' do
      it 'pings all founders the target details' do
        expect(PublicSlackTalk).to receive(:post_message).with(message: subject.details_as_slack_message, users: subject.startup.founders)
        subject.notify_new_target
      end
    end
  end

  describe '#notify_revision' do
    context 'when a crucial target field is updated' do
      it 'pings all founders the update details' do
        expect(PublicSlackTalk).to receive(:post_message).with(message: subject.revision_as_slack_message, users: subject.startup.founders)
        subject.notify_revision
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
      # default details
      expect(subject.details_as_slack_message).to include("#{subject.assigner.name} has assigned ")
      expect(subject.details_as_slack_message).to include(ApplicationController.helpers.strip_tags subject.description)

      # conditional details
      expect(subject.details_as_slack_message).to include("<#{subject.resource_url}|a useful link>") # already set from factory
      expect(subject.details_as_slack_message).to_not include("due date to complete this target is") # no due date yet
      subject.due_date = 1.week.from_now
      expect(subject.details_as_slack_message).to include(subject.due_date.strftime('%A, %d %b %Y %l:%M %p'))
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
