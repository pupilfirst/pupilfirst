module Hubspot
  class Adapter
    def fetch_contact_email(object_id)
      Hubspot::Contact.find_by_id(object_id)&.email
    rescue Hubspot::RequestError
      nil
    end
  end
end