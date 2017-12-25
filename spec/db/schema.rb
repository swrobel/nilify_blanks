ActiveRecord::Schema.define(:version => 0) do

  create_table :posts, :force => true do |t|
    t.string :first_name
    t.string :last_name, :null => false
    t.string :title
    t.text :summary
    t.text :body
    t.column :slug, :citext
    t.integer :views
    t.integer :category_id
    t.string :blog_id
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :postgresql
      t.string :tags, array: true
      t.hstore :custom_data
    else
      t.string :tags
      t.integer :custom_data
    end
  end

end
