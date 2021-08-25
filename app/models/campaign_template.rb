class CampaignTemplate < ApplicationRecord
  belongs_to :franchise

  validates :external_id, presence: true, numericality: true, uniqueness: true
  validates :name, presence: true
  validates :subject, presence: true

  def self.fetch(franchise)
    options = {
      headers: { 
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'api-key': franchise.sendinblue_api_key,
      },
      query: {
        templateStatus: 'true',
      }
    }
    response = HTTParty.get("https://api.sendinblue.com/v3/smtp/templates", options)
    if response.success?
      data = JSON.parse(response.body)
      templates = data['templates']
      templates.each do |template|
        next if template['subject'].blank?
        if tpl = franchise.campaign_templates.find_by(external_id: template['id'])
          tpl.update!(
            name: template['name'],
            subject: template['subject'],
            html: template['htmlContent'],
          )
        else
          franchise.campaign_templates.create!(
            external_id: template['id'],
            name: template['name'],
            subject: template['subject'],
            html: template['htmlContent'],
          )
        end
      end
      return true
    end
    false
  end
end
