class Campaign < ApplicationRecord
  include ActionView::Helpers::TextHelper
  attr_accessor :email # for test email sending

  belongs_to :franchise
  belongs_to :campaign_template, optional: true

  validates :name, presence: true
  validates :body, presence: true
  validates :sms, inclusion: [true, false]
  validates :draft, inclusion: [true, false]

  after_create :create_in_sendinblue
  after_update :update_recipients

  def send_test_email(email)
    options = {
      headers: sendinblue_headers,
      body: {
        emailTo: [email],
      }.to_json
    }
    response = HTTParty.post("https://api.sendinblue.com/v3/emailCampaigns/#{sendinblue_campaign_id}/sendTest", options)
    response.success?
  end

  def send_now
    return false if draft == false
    options = {
      headers: sendinblue_headers,
      body: {}.to_json
    }
    response = HTTParty.post("https://api.sendinblue.com/v3/emailCampaigns/#{sendinblue_campaign_id}/sendNow", options)
    if response.success?
      update(draft: false)
      return true
    end
    false
  end

  private

  def update_recipients
    return if draft == false
    return if previous_changes['filters'].nil?
    recipients = franchise.clients
    empty_sendinblue_list
    filters.each do |key, value|
      if key == 'objectives' && value.any? && value.reject(&:blank?).any?
        franchise.clients.each do |client|
          if (client.objectives & value).empty?
            recipients = recipients.reject { |x| x.id == client.id }
          end
        end
      end
      if key == 'product_id' && value.present?
        recipients.each do |client|
          product_ids = client.reservations.joins(:product_price).pluck('product_id')
          if product_ids.exclude?(value)
            recipients = recipients.reject { |x| x.id == client.id }
          end
        end
      end
      if key == 'last_reservation_date' && value.present?
        recipients.each do |client|
          last_reservation = client.reservations.order(start_time: :desc).first
          last_reservation_date = last_reservation.start_time.to_date.to_s
          if last_reservation_date != value
            recipients = recipients.reject { |x| x.id == client.id }
          end
        end
      end
      if key == 'male' && value == 'true'
        recipients = recipients.select { |client| client.male == true }
      end
      if key == 'male' && value == 'false'
        recipients = recipients.select { |client| client.male == false }
      end
    end
    if sms?
      update(recipients: recipients.pluck(:phone))
    else
      update(recipients: recipients.pluck(:email))
    end
    save_contacts_in_sendinblue
  end

  def create_in_sendinblue
    options = {
      headers: sendinblue_headers,
      body: {
        name: "Liste test campagne2 ##{id}",
        folderId: 27,
      }.to_json
    }
    response = HTTParty.post('https://api.sendinblue.com/v3/contacts/lists', options)
    list_id = JSON.parse(response.body)['id']
    update(sendinblue_list_id: list_id)

    if sms?
      url = 'https://api.sendinblue.com/v3/smsCampaigns'
      options_2 = {
        headers: sendinblue_headers,
        body: {
          sender: 'Cryotera',
          name: name,
          content: 'Bonjour, message de test Sendinblue',
          recipients: {
            listIds: [sendinblue_list_id],
          },
        }.to_json
      }
    else
      return false if campaign_template.nil?
      url = 'https://api.sendinblue.com/v3/emailCampaigns'
      options_2 = {
        headers: sendinblue_headers,
        body: {
          sender: {
            name: 'Cryotera',
            email: 'contact@cryotera.fr',
          },
          name: name,
          subject: campaign_template.subject,
          templateId: campaign_template.external_id,
          # htmlContent: body,
          recipients: {
            listIds: [sendinblue_list_id],
          },
        }.to_json
      }
    end
    response_2 = HTTParty.post(url, options_2)
    p response_2
    campaign_id = JSON.parse(response_2.body)['id']
    update(sendinblue_campaign_id: campaign_id)
  end

  def empty_sendinblue_list
    return if recipients.nil?
    recipients.each do |recipient|
      options = {
        headers: sendinblue_headers,
        body: {
          unlinkListIds: [sendinblue_list_id],
        }.to_json
      }
      a = HTTParty.put("https://api.sendinblue.com/v3/contacts/#{recipient}", options)
      p "insert #{recipient}: #{a.code}"
      if a.code == 400
        p a.body
      end
    end
  end

  def save_contacts_in_sendinblue
    recipients.each do |recipient|
      options = {
        headers: sendinblue_headers,
        body: {
          listIds: [sendinblue_list_id],
        }.to_json
      }
      a = HTTParty.put("https://api.sendinblue.com/v3/contacts/#{recipient}", options)
      p "update #{recipient}: #{a.code}"
      if a.code == 404
        options_b = {
          headers: sendinblue_headers,
          body: {
            email: recipient,
            listIds: [sendinblue_list_id],
          }.to_json
        }
        b = HTTParty.post('https://api.sendinblue.com/v3/contacts', options_b)
        p "create #{recipient}: #{b.code}"
      end
    end
  end

  def sendinblue_headers
    {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      'api-key': franchise.sendinblue_api_key,
    }
  end
end
