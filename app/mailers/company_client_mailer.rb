class CompanyClientMailer < ApplicationMailer
  def invite(company_client)
    @company_client = company_client
    mail(to: company_client.email, subject: 'Créez votre compte')
  end

  def new_credit(company_client)
    @company_client = company_client
    mail(to: company_client.email, subject: 'Vous venez de recevoir un crédit !')
  end

  def birthday(company_client)
    @company_client = company_client
    mail(to: @company_client.email, subject: 'Joyeux anniversaire !')
  end
end
