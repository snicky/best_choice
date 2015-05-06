require './lib/best_choice/algorithm'
require './lib/best_choice/selector'

require './lib/best_choice/algorithms/epsilon_greedy'
require './lib/best_choice/storage/redis_hash'

require './lib/best_choice/selectors/greedy_redis'


module BestChoice
  
  module_function
  
  def for selector_name, selector: default_selector, **opts
    selector.new(selector_name, opts)
  end
  
  def default_selector
    @default_selector ||= Selectors::GreedyRedis
  end
  
  def default_selector= selector
    @default_selector = selector
  end

end
