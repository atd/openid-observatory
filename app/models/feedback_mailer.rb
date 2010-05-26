class FeedbackMailer < ActionMailer::Base
  

  def feedback_email(f, sent_at = Time.now)
    subject    "[Feedback] #{ f.subject }"
    recipients Site.current.email_with_name
    from       Site.current.email_with_name
    sent_on    sent_at
    
    body       :feedback => f
  end

end
