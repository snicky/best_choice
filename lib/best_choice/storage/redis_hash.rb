require 'json'
require 'redis-objects'

module BestChoice
  module Storage
    
    class RedisHash

      def initialize storage_name
        @hash_key = Redis::HashKey.new "best_choice:#{storage_name}"
      end

      def options
        if @hash_key[:options]
          JSON.parse @hash_key[:options]
        else
          []
        end
      end

      def add option
        unless has_option? option
          @hash_key[:options] = (options << option).to_json
        end
      end

      def display_count_incr option
        @hash_key.incr display_count_key(option)
      end

      def success_count_incr option
        @hash_key.incr success_count_key(option)
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
        (@hash_key[display_count_key(option)] || 0).to_i
      end

      def success_count option
        (@hash_key[success_count_key(option)] || 0).to_i
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
