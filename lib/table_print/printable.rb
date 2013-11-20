module TablePrint
  module Printable
    # Sniff the data class for non-standard methods to use as a baseline for display
    def self.default_display_methods(target)
      # Sequel columns are just symbols
      return target.class.columns.collect{|c| c.respond_to?(:name) ? c.name : c } if target.class.respond_to? :columns
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
