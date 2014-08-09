module BestChoice

  class Selector
    
    attr_reader :name
    attr_writer :picked_option
    

    def initialize name, storage:, algorithm:, **opts
      @name      = name
      @storage   = storage.new(name)
      @algorithm = algorithm.new(opts)
    end

    def option option
      @storage.add option
      
      if should_display? option
        mark_display option
        yield
      end
    end

    def mark_success option
      @marked_success ||= !!@storage.increment_success_count(option)
    end
    
    def picked_option
      @picked_option ||= @algorithm.pick_option(@storage.stats)[:name]
    end
    
    def equal? selector
      self.class == selector.class && name == selector.name
    end
    
    alias :== :equal?


    private

    def should_display? option
      picked_option == option
    end

    def mark_display option
      @marked_display ||= !!@storage.increment_display_count(option)
    end

  end

end
