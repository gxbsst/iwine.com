ActionMailer::Base.smtp_settings = {
    :address              => "mail.sidways.com",
    :port                 => 25,
    :domain               => 'sidways.com',
    :user_name            => 'patrick_contact@sidways.com',
    :password             => '123456',
    :authentication       => :login,
    :enable_starttls_auto => true
    #:tls => true # ssl
}