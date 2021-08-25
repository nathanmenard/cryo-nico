require 'rails_helper'

Rails.application.load_tasks

describe 'birthday:send_email', type: :mailer do
  it 'sends email to every client/company/client whose birthday is today' do
    client_a = FactoryBot.create(:client, birth_date: Date.today - 20.years)
    client_b = FactoryBot.create(:client, birth_date: Date.today - 10.years)
    client_c = FactoryBot.create(:client, birth_date: Date.today - 10.days - 30.years)
    company_client_a = FactoryBot.create(:company_client, birth_date: Date.today - 20.years)
    company_client_b = FactoryBot.create(:company_client, birth_date: Date.today - 10.years)
    company_client_c = FactoryBot.create(:company_client, birth_date: Date.today - 10.days - 30.years)

    #expect {
      Rake::Task['birthday:send_email'].invoke
    #}.to change(ActionMailer::Base.deliveries, :count).by(4)

    froms = ActionMailer::Base.deliveries.map(&:from).flatten.uniq
    expect(froms).to eq(['contact@cryotera.fr'])

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten.sort
    expect(recipients).to eq([client_a.email, client_b.email, company_client_a.email, company_client_b.email])

    subjects = ActionMailer::Base.deliveries.map(&:subject).uniq
    expect(subjects).to eq(['Joyeux anniversaire !'])
  end
end
