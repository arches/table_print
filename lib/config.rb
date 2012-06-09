require 'cattr'

module TablePrint
  class Config
    cattr_accessor :max_width, :time_format

    @@max_width = 30
    @@time_format = "%Y-%m-%d %H:%M:%S"

    @@klasses = {}

    def self.set(klass, hash)
      @@klasses[klass] = hash
    end

    def self.for(klass)
      @@klasses[klass]
    end

    def self.clear(klass)
      @@klasses.delete(klass)
    end
  end
end
