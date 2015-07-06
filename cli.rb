#!/usr/bin/env ruby
require "thor"
require_relative 'place'

class Cli < Thor
  Signal.trap("INT") do
    exit 1
  end

  desc "list", "Returns list of completed places"
  def list
    places = Place.completed
    if places.any?
      places.each {|place| puts place.summary; puts "\n" }
    else
      puts "No offers found."
    end
  end

  desc "new", "Builds new place"
  def new
    @place = Place.new
    puts "Starting with new property #{@place.id}"
    collect_data
  end

  desc "continue", "Continue entering place info"
  def continue(id)
    @place = Place.find(id)
    if @place
      puts "Continuing with #{id}"
      collect_data
    else
      puts "Place is not found"
    end
  end

  private

  def collect_data
    return unless @place
    if property = next_property
      value = ask_property(property)
      unless value.blank?
        @place.send("#{property}=", value)
        if @place.save
          collect_data
        else
          puts @place.errors.full_messages.join('')
        end
      end
    else
      @place.complete
      puts "Great job! Listing #{@place.id} is complete!"
      puts @place.summary
    end
  end

  def next_property
    return unless @place
    Place::PROPERTIES.select{ |property| !@place.send(property) }.first
  end

  def ask_property(property)
    method_name = "ask_#{property}"
    method_name = :ask_default unless respond_to?(method_name, true)
    send(method_name, property)
  end

  def ask_default(property)
    ask([humanize(property), ':'].join)
  end

  def ask_type(property)
    type_choices = Place::TYPES.map.with_index{|type, i| [i+1, humanize(type)].join(' ') }.join("\n")
    choice = ask type_choices
    Place::TYPES[choice.to_i - 1]
  end

  def humanize(str)
    str && str.to_s.split('_').join(' ').capitalize
  end
end

Cli.start