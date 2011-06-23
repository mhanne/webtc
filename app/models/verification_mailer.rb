class VerificationMailer < ActionMailer::Base

  default :from => WeBTC::Application.config.mail[:from]

  def verification_code verification
    @verification = verification
    @transaction = @verification.transaction
    @user = @verification.user
    @link = verify_transaction_url(@verification.secret)
    mail(:to => @user.email,
         :subject => t('mail.verification.subject'),
         :body => t('mail.format',
                    :greeting => t('mail.greeting', :user => @user.email),
                    :body => t('mail.verification.body',
                               :amount => @transaction.amount,
                               :unit => @user.setting(:units),
                               :address => @transaction.address,
                               :link => @link,
                               :code => @verification.secret),
                    :salutation => t('mail.salutation')))

  end

end
