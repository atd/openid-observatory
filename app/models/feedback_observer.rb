class FeedbackObserver < ActiveRecord::Observer
  def after_save(f)
    FeedbackMailer.deliver_feedback_email(f)
  end
end
