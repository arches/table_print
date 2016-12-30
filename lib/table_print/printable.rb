module TablePrint
  module Printable
    # Sniff the data class for non-standard methods to use as a baseline for display
    def self.default_display_methods(target)
      if target.class.respond_to? :columns
        if target.class.columns.first.respond_to? :name

          # eg ActiveRecord
          names = target.class.columns.collect(&:name)
          return names unless target.class.respond_to?(:human_attribute_name)
          return names.inject({}) do |h, n|
            h[n] = target.class.human_attribute_name(n)
            h
          end
        else

          # eg Sequel
          return target.class.columns
        end
      end

      # eg mongoid
      return target.fields.keys if target.respond_to? :fields and target.fields.is_a? Hash

      return target.keys if target.is_a? Hash
      return target.members.collect(&:to_sym) if target.is_a? Struct

      methods = []
      target.methods.each do |method_name|
        method = target.method(method_name)

        if method.owner == target.class
          if method.arity == 0 #
            methods << method_name.to_s
          end
        end
      end

      methods.delete_if { |m| m[-1].chr == "!" } # don't use dangerous methods
      methods
    end
  end
end
