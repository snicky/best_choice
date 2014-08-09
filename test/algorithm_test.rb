require 'test_helper'

class AlgorithmTest < ActiveSupport::TestCase

  def setup
    @algorithm = DummyAlgorithm.new
  end

  test 'pick_option' do
    # Empty stats
    assert_raises(BestChoice::Algorithm::NoAvailableOptionsError) do
      @algorithm.pick_option []
    end

    # One option
    assert_equal 'an_option', @algorithm.pick_option(['an_option'])

    # Multiple options
    options = ['a','b']
    mock(@algorithm).do_actual_pick options
    @algorithm.pick_option options
  end

  test 'the class itself does not implement do_actual_pick method' do
    assert_raises(BestChoice::NotImplementedError) do
      @algorithm.send :do_actual_pick
    end
  end

  test 'is_non_negative_int?' do
    [ nil, '', 'a', -1, -0.01, 0.1, 12.23 ].each do |arg|
      refute @algorithm.send :is_non_negative_int?, arg
    end

    [ 0, 1 ].each do |arg|
      assert @algorithm.send :is_non_negative_int?, arg
    end
  end

end
