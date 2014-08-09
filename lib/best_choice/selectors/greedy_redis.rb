module BestChoice
  module Selectors

    class GreedyRedis < BestChoice::Selector

      def initialize name, opts={}
        super name, opts.merge({
                storage:   Storage::RedisHash,
                algorithm: Algorithms::EpsilonGreedy
              })
      end

    end
    
  end
end
