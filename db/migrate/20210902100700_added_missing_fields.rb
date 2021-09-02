class AddedMissingFields < ActiveRecord::Migration[5.2]
  def change
  	add_column :tabienrodpramool_details, :price_status, :text
  	add_column :tabienrodpramool_details, :is_duplicate, :text
  end
end
