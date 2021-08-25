FactoryBot.define do
  factory :campaign_template do
    franchise
    external_id { 1 }
    name { 'My template name' }
    subject { 'Hello world' }
    html { '<strong>Hello</strong>' }
  end
end
