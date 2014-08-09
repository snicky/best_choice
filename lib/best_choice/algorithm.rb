module BestChoice

  class Algorithm

    class NoAvailableOptionsError < StandardError ; end
    
    
    def initialize
      raise BestChoice::NotImplementedError.new 'Expected subclass to implement'
    end

    def pick_option stats
      unless stats.kind_of? Array
        raise ArgumentError.new 'Expected an array'
      end

      case stats.length
      when 0
        raise NoAvailableOptionsError
      when 1
        stats.first
      else
        do_actual_pick stats
      end
    end


    protected
    
    def do_actual_pick stats=[]
      raise BestChoice::NotImplementedError.new 'Expected subclass to implement'
    end
    
    def choice_rate option_data
      display_count = option_data[:display_count]
      success_count = option_data[:success_count]

      unless is_non_negative_int?(display_count)
        raise ArgumentError.new "Invalid display_count: #{display_count.inspect}"
      end
      unless is_non_negative_int?(success_count)
        raise ArgumentError.new "Invalid success_count: #{success_count.inspect}"
      end
      if option_data[:success_count] > option_data[:display_count]
        raise ArgumentError.new "success_count: #{success_count} " \
                                "higher than display_count: #{display_count}"
      end

      if option_data[:display_count] == 0
        100
      else
        option_data[:success_count].to_f / option_data[:display_count]
      end
    end


    private
    
    def is_non_negative_int? arg
      arg.kind_of?(Integer) && arg >= 0
    end

  end

end
