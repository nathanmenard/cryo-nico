require "rails_helper"

RSpec.describe CouponMailer, type: :mailer do
  describe '#loyalty' do
    let(:client) { FactoryBot.create(:client, email: 'client@gmail.com') }
    let(:coupon) { FactoryBot.create(:coupon, client: client) }
    let(:mail) { described_class.loyalty(coupon).deliver_now }

    it 'has valid from' do
      expect(mail.from).to eq(['contact@cryotera.fr'])
    end

    context 'when client' do
      it 'has valid to' do
        expect(mail.to).to eq([client.email])
      end
    end
    context 'when company client' do
      it 'has valid to' do
        coupon.update!(client: nil, company_client: FactoryBot.create(:company_client))
        expect(mail.to).to eq([coupon.company_client.email])
      end
    end

    it 'has valid subject' do
      expect(mail.subject).to eq('20€ offerts sur votre prochaine réservation')
    end

    it 'assigns @coupon' do
      expect(mail.body.decoded).to match(coupon.code.upcase)
    end
  end
end
