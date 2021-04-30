module DatabaseTables
  module User
    def self.init!
      return if ActiveRecord::Base.connection.tables.include?('users')

      ActiveRecord::Base.connection.create_table :users do |t|
        t.string :slack_id
        t.string :ruby_id
        t.string :name
        t.timestamps
      end
    end
  end
end