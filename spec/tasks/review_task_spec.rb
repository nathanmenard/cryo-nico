require 'rails_helper'

Rails.application.load_tasks

describe 'review:ask' do
  xit 'sends an email to every client for reservations that finished yesterday' do
    reservation_a = FactoryBot.create(:reservation, start_time: Date.yesterday, client: FactoryBot.create(:client), company_client: nil)
    reservation_b = FactoryBot.create(:reservation, start_time: Date.yesterday, client: nil, company_client: FactoryBot.create(:company_client))
    reservation_c = FactoryBot.create(:reservation, start_time: Date.today - 2.days)
    expect {
      Rake::Task['review:ask'].invoke
    }.to change(ActionMailer::Base.deliveries, :count).by(2)
    recipients = ActionMailer::Base.deliveries.map(&:to).flatten.sort
    expect(recipients).to eq([reservation_a.client.email, reservation_b.company_client.email].sort)
  end
end
