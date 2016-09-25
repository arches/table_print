module TablePrint
  class Returnable
    def initialize(string_value="")
      @string_value = string_value
    end

    def set(klass, *config)
      TablePrint::Config.singleton.set(klass, config)
      "Set table_print config for #{klass}"
    end

    def clear(klass)
      TablePrint::Config.singleton.clear(klass)
      "Cleared table_print config for #{klass}"
    end

    def config_for(klass)
      TablePrint::Config.singleton.for(klass)
    end

    def to_s
      @string_value
    end

    def inspect
      to_s
     end
  end
end
