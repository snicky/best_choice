require 'set'

module BestChoice
  module RailsUtil

    extend ActiveSupport::Concern


    included do
      before_filter do
        RailsUtil.instance_variable_set('@session', session)
      end
         
      after_filter do
        if @_best_choice_selectors
          RailsUtil.best_choice_picks = @_best_choice_selectors.inject(
            RailsUtil.best_choice_picks) do |picks, (_, selector)|
              picks.merge!(selector.name => selector.picked_option)
            end
        end
      end
    end
    
    
    module SelectorExtension
      
      def self.extended klass
        klass.class_eval do
          define_method :mark_success do
            if pick = RailsUtil.best_choice_picks[name]
              super pick
              RailsUtil.best_choice_picks.delete name
            end
          end
        end
      end
      
    end
    
    
    # -------------------------------------------------
    # Module functions
    
    def self.best_choice_picks
      @session[:_best_choice_picks] ||= {}
    end
    
    def self.best_choice_picks= picked_options
      @session[:_best_choice_picks] = picked_options
    end
    

    # -------------------------------------------------
    # Methods visible to Rails controller
    
    def best_choice_for s_name, selector: BestChoice.default_selector, **opts
      s = selector.new s_name, opts
      s.extend SelectorExtension
      best_choice_selector_register s
      s.picked_option = RailsUtil.best_choice_picks[s_name]
      s
    end
    
    
    private
    
    # Save the test data in the instance variable, so that
    # it can be later retrieved in the after_filter.
    #
    def best_choice_selector_register selector
      @_best_choice_selectors ||= {}
      @_best_choice_selectors[selector.name] ||= selector
    end
    
  end
end
