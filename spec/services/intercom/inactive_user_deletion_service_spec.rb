require 'rails_helper'

describe Intercom::InactiveUserDeletionService do
  subject { described_class }

  describe '.new' do
    it 'creates Intercom and SendInBlue API clients' do
      expect(Intercom::Client).to receive(:new).with(token: 'test_intercom_access_token')
      expect(Sendinblue::Mailin).to receive(:new).with('https://api.sendinblue.com/v2.0', 'test_sendinblue_v2_api_key')
      subject.new
    end
  end

  describe '#execute' do
    subject { described_class.new }

    let(:sendinblue_client) { instance_double Sendinblue::Mailin }
    let(:intercom_client) { instance_double Intercom::Client }

    let(:location_data_1) { OpenStruct.new(city_name: Faker::Name.name, region_name: Faker::Name.name) }
    let(:location_data_2) { OpenStruct.new }

    let(:intercom_user_1) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: nil,
        unsubscribed_from_emails: false,
        custom_attributes: {},
        location_data: location_data_1
    end

    let(:intercom_user_2) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: nil,
        unsubscribed_from_emails: false,
        custom_attributes: { 'phone' => '9876543210' },
        location_data: location_data_2
    end

    let(:intercom_user_3) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: '7896543210',
        unsubscribed_from_emails: true,
        custom_attributes: {},
        location_data: location_data_2
    end

    let(:intercom_user_4) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: nil,
        unsubscribed_from_emails: true,
        custom_attributes: { 'college' => Faker::Lorem.word },
        location_data: location_data_2
    end

    let(:intercom_user_5) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: nil,
        unsubscribed_from_emails: false,
        custom_attributes: {},
        location_data: location_data_1
    end

    let(:intercom_user_6) do
      double 'Intercom User',
        email: Faker::Internet.email,
        name: Faker::Name.name,
        phone: nil,
        unsubscribed_from_emails: false,
        custom_attributes: {},
        location_data: location_data_1
    end

    let(:segment_1_contact) do
      {
        email: intercom_user_1.email,
        listid: [1],
        attributes: { NAME: intercom_user_1.name, CITY: intercom_user_1.location_data.city_name, STATE: intercom_user_1.location_data.region_name },
        blacklisted: 0
      }
    end

    let(:segment_2_contact) do
      {
        email: intercom_user_2.email,
        listid: [1],
        attributes: { NAME: intercom_user_2.name, PHONE: '9876543210' },
        blacklisted: 0
      }
    end

    let(:segment_3_contact) do
      {
        email: intercom_user_3.email,
        listid: [2],
        attributes: { NAME: intercom_user_3.name, PHONE: '7896543210' },
        blacklisted: 1
      }
    end

    let(:segment_4_contact) do
      {
        email: intercom_user_4.email,
        listid: [2],
        attributes: { NAME: intercom_user_4.name, COLLEGE: intercom_user_4.custom_attributes['college'] },
        blacklisted: 1
      }
    end

    before do
      allow(Intercom::Client).to receive(:new).and_return(intercom_client)
      allow(Sendinblue::Mailin).to receive(:new).and_return(sendinblue_client)

      allow(intercom_client).to receive_message_chain(:segments, :all).and_return(
        [
          OpenStruct.new(name: 'Stale Applicants - Last Seen Known', id: '11'),
          OpenStruct.new(name: 'Stale Applicants - Last Seen Unknown', id: '12'),
          OpenStruct.new(name: 'Stale Leads - Email - Last Seen Known', id: '13'),
          OpenStruct.new(name: 'Stale Leads - Email - Last Seen Unknown', id: '14'),
          OpenStruct.new(name: 'Clean Up Leads - Delete often', id: '15'),
          OpenStruct.new(name: 'Clean Up Leads - Delete often 2', id: '16')
        ]
      )

      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '11').and_return([intercom_user_1])
      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '12').and_return([intercom_user_2])
      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '13').and_return([intercom_user_3])
      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '14').and_return([intercom_user_4])
      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '15').and_return([intercom_user_5])
      allow(intercom_client).to receive_message_chain(:users, :find_all).with(segment_id: '16').and_return([intercom_user_6])

      allow(sendinblue_client).to receive(:get_lists).and_return(
        'data' => [
          { 'name' => 'Stale Applicants', 'id' => 1 },
          { 'name' => 'Stale Leads', 'id' => 2 }
        ]
      )
    end

    it 'sends stale users to SendinBlue and deletes from Intercom' do
      expect(sendinblue_client).to receive(:create_update_user).with(segment_1_contact)
      expect(sendinblue_client).to receive(:create_update_user).with(segment_2_contact)
      expect(sendinblue_client).to receive(:create_update_user).with(segment_3_contact)
      expect(sendinblue_client).to receive(:create_update_user).with(segment_4_contact)

      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_1])
      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_2])
      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_3])
      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_4])
      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_5])
      expect(intercom_client).to receive_message_chain(:users, :submit_bulk_job).with(delete_items: [intercom_user_6])

      subject.execute
    end
  end
end
