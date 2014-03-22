class CreateConclusions < ActiveRecord::Migration
  def change
    create_table :conclusions do |t|
      t.integer :book_id
      t.string :question1
      t.string :question2
      t.string :question3
      t.string :question4
    end
  end
end
