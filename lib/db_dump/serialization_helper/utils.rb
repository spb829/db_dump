module DbDump::SerializationHelper
  module Utils

    def self.unhash(hash, keys)
      keys.map { |key| hash[key] }
    end

    def self.unhash_records(records, keys)
      records.each_with_index do |record, index|
        records[index] = unhash(record, keys)
      end

      records
    end

    def self.convert_booleans(records, columns)
      records.each do |record|
        columns.each do |column|
          next if is_boolean(record[column])
          record[column] = convert_boolean(record[column])
        end
      end
      records
    end

    def self.convert_boolean(value)
      ['t', '1', true, 1].include?(value)
    end

    def self.boolean_columns(table)
      columns = ActiveRecord::Base.connection.columns(table).reject { |c| silence_warnings { c.type != :boolean } }
      columns.map { |c| c.name }
    end

    def self.is_boolean(value)
      value.kind_of?(TrueClass) or value.kind_of?(FalseClass)
    end

    def self.quote_table(table)
      ActiveRecord::Base.connection.quote_table_name(table)
    end

    def self.quote_column(column)
      ActiveRecord::Base.connection.quote_column_name(column)
    end
  end
end