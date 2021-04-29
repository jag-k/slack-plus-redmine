module Unfurls
  REVIEWER = 'Ревьюер'.freeze

  class Fields
    # @param fields [Array<Hash>] Fields to unfurls
    def initialize(fields)
      @fields = fields
    end

    def call
      fields.each_with_object([]) do |field, acc|
        name, value = field[:name], field[:value]
        next if value.blank?

        field_value = if value.is_a?(Array)
                        value.join(', ')
                      elsif name == REVIEWER
                        reviewer = Redmine::User.new(value).call
                        "<#{Redmine::USERS_URL}#{value}|#{reviewer[:name]}}"
                      else
                        value
                      end

        acc << "#{name}: #{field_value}"
      end.join("\n")
    end

    private

    attr_reader :fields
  end
end
