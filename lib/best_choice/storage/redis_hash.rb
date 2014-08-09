require 'json'
require 'redis-objects'

module BestChoice
  module Storage
    
    class RedisHash

      def initialize s_name
        @hash = Redis::HashKey.new "best_choice:#{s_name}"
      end

      def options
        if @hash[:options]
          JSON.parse @hash[:options]
        else
          []
        end
      end

      def add option
        unless has_option? option
          @hash[:options] = (options << option).to_json
        end
      end

      def increment_display_count option
        @hash.incr display_count_key(option)
      end

      def increment_success_count option
        @hash.incr success_count_key(option)
      end

      def stats
        options.inject([]) { |memo, option|
          memo << {
            name:          option,
            display_count: display_count(option),
            success_count: success_count(option)
          }
        }
      end


      private

      def has_option? option
        !!options.index(option)
      end

      def display_count option
        (@hash[display_count_key(option)] || 0).to_i
      end

      def success_count option
        (@hash[success_count_key(option)] || 0).to_i
      end

      def display_count_key option
        "display_#{option}"
      end

      def success_count_key option
        "success_#{option}"
      end

    end

  end
end
