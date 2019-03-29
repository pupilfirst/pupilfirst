require 'rails_helper'

describe Zoom::CreateFacultyConnectService do
  subject { described_class.new(connect_request, mock: false) }

  let(:api_service) { instance_double(Zoom::ApiService) }
  let(:success_response) { double('RestClient Response', code: 201, body: { body: 'xxxxx' }.to_json) }
  let(:error_response) { double('RestClient Response', code: 404) }
  let(:connect_request) { create :connect_request }

  describe '#create' do
    context 'when the Zoom API responds with a 201 code' do
      it 'returns the JSON parsed body of the response' do
        # Stubs as required.
        expect(Zoom::ApiService).to receive(:new).and_return(api_service)
        expect(api_service).to receive(:post).with('users/host_user_id/meetings', meeting_details)
          .and_return(success_response)

        expect(subject.create).to eq('body' => 'xxxxx')
      end
    end

    context 'when the Zoom API responds with a code other than 201' do
      it 'raises an error containing the response' do
        # Stubs as required.
        expect(Zoom::ApiService).to receive(:new).and_return(api_service)
        expect(api_service).to receive(:post).with('users/host_user_id/meetings', meeting_details)
          .and_return(error_response)

        expect { subject.create }.to raise_error("Unexpected response while creating Zoom meeting: #{error_response}")
      end
    end
  end

  def meeting_details
    {
      topic: topic,
      type: '2',
      start_time: connect_request.slot_at.strftime('%Y-%m-%dT%H:%M:%S'),
      timezone: 'Asia/Calcutta',
      duration: '30',
      settings: {
        join_before_host: true,
        participant_video: true
      }
    }
  end

  def topic
    startup = connect_request.startup.name
    faculty = connect_request.faculty.name
    "#{startup} / #{faculty} (Office Hour)"
  end
end
