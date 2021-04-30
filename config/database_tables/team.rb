module DatabaseTables
  module Team
    def self.init!
      return if ActiveRecord::Base.connection.tables.include?('teams')

      ActiveRecord::Base.connection.create_table :teams do |t|
        t.string :team_id
        t.string :name
        t.string :domain
        t.string :token
        t.string :oauth_scope
        t.string :oauth_version, default: 'v1', null: false
        t.string :bot_user_id
        t.string :activated_user_id
        t.string :activated_user_access_token
        t.boolean :active, default: true
        t.timestamps
      end
    end
  end
end