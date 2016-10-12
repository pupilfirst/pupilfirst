shared_context 'mocked_instamojo' do
  let(:instamojo_payment_request_id) { SecureRandom.hex }
  let(:long_url) { 'http://example.com/a/b' }
  let(:short_url) { 'http://example.com/a/b' }

  before do
    # stub any requests to instamojo
    allow_any_instance_of(Instamojo).to receive(:create_payment_request).and_return(
      id: instamojo_payment_request_id,
      status: 'Pending',
      long_url: long_url,
      short_url: short_url
    )
  end
end
