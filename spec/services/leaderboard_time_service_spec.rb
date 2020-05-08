require 'rails_helper'

describe LeaderboardTimeService, broken: true do
  include ActiveSupport::Testing::TimeHelpers

  around(:each) do |example|
    # Time travel to the test time when running a spec.
    travel_to(Time.zone.parse('2019-03-20T14:00:00+05:30')) do
      example.run
    end
  end

  context 'when there is no delta' do
    subject { LeaderboardTimeService.new }

    describe '#week_start' do
      it 'returns start of week' do
        expected_time = Time.zone.parse('2019-03-11T12:00:00+05:30')
        expect(subject.week_start).to eq(expected_time)
      end
    end

    describe '#week_end' do
      it 'returns end of week' do
        expected_time = Time.zone.parse('2019-03-18T12:00:00+05:30')
        expect(subject.week_end).to eq(expected_time)
      end
    end

    describe '#last_week_start' do
      it 'returns start of week before last' do
        expected_time = Time.zone.parse('2019-03-04T12:00:00+05:30')
        expect(subject.last_week_start).to eq(expected_time)
      end
    end

    describe '#last_week_end' do
      it 'returns end of week before last' do
        expected_time = Time.zone.parse('2019-03-11T12:00:00+05:30')
        expect(subject.last_week_end).to eq(expected_time)
      end
    end
  end

  context 'when delta is two weeks' do
    subject { LeaderboardTimeService.new(2.weeks.ago) }

    describe '#week_start' do
      it 'returns start of week' do
        expected_time = Time.zone.parse('2019-02-25T12:00:00+05:30')
        expect(subject.week_start).to eq(expected_time)
      end
    end

    describe '#week_end' do
      it 'returns end of week' do
        expected_time = Time.zone.parse('2019-03-04T12:00:00+05:30')
        expect(subject.week_end).to eq(expected_time)
      end
    end

    describe '#last_week_start' do
      it 'returns start of week before last' do
        expected_time = Time.zone.parse('2019-02-18T12:00:00+05:30')
        expect(subject.last_week_start).to eq(expected_time)
      end
    end

    describe '#last_week_end' do
      it 'returns end of week before last' do
        expected_time = Time.zone.parse('2019-02-25T12:00:00+05:30')
        expect(subject.last_week_end).to eq(expected_time)
      end
    end
  end
end
