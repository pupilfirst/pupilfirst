require 'rails_helper'

RSpec.describe ProgramWeek, type: :model do
  subject { described_class }
  let(:batch) { create :batch }

  it 'ensures uniqueness of week number in batch' do
    subject.create! name: 'foo', number: 1, batch: batch, icon_name: ProgramWeek.icon_name_options.sample

    expect do
      subject.create! name: 'bar', number: 1, batch: batch
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
