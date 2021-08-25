class ClientMailer < ApplicationMailer
  def password_forgotten(client)
    @client = client
    mail(to: client.email, subject: 'Mot de passe oublié')
  end

  def new_reservation(reservation)
    @client = reservation.client
    @reservation = reservation
    mail(to: @client.email, subject: 'Votre réservation')
  end

  def invoice(payment)
    @payment = payment
    invoice_url = "http://www.africau.edu/images/default/sample.pdf"
    invoice = open(invoice_url).read
    attachments['facture.pdf'] = invoice
    client = @payment.client.present? ? @payment.client : @payment.company_client
    mail(to: client.email, subject: 'Votre facture')
  end

  def ask_for_review(reservation)
    @reservation = reservation
    @client = reservation.client || reservation.company_client
    mail(to: @client.email, subject: "Qu'avez-vous pensé de nous ?")
  end

  def invite(current_client, email)
    @current_client = current_client
    @email = email
    mail(to: @email, subject: "#{current_client.full_name} vous invite à rejoindre Cryotera !")
  end

  def invite_by_admin(client)
    @client = client
    mail(to: @client.email, subject: "Vous avez été invité à rejoindre Cryotera !")
  end

  def birthday(client)
    @client = client
    mail(to: @client.email, subject: 'Joyeux anniversaire !')
  end
end
