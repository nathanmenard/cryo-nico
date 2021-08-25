class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: user.email, subject: 'Bienvenue sur Cryotera')
  end

  def password_forgotten(user)
    @user = user
    mail(to: user.email, subject: 'Mot de passe oublié')
  end
end
