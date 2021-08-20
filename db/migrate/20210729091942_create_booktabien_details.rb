class CreateBooktabienDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :booktabien_details do |t|
    	t.text :url
    	t.date :date_created
    	t.text :license_group
    	t.text :license_number
    	t.text :price
    	t.text :location
    	t.text :license_status
    	t.text :color
    	t.text :processing_status
      t.text :is_duplicate
      t.text :price_status
      t.timestamps
    end
  end
end
