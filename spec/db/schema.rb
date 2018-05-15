ActiveRecord::Schema.define(:version => 0) do
  adapter_type = connection.adapter_name.downcase.to_sym

  if adapter_type == :postgresql
    enable_extension "citext"
    enable_extension "hstore"
  end

  create_table :posts, :force => true do |t|
    t.string :first_name
    t.string :last_name, :null => false
    t.string :title
    t.text :summary
    t.text :body
    t.integer :views
    t.integer :category_id
    t.string :blog_id
    t.json :json if %i[mysql2 postgresql].include? adapter_type
    if adapter_type == :postgresql
      t.citext :slug
      t.string :array, array: true
      t.hstore :hstore
      t.jsonb :jsonb
    end
  end
end
