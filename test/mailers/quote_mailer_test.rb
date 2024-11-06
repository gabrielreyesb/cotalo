require "test_helper"

class QuoteMailerTest < ActionMailer::TestCase
  test "send_quote" do
    mail = QuoteMailer.send_quote
    assert_equal "Send quote", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
