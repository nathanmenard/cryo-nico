FactoryBot.define do
  factory :survey_question do
    survey
    body { "Avez-vous été satisfait de l'accueil ?" }
  end
end
