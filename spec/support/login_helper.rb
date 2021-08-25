module LoginHelper
  def login_admin
    admin = FactoryBot.create(:user)
    session[:user_id] = admin.id
  end
end
