require "rails_helper"

RSpec.describe ClientMailer, type: :mailer do
  describe '#password_forgotten' do
    let(:client) { FactoryBot.create(:client) }
    let(:mail) { described_class.password_forgotten(client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Mot de passe oublié')
    end

    it 'assigns @client' do
      expect(mail.body.decoded).to match(client.first_name)
    end
  end

  describe '#invite_by_admin' do
    let(:client) { FactoryBot.create(:client) }
    let(:mail) { described_class.invite_by_admin(client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Vous avez été invité à rejoindre Cryotera !')
    end

    it 'assigns @client' do
      expect(mail.body.decoded).to match(client.first_name)
    end
  end

  describe '#new_reservation' do
    let(:reservation) { FactoryBot.create(:reservation) }
    let(:mail) { described_class.new_reservation(reservation).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([reservation.client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Votre réservation')
    end

    it 'assigns @client' do
      expect(mail.body.decoded).to match(reservation.client.first_name)
    end

    it 'assigns @reservation' do
      expect(mail.body.decoded).to match(I18n.l(reservation.start_time, format: :short))
    end
  end

  describe '#invoice' do
    let(:payment) { FactoryBot.create(:payment) }
    let(:mail) { described_class.invoice(payment).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([payment.client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Votre facture')
    end

    it 'assigns @payment' do
      expect(mail.text_part.body.decoded).to match(payment.client.first_name)
      # expect(mail.text_part.body.decoded).to match(I18n.l(payment.start_time, format: :short))
    end

    it 'attaches invoice' do
      expect(mail.attachments.count).to eq(1)
      attachment = mail.attachments.first
      expect(attachment.content_type).to include('application/pdf')
      expect(attachment.filename).to eq('facture.pdf')
    end
  end

  describe '#ask_for_review' do
    let(:reservation) { FactoryBot.create(:reservation) }
    let(:mail) { described_class.ask_for_review(reservation).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([reservation.client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq("Qu'avez-vous pensé de nous ?")
    end

    it 'assigns @reservation' do
      expect(mail.body.decoded).to match(reservation.client.first_name)
    end
  end

  describe '#birthday' do
    let(:client) { FactoryBot.create(:client) }
    let(:mail) { described_class.birthday(client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Joyeux anniversaire !')
    end

    it 'assigns @client' do
      expect(mail.body.decoded).to match(client.first_name)
    end
  end
end
