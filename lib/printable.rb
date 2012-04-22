module TablePrint
  module Printable
    # Sniff the data class for non-standard methods to use as a baseline for display
    def default_display_methods
      methods = []
      self.methods.each do |method_name|
        method = self.method(method_name)

        if method.owner == self.class
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
