class CreateSurveyQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_questions do |t|
      t.references :survey, null: false, index: true, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
