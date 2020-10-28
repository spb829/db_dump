module DbDump::SerializationHelper
  class Load
    def self.load(io, truncate = true)
      ActiveRecord::Base.connection.transaction do
        load_documents(io, truncate)
      end
    end

    def self.truncate_table(table)
      begin
        ActiveRecord::Base.connection.execute("TRUNCATE #{Utils.quote_table(table)}")
      rescue Exception
        ActiveRecord::Base.connection.execute("DELETE FROM #{Utils.quote_table(table)}")
      end
    end

    def self.load_table(table, data, truncate = true)
      column_names = data['columns']
      if truncate
        truncate_table(table)
      end
      load_records(table, column_names, data['records'])
      reset_pk_sequence!(table)
    end

    def self.load_records(table, column_names, records)
      if column_names.nil?
        return
      end
      quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
      quoted_table_name = Utils.quote_table(table)
      records.each do |record|
        quoted_values = record.map{|c| ActiveRecord::Base.connection.quote(c)}.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES (#{quoted_values})")
      end
    end

    def self.reset_pk_sequence!(table_name)
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
      end
    end

  end
end