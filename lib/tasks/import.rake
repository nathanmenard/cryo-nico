require 'csv'

namespace :import do
  task clients: :environment do
    data = CSV.read("#{Rails.root}/Export.csv")
    data[1..].each do |client|
      gender = client[1]
      last_name = client[4]
      first_name = client[2]
      phone = client[5]
      email = client[6]
      created_at = client[7]

      next if last_name.nil?
      next if first_name.nil?
      next if email.nil? && phone.nil?
      next if !email.nil? && !email.include?('@')

      unless phone.nil?
        phone = phone
          .gsub(/\s+/, '')
          .gsub(/\+?336/, '06')
          .gsub(/\+?337/, '07')
          .gsub(/\+?333/, '03')
          .gsub(/\+?339/, '09')
          .gsub(/\+?324/, '04')

        if phone.length != 10
          phone = nil
        end
      end

      male = gender.strip == 'Homme' ? true : false

      Client.create(
        franchise: Franchise.first,
        last_name: last_name.strip,
        first_name: first_name.strip,
        email: email,
        phone: phone,
        male: male,
        created_at: created_at,
        updated_at: created_at
      )
    end
  end
end
