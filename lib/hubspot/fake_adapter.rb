module Hubspot
  class FakeAdapter
    def fetch_contact_email(object_id)
      object_id == 123 ? 'test@test.com' : nil
    end
  end
end