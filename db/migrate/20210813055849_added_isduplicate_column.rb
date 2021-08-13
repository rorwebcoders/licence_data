class AddedIsduplicateColumn < ActiveRecord::Migration[5.2]
  def change
  	add_column :buddytabien_details, :is_duplicate, :text
  	add_column :tabienhot_details, :is_duplicate, :text
  end
end
