module TablePrint
  module Printable
    # Sniff the data class for non-standard methods to use as a baseline for display
    # If class has a .columns() or a .keys() use it over methods
    def self.default_display_methods(target)
       if target.class.respond_to? :columns
         return target.class.columns.collect do |column|
           if column.respond_to? :name
             column.name
           else
             column
           end
         end
       end
      
      return target.keys if target.is_a? Hash

      methods = []
      target.methods.each do |method_name|
        method = target.method(method_name)

        # Check that this method is not an inherited method and that it does not require any arguments
        if method.owner == target.class
          if method.arity == 0
            methods << method_name.to_s
          end
        end
      end

      methods.delete_if { |m| m[-1].chr == "!" } # Don't use dangerous methods
      methods
    end
  end
end
