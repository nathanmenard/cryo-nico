FactoryBot.define do
  factory :company do
    franchise
    name { 'Apple' }
    email { 'contact@apple.com' }
    phone { '0620853909' }
    address { '60 rue des Gobelins' }
    zip_code { '51100' }
    city { 'Reims' }
    siret { '81214811200012' }
  end
end
