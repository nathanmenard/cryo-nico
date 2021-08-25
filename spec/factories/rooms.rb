FactoryBot.define do
  factory :room do
    franchise
    name { 'Salle de Cryothérapie' }
    capacity { 4 }
  end
end
