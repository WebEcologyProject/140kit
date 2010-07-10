class ResearcherMailer < ActionMailer::Base
  def self.check_for_messages
    puts "In check_for_messages"
    emails = PendingEmail.find(:all, :conditions => {:sent => false})
    emails.each do |email|
      ResearcherMailer.deliver_notification(email)
      puts "Supposedly sent email to #{email.recipient}"
      email.sent = true
      email.save!
    end
    puts "ran check_for_messages at #{Time.now}"
  end

  def notification(email)
    subject    email.subject
    recipients email.recipient
    from       '140kit@gmail.com'
    sent_on    Time.now
    body       :message_content => email.message_content, :subject => email.subject
    content_type "text/html"
  end

end
