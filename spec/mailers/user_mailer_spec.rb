require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe '#welcome' do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { described_class.welcome(user).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([user.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Bienvenue sur Cryotera')
    end

    it 'assigns @user' do
      expect(mail.body.decoded).to match(user.first_name)
    end
  end

  describe '#password_forgotten' do
    let(:user) { FactoryBot.create(:user, email: 'user@gmail.com') }
    let(:mail) { described_class.password_forgotten(user).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    it 'has valid to' do
      expect(mail.to).to eq([user.email])
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('Mot de passe oublié')
    end

    it 'assigns @user' do
      expect(mail.body.decoded).to match(user.first_name)
    end
  end
end
