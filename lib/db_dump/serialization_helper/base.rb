module DbDump::SerializationHelper
  class Base
    attr_reader :extension
  
    def initialize(helper)
      @dumper    = helper.dumper
      @loader    = helper.loader
      @extension = helper.extension
    end
  
    def dump(filename)
      disable_logger
      File.open(filename, "w") do |file|
        @dumper.dump(file)
      end
      reenable_logger
    end
  
    def dump_to_dir(dirname)
      Dir.mkdir(dirname)
      tables = @dumper.tables
      tables.each do |table|
        File.open("#{dirname}/#{table}.#{@extension}", "w") do |io|
          @dumper.before_table(io, table)
          @dumper.dump_table io, table
          @dumper.after_table(io, table)
        end
      end
    end
  
    def load(filename, truncate = true)
      disable_logger
      @loader.load(File.new(filename, "r"), truncate)
      reenable_logger
    end
  
    def load_from_dir(dirname, truncate = true)
      Dir.entries(dirname).each do |filename|
        if filename =~ /^[.]/
          next
        end
        @loader.load(File.new("#{dirname}/#{filename}", "r"), truncate)
      end
    end
  
    def disable_logger
      @@old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
    end
  
    def reenable_logger
      ActiveRecord::Base.logger = @@old_logger
    end
  end
end