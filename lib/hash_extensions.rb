module TablePrint
  module HashExtensions
    module ConstructiveMerge
      def constructive_merge(hash)
        target = dup

        hash.keys.each do |key|
          if hash[key].is_a? Hash and self[key].is_a? Hash
            target[key].extend ConstructiveMerge
            target[key] = target[key].constructive_merge(hash[key])
            next
          end

          target[key] = hash[key]
        end

        target
      end

      def constructive_merge!(hash)
        target = self

        hash.keys.each do |key|
          if hash[key].is_a? Hash and self[key].is_a? Hash
            target[key].extend ConstructiveMerge
            target[key] = target[key].constructive_merge(hash[key])
            next
          end

          target[key] = hash[key]
        end

        target
      end
    end
  end
end
