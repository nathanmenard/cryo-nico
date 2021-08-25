require "rails_helper"

RSpec.describe CompanyClientMailer, type: :mailer do
  describe '#invite' do
    let(:company_client) { FactoryBot.create(:company_client) }
    let(:mail) { described_class.invite(company_client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([company_client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Créez votre compte')
    end

    it 'assigns @company_client' do
      expect(mail.body.decoded).to match(company_client.first_name)
    end
  end

  describe '#new_credit' do
    let(:company_client) { FactoryBot.create(:company_client) }
    let!(:credit)         { FactoryBot.create(:credit, company_client: company_client) }
    let(:mail) { described_class.new_credit(company_client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([company_client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Vous venez de recevoir un crédit !')
    end

    it 'assigns @product' do
      expect(mail.body.decoded).to match(company_client.credits.last.product.name)
    end
  end

  describe '#birthday' do
    let(:company_client) { FactoryBot.create(:company_client) }
    let(:mail) { described_class.birthday(company_client).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([company_client.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Joyeux anniversaire !')
    end

    it 'assigns @company_client' do
      expect(mail.body.decoded).to match(company_client.first_name)
    end
  end
end
