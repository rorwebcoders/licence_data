class AddedPricingStatus < ActiveRecord::Migration[5.2]
  def change
  	add_column :tabien9_details, :price_status, :text
  	add_column :duplicate_temps, :price_status, :text
  	add_column :tabieninfinity_details, :price_status, :text
  	add_column :teeneetabien_details, :price_status, :text
  	add_column :kaitabien_details, :price_status, :text
  	add_column :tabien999_details, :price_status, :text
  	add_column :tabiend789_details, :price_status, :text
  	add_column :tabienrodnamchock_details, :price_status, :text
  	add_column :lekpramool_details, :price_status, :text
  	add_column :raktabien_details, :price_status, :text
  end
end
