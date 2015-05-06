BestChoice - Auto A/B testing in Ruby
===

Simple implementation of the idea presented in Steve Hanov's article [20 lines of code that will beat A/B testing every time][1].


  [1]: http://stevehanov.ca/blog/index.php?id=132
  
Installation and setup
----
Add it to your Gemfile:
```ruby
gem 'best_choice'
```

Currently, the only supported storage type is Redis hash (accessed via redis-objects gem), thus you need to run a Redis server and set `Redis.current` to point to the server in your Ruby code. The setup might look like this:
```ruby
Redis.current = Redis.new(host: '127.0.0.1', port: 6379)
```

Rails usage
----
First you need to include BestChoice::RailsUtil in your controller:

```ruby
include BestChoice::RailsUtil
```

In order to create a test and assign some options to it, you need to initialize a new `Selector`. You can initialize an instance of the default `Selector` using this helper:

```ruby
@selector = best_choice_for 'my_test'
```

Now you can assign options for the test directly in your view:

```ruby
@selector.option 'first_option' do
  # display sth here
end

@selector.option 'second_option' do
  # display sth else here
end
```

The `option` method both assigns an option to the test by saving its name in a storage (look below) and also chooses whether to execute the given block of code or not. Only one of the options is chosen per any given instance of a `Selector` and only this option's block of code gets executed. The choice is made by an algorithm based on statistics gathered in the storage. 

As a consequence of this design, the very first time your code is being executed (the very first instance of the `Selector` with the given name is being initialized) the first option will be chosen for sure. Any consecutive time though, the choice will be made based on the saved stats.

So far there are only two stats taken into account by the algorithm: `display_count` and `success_count`. Obviously, the `display_count` is being incremented for a given option every time this option is displayed. Though the `success_count` has to be incremented manually by calling:

```ruby
@selector.mark_success
```

`BestChoice::RailsUtil` saves the options chosen of the selectors in the session, so you don't need to care about which option you need to mark as a successful one. Any time you mark a success, it means that the option displayed to this visitor is marked as successful.

Here's a complete example of a best_choice setup in Rails:

Controller:
```ruby
class MyController < ApplicationController
  
  include BestChoice::RailsUtil
  
  def landing
    @bc = best_choice_for 'call_to_action'
  end
  
  def sign_up_form
    best_choice_for('sign_up_button').mark_success
  end
  
end
```

View:
```erb
<% @bc.option 'simple' do %>
  <%= link_to 'Sign up now!', sign_up_form_path, class: 'btn' %>
<% end %>

<% @bc.option 'polite' do %>
  Please <%= link_to 'sign up', sign_up_form_path %> here.
<% end %>

<% @bc.option 'blackmail' do %>
  <h1>
    IF YOU WON'T
    <%= link_to 'SIGN UP', sign_up_form_path %> 
    WE WILL KILL THIS DOG!
  </h1>
  <img src="doge.jpg">
<% end %>
```

Only one of the given options for a 'call_to_action' test will be displayed (simple, polite or blackmail) depending on the gathered stats. After a sample of visitors goes through the flow, the landing page will display the best possible option (the one with the highest success/display ratio) most of the time (90% by default). There's still a possibility (10%) to see another option and this is necessary for the exploration purposes (you can learn more from the [article][1]).


Non-rails usage
----

Determining the `best_choice` outside Rails is similar, but it does not rely on the session to keep track of the picked options, so you will have to do this yourself.

Here's one possible solution using a simple Sinatra API as an example, but you can choose another way to remember who saw which option depending on your code.

```ruby
get '/welcome' do
  response = { ... }

  # Mind that outside of Rails there's no `best_choice_for` helper.
  selector = BestChoice.for 'sign_up_text'
  
  response.merge(
    selector.option 'simple' do
      { text: 'Sign up now', bc_option: 'simple' }
    end
    selector.option 'polite' do
      { text: 'Please sign up', bc_option: 'polite' }
    end
    selector.option 'blackmail' do
      {
        text: 'IF YOU WONT SIGN UP WE WILL KILL THIS DOG', 
        bc_option: 'blackmail'
      }
    end
  )
  
  response.to_json
end

get '/sign_up' do
    ...

    selector = BestChoice.for 'sign_up_text'
    
    if bc_option = request['bc_option']
      selector.mark_success bc_option
    end
    
    { text: 'Thanks for signing up' }.to_json
end
```

Custom parameters
----

For the default `EpsilonGreedy` algorithm the only parameter you can change is the `randomness_factor` which describes the percentage of visits that does not receive the best option. It's set to 10(%) by default. In order to change it you have to specify the parameter value upon selector's initialization.

```ruby
@selector = BestChoice.for 'my_test', randomness_factor: 25
```

Other algorithms and storage options
----

There's only one algorithm (`EpsilonGreedy`) and only one storage option (`RedisHash`) provided so far. The default `Selector` class that uses both of them is called `GreedyRedis`. If you are willing to use a custom algorithm or a different storage, you can easily add them to the codebase by providing the following public APIs in your classes:

For an `Algorithm`
```ruby
class MyAlgorithm < BestChoice::Algorithm

  def initialize **opts
    ...
  end
  
  protected
  def do_actual_pick stats
    # The `stats` argument is an <Array> of <Hash>es with the following keys:
    # {name: <String>, display_count: <Int>, success_count: <Int>}
    #
    # Returns one of the stats.
  end

end
```

For a `Storage`
```ruby
class MyStorage < BestChoice::Storage

  def initialize data_identifier
    # Initializes the instance with the given identifier.
  end
  
  def options
    # Returns an Array of available options' names:
    # [<String>, <String>, ...]
  end
  
  def add option
    # Saves the option (<String>/<Symbol>) with the given name.
  end

  def display_count_incr option
    # Increments the display counter for the option.
  end
  
  def success_count_incr option
    # Increments the success counter for the option.
  end
  
  def stats
    # Returns an <Array> of <Hash>es (presenting the stats for all 
    # the available options) with the following keys:
    # { name: <String>, display_count: <Int>, success_count: <Int> }
  end
  
end
```

For a `Selector`
```ruby
class MySelector < BestChoice::Selector

  def initialize name, **opts
    super name, opts.merge({
      algorithm: MyAlgorithm,
      storage:   MyStorage
    })
  end
  
end
```

You can also override the default selector:
```ruby
BestChoice.default_selector = MySelector
```
