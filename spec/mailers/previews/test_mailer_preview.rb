class TestMailerPreview < ActionMailer::Preview
  def test_mail
    TestMailer.test_mail('test@example.com')
  end
end
