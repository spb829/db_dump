module DbDump::SerializationHelper
  class Dump
    def self.before_table(io, table)

    end

    def self.dump(io)
      tables.each do |table|
        before_table(io, table)
        dump_table(io, table)
        after_table(io, table)
      end
    end

    def self.after_table(io, table)

    end

    def self.tables
      ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }.sort
    end

    def self.dump_table(io, table)
      return if table_record_count(table).zero?

      dump_table_columns(io, table)
      dump_table_records(io, table)
    end

    def self.table_column_names(table)
      ActiveRecord::Base.connection.columns(table).map { |c| c.name }
    end


    def self.each_table_page(table, records_per_page=1000)
      total_count = table_record_count(table)
      pages = (total_count.to_f / records_per_page).ceil - 1
      keys = sort_keys(table)
      boolean_columns = Utils.boolean_columns(table)

      (0..pages).to_a.each do |page|
        query = Arel::Table.new(table).order(*keys).skip(records_per_page*page).take(records_per_page).project(Arel.sql('*'))
        records = ActiveRecord::Base.connection.select_all(query.to_sql)
        records = Utils.convert_booleans(records, boolean_columns)
        yield records
      end
    end

    def self.table_record_count(table)
      ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM #{Utils.quote_table(table)}").values.first.to_i
    end

    # Return the first column as sort key unless the table looks like a
    # standard has_and_belongs_to_many join table, in which case add the second "ID column"
    def self.sort_keys(table)
      first_column, second_column = table_column_names(table)

      if [first_column, second_column].all? { |name| name =~ /_id$/ }
        [Utils.quote_column(first_column), Utils.quote_column(second_column)]
      else
        [Utils.quote_column(first_column)]
      end
    end
  end
end