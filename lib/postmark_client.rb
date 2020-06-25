class PostmarkClient < Postmark::Client
  def create_sender_signature(name, email)
    options = { from_email: email, name: name }
    data = serialize(Postmark::HashHelper.to_postmark(options))
    format_response http_client.post("senders", data)
  end
end
