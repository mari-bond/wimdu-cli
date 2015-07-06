A standalone app that allows users to list their place via a CLI. The data is kept locally. It is possible to enter partial data and continue later. Only completed items are displayed in the list.

# Commands:

* cli.rb continue #id    # Continue entering place info
* cli.rb help [COMMAND]  # Describe available commands or one specific command
* cli.rb list            # Display list of completed places
* cli.rb new             # Create new place

# Technologies:

* Ruby
* Thor https://github.com/erikhuda/thor
* PStore http://docs.ruby-lang.org/en/2.2.0/PStore.html
* Rspec