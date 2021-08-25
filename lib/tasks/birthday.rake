namespace :birthday do
  task send_email: :environment do
    clients = Client.birthday_today
    clients.each do |client|
      ClientMailer.birthday(client).deliver_now
    end

    company_clients = CompanyClient.birthday_today
    company_clients.each do |company_client|
      CompanyClientMailer.birthday(company_client).deliver_now
    end

    exit
  end
end
