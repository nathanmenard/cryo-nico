require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'after_create #generate_coupon' do
    let(:client) { FactoryBot.create(:client) }
    context 'when has no loyalty coupon' do
      context 'when payments.sum = 550' do
        context 'when has no loyalty coupon' do
          context 'when client is subscriber' do
            it 'does not generate coupon' do
              FactoryBot.create(:subscription, client: client)
              expect do
                FactoryBot.create(:payment, client: client, amount: 100*100)
                FactoryBot.create(:payment, client: client, amount: 450*100)
              end.not_to change(client.coupons, :count)
            end
          end
          it 'generates coupon' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(client.coupons, :count).by(1)
            expect(client.coupons.last.name).to eq("20€ offerts après 550€ dépensés")
            expect(client.coupons.last.value).to eq(20)
            expect(client.coupons.last.percentage).to eq(false)
            expect(client.coupons.last.usage_limit).to eq(1)
            expect(client.coupons.last.usage_limit_per_person).to eq(1)
            expect(client.coupons.last.loyalty).to eq(true)
            expect(client.coupons.last.code).to eq('fidelite20')
            expect(client.coupons.last.start_date).to eq(Date.today)
            expect(client.coupons.last.end_date).to eq(Date.today + 30.days)
          end
          it 'sends coupon via email' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(ActionMailer::Base.deliveries, :count).by(1)
            expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
            expect(ActionMailer::Base.deliveries.first.to).to eq([client.email])
            expect(ActionMailer::Base.deliveries.first.subject).to eq('20€ offerts sur votre prochaine réservation')
            expect(ActionMailer::Base.deliveries.first.body.decoded).to match(Coupon.last.code.upcase)
          end
        end
        context 'when payments.sum > 550' do
          it 'generates coupon' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 200*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(client.coupons, :count).by(1)
            expect(client.coupons.last.name).to eq("20€ offerts après 550€ dépensés")
            expect(client.coupons.last.value).to eq(20)
            expect(client.coupons.last.percentage).to eq(false)
            expect(client.coupons.last.usage_limit).to eq(1)
            expect(client.coupons.last.usage_limit_per_person).to eq(1)
            expect(client.coupons.last.loyalty).to eq(true)
            expect(client.coupons.last.code).to eq('fidelite20')
            expect(client.coupons.last.start_date).to eq(Date.today)
            expect(client.coupons.last.end_date).to eq(Date.today + 30.days)
          end
          it 'sends coupon via email' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 200*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(ActionMailer::Base.deliveries, :count).by(1)
            expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
            expect(ActionMailer::Base.deliveries.first.to).to eq([client.email])
            expect(ActionMailer::Base.deliveries.first.subject).to eq('20€ offerts sur votre prochaine réservation')
            expect(ActionMailer::Base.deliveries.first.body.decoded).to match(Coupon.last.code.upcase)
          end
        end
      end
      context 'when has loyalty coupon' do
        context 'when payments.sum = 550 since last loyalty coupon' do
          it 'generates coupon' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100) # this generates loyalty coupon

              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(client.coupons, :count).by(2)
            expect(client.coupons.last.name).to eq("20€ offerts après 550€ dépensés")
            expect(client.coupons.last.value).to eq(20)
            expect(client.coupons.last.percentage).to eq(false)
            expect(client.coupons.last.usage_limit).to eq(1)
            expect(client.coupons.last.usage_limit_per_person).to eq(1)
            expect(client.coupons.last.loyalty).to eq(true)
            expect(client.coupons.last.code).to eq('fidelite20')
            expect(client.coupons.last.start_date).to eq(Date.today)
            expect(client.coupons.last.end_date).to eq(Date.today + 30.days)
          end
          it 'sends coupon via email' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100) # this generates loyalty coupon

              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(ActionMailer::Base.deliveries, :count).by(2)
            expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
            expect(ActionMailer::Base.deliveries.first.to).to eq([client.email])
            expect(ActionMailer::Base.deliveries.first.subject).to eq('20€ offerts sur votre prochaine réservation')
            expect(ActionMailer::Base.deliveries.first.body.decoded).to match(Coupon.last.code.upcase)
          end
        end
        context 'when payments.sum > 550 since last loyalty coupon' do
          it 'generates coupon' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100) # this generates loyalty coupon

              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(client.coupons, :count).by(2)
            expect(client.coupons.last.name).to eq("20€ offerts après 550€ dépensés")
            expect(client.coupons.last.value).to eq(20)
            expect(client.coupons.last.percentage).to eq(false)
            expect(client.coupons.last.usage_limit).to eq(1)
            expect(client.coupons.last.usage_limit_per_person).to eq(1)
            expect(client.coupons.last.loyalty).to eq(true)
            expect(client.coupons.last.code).to eq('fidelite20')
            expect(client.coupons.last.start_date).to eq(Date.today)
            expect(client.coupons.last.end_date).to eq(Date.today + 30.days)
          end
          it 'sends coupon via email' do
            expect do
              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100) # this generates loyalty coupon

              FactoryBot.create(:payment, client: client, amount: 100*100)
              FactoryBot.create(:payment, client: client, amount: 450*100)
            end.to change(ActionMailer::Base.deliveries, :count).by(2)
            expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
            expect(ActionMailer::Base.deliveries.first.to).to eq([client.email])
            expect(ActionMailer::Base.deliveries.first.subject).to eq('20€ offerts sur votre prochaine réservation')
            expect(ActionMailer::Base.deliveries.first.body.decoded).to match(Coupon.last.code.upcase)
          end
        end
      end
    end
  end
end
