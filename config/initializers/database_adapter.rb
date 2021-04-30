class Module
  def all_modules
    self.constants.map { |c| self.const_get(c) }
               .filter { |c| c.is_a?(Module) }
  end
end

module SlackRubyBotServer
  module DatabaseAdapter
    def self.init!
      ::DatabaseTables.all_modules.each { |table|
        puts "#{table}.init!"
        table.init!
      }
    end
  end
end