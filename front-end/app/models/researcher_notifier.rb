class ResearcherNotifier < ActionMailer::Base

  def self.password_reset(researcher)
    researcher.create_reset_code
    email = PendingEmail.new
    email.subject = "Hey, #{researcher.user_name}, here's your reset code"
    email.recipient = researcher.email
    email.message_content = "Hey, it looks like you're having kind of a lame time with your password. Click this link to reset your password and get back to work: 
    <a href=\"http://#{SITE_URL}reset/#{researcher.reset_code}\">http://#{SITE_URL}reset/#{researcher.reset_code}</a>"
    email.sent = false
    email.save
  end

  def self.check_for_messages
    emails = PendingEmail.find(:all, :conditions => {:sent => false})
    emails.each do |email|
      ResearcherNotifier.deliver_notification(email)
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