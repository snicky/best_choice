require 'test_helper'

class EpsilonGreedyTest < ActiveSupport::TestCase

  def setup
    @algorithm = BestChoice::Algorithms::EpsilonGreedy.new
  end

  test 'randomness_factor validation' do
    invalid_values = [ -1, -0.1, 100.5, 101 ]
    invalid_values.each { |val|
      assert_raises(ArgumentError) do
        BestChoice::Algorithms::EpsilonGreedy.new(randomness_factor: val)
      end
    }

    valid_values = [ 0.1, 1, 100 ]
    valid_values.each { |val|
      assert_nothing_raised do
        BestChoice::Algorithms::EpsilonGreedy.new(randomness_factor: val)
      end
    }
  end

  test 'choice_rate' do
    invalid_data = [
      { display_count: nil , success_count: 0 },
      { display_count: 1   , success_count: nil },
      { display_count: 0   , success_count: -1 },
      { display_count: -1  , success_count: -2 },
      { display_count: 1.0 , success_count: 0 },
      { display_count: 1.1 , success_count: 0 },
      { display_count: 1   , success_count: 2 },
    ]

    invalid_data.each { |data| 
      assert_raises(ArgumentError) do
        @algorithm.send :choice_rate, data
      end
    }

    assert_equal 100, 
      @algorithm.send(:choice_rate, { display_count: 0, success_count: 0 })
    assert_equal 0.5,
      @algorithm.send(:choice_rate, { display_count: 6, success_count: 3 })
    assert_equal 2/3.to_f,
      @algorithm.send(:choice_rate, { display_count: 6, success_count: 4 })
  end

  test 'actual picking via pick_option' do

    # --------------------------------------------------------
    # Non-random version
    # --------------------------------------------------------

    non_random_algorithm = BestChoice::Algorithms::EpsilonGreedy.new(
                            randomness_factor: 0)

    # The first option should be always chosen.
    stats = [
      { display_count: 2 , success_count: 2 },
      { display_count: 2 , success_count: 1 },
      { display_count: 1 , success_count: 0 }
    ]

    10.times {
      assert_equal stats[0], non_random_algorithm.pick_option(stats)
    }

    # If the second option has the same success_count as the first one, but
    # a higher display_count, the first option should still be chosen.
    #
    stats = [
      { display_count: 2 , success_count: 2 },
      { display_count: 3 , success_count: 2 },
      { display_count: 1 , success_count: 0 }
    ]

    10.times {
      assert_equal stats[0], non_random_algorithm.pick_option(stats)
    }

    # Even if the ratio of success_count to display_count of the first option
    # drops to the ratio of the second option, it would still be preferred
    # if its display_count is higher.
    #
    stats = [
      { display_count: 6 , success_count: 4 },
      { display_count: 3 , success_count: 2 },
      { display_count: 1 , success_count: 0 }
    ]

    10.times {
      assert_equal stats[0], non_random_algorithm.pick_option(stats)
    }

    # Changing the ratio in favor of the second option, should make it the
    # new optimal choice.
    #
    stats = [
      { display_count: 6 , success_count: 3 },
      { display_count: 4 , success_count: 3 },
      { display_count: 1 , success_count: 0 }
    ]

    10.times {
      assert_equal stats[1], non_random_algorithm.pick_option(stats)
    }

    # --------------------------------------------------------
    # 100% random version
    # --------------------------------------------------------

    totally_random_algorithm = BestChoice::Algorithms::EpsilonGreedy.new(
                                randomness_factor: 100)

    stats = [
      { display_count: 5, success_count: 2 },
      { display_count: 5, success_count: 1 },
      { display_count: 2, success_count: 0 }
    ]

    # The probability of choosing each non-optimal option should be equal.
    #
    chosen_options = []
    20.times {
      chosen_options << totally_random_algorithm.pick_option(stats)
    }
    assert_equal stats[1..2],
                 chosen_options.uniq.sort_by{ |d| d[:success_count] }.reverse

    # --------------------------------------------------------
    # Default version
    # --------------------------------------------------------

    stats = [
      { display_count: 5, success_count: 2 },
      { display_count: 5, success_count: 1 }
    ]

    # The second option should be chosen only in ~10% of cases.
    #
    chosen_options = []
    1000.times { chosen_options << @algorithm.pick_option(stats) }

    counts = Hash.new 0
    chosen_options.each { |opt| counts[opt] += 1 }

    assert counts[stats[1]] > 80   # Leave some margin.
  end

end
