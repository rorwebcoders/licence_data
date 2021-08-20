class CreateTtabienDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :ttabien_details do |t|
    	t.text :url
    	t.date :date_created
    	t.text :license_group
    	t.text :license_number
    	t.text :price
    	t.text :location
    	t.text :license_status
    	t.text :color
    	t.text :processing_status
      t.timestamps
    end
  end
end
