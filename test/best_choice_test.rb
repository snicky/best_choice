require 'test_helper'

class BestChoiceTest < ActiveSupport::TestCase

  def setup
    @algorithm_class = DummyAlgorithm
    @storage_class   = DummyStorage
    @sel             = BestChoice::Selector.new('just a test',
                         algorithm: @algorithm_class, storage: @storage_class)
  end
  
  test 'for' do
    sel = BestChoice.for 'sign up button'
    assert_kind_of BestChoice.default_selector, sel
    assert_equal   'sign up button', sel.name
  end

  test 'storage constraint' do
    assert_raises(ArgumentError) do
      BestChoice::Selector.new(algorithm: DummyAlgorithm.new)
    end
  end

  test 'algorithm constraint' do
    assert_raises(ArgumentError) do
      BestChoice::Selector.new(storage: DummyStorage.new)
    end
  end

  test 'option method' do
    first_option  = 'green_button'
    second_option = 'blue_button'
    
    any_instance_of(@storage_class) do |instance|
      mock(instance).add(first_option)
    end
    mock(@sel).should_display?(first_option) { true }
    mock(@sel).mark_display(first_option)
    
    any_instance_of(@storage_class) do |instance|
      mock(instance).add(second_option)
    end
    mock(@sel).should_display?(second_option) { false }
    mock(@sel).mark_display(second_option).times 0
    
    assert_equal 'a green button',
                 @sel.option(first_option) { 'a green button' }

    assert_equal nil, @sel.option(second_option) { 'a blue button' }
  end

  test 'picked_option=, picked_option and should_display?' do
    @sel.picked_option = 'previously_chosen_option'
    assert @sel.send(:should_display?, 'previously_chosen_option')
  end

  test "private picked_option method calls algorithm's pick_option
        with storage's stats" do

    fake_stats = [:fake, :array]
    any_instance_of(@storage_class) do |instance|
      mock(instance).stats{fake_stats}.times(1)
    end
    any_instance_of(@algorithm_class) do |instance|
      mock(instance).pick_option(fake_stats){ {name: 'picked_option'} }
                    .times(1)
    end
    @sel.send :picked_option
    @sel.send :picked_option
  end

  test 'mark_display' do
    assert_nil @sel.instance_variable_get('@marked_display')

    option = 'red_button'

    any_instance_of(@storage_class) do |instance|
      mock(instance).increment_display_count(option) { true }
    end
    
    @sel.send(:mark_display, option)
    assert @sel.instance_variable_get("@marked_display")
  end

  test 'mark_success' do
    assert_nil @sel.instance_variable_get('@marked_success')

    option = 'purple_button'

    any_instance_of(@storage_class) do |instance|
      mock(instance).increment_success_count(option) { true }
    end

    @sel.mark_success(option)
    assert @sel.instance_variable_get("@marked_success")
  end
end
