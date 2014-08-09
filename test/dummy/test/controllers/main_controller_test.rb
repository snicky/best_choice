require 'test_helper'

class MainControllerTest < ActionController::TestCase
  
  def setup
    Redis.current.flushall
    @s_name = :sign_up_button
  end
  
  test 'display the same option for the same visitor' do
    
    get :landing
    picked_option = session[:_best_choice_picks][@s_name]
    css_selector  = "#test-#{picked_option}"
    assert_select css_selector
    
    3.times {
      get :landing
      assert_select css_selector
    }
  end
  
  test 'display better option if available' do
    get :landing
    first_picked_option = session[:_best_choice_picks][@s_name]
    assert_has_html_for first_picked_option
    
    clear_picks_from_session
    get :landing
    second_picked_option = session[:_best_choice_picks][@s_name]
    assert_not_equal first_picked_option, second_picked_option
    assert_has_html_for second_picked_option
    
    clear_picks_from_session
    get :landing
    third_picked_option = session[:_best_choice_picks][@s_name]
    assert_not_equal second_picked_option, third_picked_option
    assert_has_html_for third_picked_option
  end
  
  test 'display the best option' do
    # -------------------------------------------------
    # 1. Get landing. The visitor does not choose to sign up.
    #
    get :landing
    all_options = BestChoice.for(@s_name)
                            .instance_variable_get('@storage')
                            .options
    first_picked_option = session[:_best_choice_picks][@s_name]
    assert_has_html_for first_picked_option
    # First option: success 0 / display 1.
    
    # -------------------------------------------------
    # 2. The second visitor sees another option and chooses to sign up.
    #
    clear_picks_from_session
    get :landing
    second_picked_option = session[:_best_choice_picks][@s_name]
    assert_has_html_for second_picked_option
    get :sign_up
    # Second option: success 1 / display 1.
    
    # -------------------------------------------------
    # 3. The third visitor might either see the second option or the last
    #    available one with success 0 / display 0. He doesn't sign up.
    #
    clear_picks_from_session
    get :landing
    assert_not_equal first_picked_option, 
                     session[:_best_choice_picks][@s_name]
    
    # -------------------------------------------------
    # 4. Force the fourth visitor to see the third option. He also doesn't
    #    sign up.
    clear_picks_from_session
    third_available_option = 
      (all_options - [first_picked_option, second_picked_option])[0]
    session[:_best_choice_picks] = { @s_name => third_available_option }
    get :landing
    assert_has_html_for third_available_option
    
    # -------------------------------------------------
    # Success/display ratio:
    #   * First option  ->      0%
    #   * Second option -> 50-100% (depending on the Step 3)
    #   * Third option  ->      0%
    #
    # Thus the fifth user HAS to see the second option
    # which is currently the best.
    #
    clear_picks_from_session
    get :landing
    assert_equal second_picked_option, session[:_best_choice_picks][@s_name]
    assert_has_html_for second_picked_option
  end


  # -------------------------------------------------
  # Utilities

  private
  
  # Deletes the picks from the session to avoid forcing the same option
  # in consecutive requests (this to mock different visitors).
  #
  def clear_picks_from_session
    session.delete :_best_choice_picks
  end
  
  def assert_has_html_for picked_option
    css_selector = "#test-#{picked_option}"
    assert_select css_selector
  end
  
end
