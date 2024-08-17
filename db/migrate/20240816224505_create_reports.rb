class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :document, null: false, foreign_key: true
      t.text :data, null: false, default: ""

      t.timestamps
    end
  end
end
