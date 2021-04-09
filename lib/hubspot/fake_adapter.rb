module Hubspot
  class FakeAdapter
    def fetch_contact_email(_object_id)
      'test@test.com'
    end
  end
end