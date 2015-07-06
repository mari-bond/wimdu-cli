require "pstore"
require 'securerandom'
require 'active_model'

class Place
  include ActiveModel::Validations

  @@store = PStore.new("wimdu.places")
  PROPERTIES = [:title, :type, :address, :nightly_rate_in_eur].freeze
  TYPES = ['holiday_home', 'apartment', 'private_room'].freeze

  attr_accessor *PROPERTIES
  attr_reader :id, :completed

  validates_numericality_of :nightly_rate_in_eur, greater_than: 0, if: :nightly_rate_in_eur
  validates_inclusion_of :type, in: TYPES, if: :type

  def initialize
    @id = SecureRandom.hex(5)
  end

  def save
    save_to_store if self.valid?
  end

  def complete
    if has_all_properties?
      @completed = true
      save_to_store
    end
  end

  def summary
    attrs_to_print = PROPERTIES + [:id]
    attrs_to_print.map{|attr| [[attr.to_s.split('_').join(' ').capitalize, ':'].join,
      send(attr)].join(' ')
    }
  end

  class << self
    def find(id)
      @@store.transaction { @@store[id] }
    end

    def all
      @@store.transaction do
        @@store.roots.map {|root| @@store[root] }
      end
    end

    def completed
      all.select {|place| place.completed }
    end
  end

  private
  def save_to_store
    @@store.transaction do
      @@store[@id] = self
    end
  end

  def has_all_properties?
    PROPERTIES.all? {|property| send(property).present? }
  end
end