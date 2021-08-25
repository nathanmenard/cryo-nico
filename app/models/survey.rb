class Survey < ApplicationRecord
  belongs_to :product

  has_many :survey_questions

  validates :name, presence: true
end
