require './lib/best_choice/rails_util'


class MainController < ApplicationController
  
  include BestChoice::RailsUtil

  
  def landing
    @bc = best_choice_for(:sign_up_button,
                          randomness_factor: 0)   # Otherwise too hard too test.
  end
  
  def sign_up
    bc = best_choice_for :sign_up_button
    bc.mark_success
    render text: 'sign up form should be here!'
  end

end
