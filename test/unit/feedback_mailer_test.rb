require 'test_helper'

class FeedbackMailerTest < ActionMailer::TestCase
  test "feedback_email" do
    @expected.subject = 'FeedbackMailer#feedback_email'
    @expected.body    = read_fixture('feedback_email')
    @expected.date    = Time.now

    assert_equal @expected.encoded, FeedbackMailer.create_feedback_email(@expected.date).encoded
  end

end
