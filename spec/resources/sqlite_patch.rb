# patches adapter in rails 2.0 which mistakenly made time attributes map to datetime column type
ActiveRecord::ConnectionAdapters::SQLiteAdapter.class_eval do
  def native_database_types #:nodoc:
    {
      :primary_key => default_primary_key_type,
      :string      => { :name => "varchar", :limit => 255 },
      :text        => { :name => "text" },
      :integer     => { :name => "integer" },
      :float       => { :name => "float" },
      :decimal     => { :name => "decimal" },
      :datetime    => { :name => "datetime" },
      :timestamp   => { :name => "datetime" },
      :time        => { :name => "time" },
      :date        => { :name => "date" },
      :binary      => { :name => "blob" },
      :boolean     => { :name => "boolean" }
    }
  end
end
