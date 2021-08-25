require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'POST :help' do
    let(:franchise) { FactoryBot.create(:franchise, name: 'Reims') }
    let(:current_user) { FactoryBot.create(:user, franchise: franchise) }
    context 'when not logged in' do
      it' redirects to login form' do
        post :help, params: { body: 'Hello World..' }
        expect(response).to redirect_to(admin_path)
      end
    end
    it 'sends email to Saïd' do
      expect do
        session[:user_id] = current_user.id
        post :help, params: { body: 'Hello World..' }
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
      expect(ActionMailer::Base.deliveries.first.to).to eq(['sayid.mimouni@gmail.com'])
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Cryotera Reims - Demande d'aide")
      expect(ActionMailer::Base.deliveries.first.body.decoded).to eq('Hello World..')
    end
    it 'redirects back' do
      session[:user_id] = current_user.id
      post :help, params: { body: 'Hello World..' }
      expect(response).to redirect_to(clients_path)
    end
  end
end
