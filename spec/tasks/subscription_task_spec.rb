require 'rails_helper'

Rails.application.load_tasks

describe 'subscription:ask' do
  xit 'creates credit for every active reservation that is due today' do
    client = FactoryBot.create(:client)
    product = FactoryBot.create(:product)
    subscription_plan = FactoryBot.create(:subscription_plan, product: product, session_count: 3)
    subscription = FactoryBot.create(:subscription, subscription_plan: subscription_plan, client: client, status: 'active')
    subscription_b = FactoryBot.create(:subscription, client: client, status: 'canceled_by_user')
    subscription_c = FactoryBot.create(:subscription, client: client, status: 'canceled_by_admin')
    expect do
      Rake::Task['subscription:sync'].invoke
    end.to change(client.credits, :count).from(0).to(3)
    expect(client.credits.pluck(:product_id).uniq).to eq([product.id])
  end
end
