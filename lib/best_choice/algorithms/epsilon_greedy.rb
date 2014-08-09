module BestChoice 
  module Algorithms

    class EpsilonGreedy < BestChoice::Algorithm

      DEFAULT_RANDOMNESS_FACTOR = 10


      def initialize randomness_factor: DEFAULT_RANDOMNESS_FACTOR
        unless randomness_factor.between? 0, 100
          raise ArgumentError.new "Invalid randomness_factor: #{randomness_factor}"
        end
        @randomness_factor = randomness_factor
      end


      protected
      
      def do_actual_pick stats
        options_by_rate = stats.sort_by{ |o| choice_rate(o) }
        if rand(100)+1 > @randomness_factor
          options_by_rate.last
        else
          options_by_rate[0..-2].sample
        end
      end
      
    end

  end
end
