require "spec_helper"
require './place'

RSpec.describe "CLI" do
  let(:exe) { File.expand_path('../../cli.rb', __FILE__) }

  before do
    store = './wimdu.places'
    File.delete(store) if File.file?(store)
  end

  describe "new" do
    let(:cmd) { "#{exe} new" }
    let(:process) { CliProcess.new(cmd) }

    it "success" do
      expect(process).to have_output("Starting with new property")
      expect(process).to have_output("Title: ")
      process.type "Test"
      expect(process).to have_output("1 Holiday home")
      expect(process).to have_output("2 Apartment")
      expect(process).to have_output("3 Private room")
      process.type '1'
      expect(process).to have_output("Address: ")
      process.type 'My address'
      expect(process).to have_output("Nightly rate in eur")
      process.type '12'
      place = Place.all.last
      expect(process).to have_output("Great job! Listing #{place.id} is complete!")
      expect(process).to have_output("Title: Test")
      expect(process).to have_output("Type: holiday_home")
      expect(process).to have_output("Address: My address")
      expect(process).to have_output("Nightly rate in eur: 12")
      expect(process).to have_output("Id: #{place.id}")

      process.kill
      process.wait
    end

    it "fail, invalid type" do
      expect(process).to have_output("Starting with new property")
      expect(process).to have_output("Title: ")
      process.type "Test"
      expect(process).to have_output("1 Holiday home")
      expect(process).to have_output("2 Apartment")
      expect(process).to have_output("3 Private room")
      process.type '5'
      expect(process).to have_output("")

      process.kill
      process.wait
    end

    it "fail, invalid rate" do
      expect(process).to have_output("Starting with new property")
      expect(process).to have_output("Title: ")
      process.type "Test"
      expect(process).to have_output("1 Holiday home")
      expect(process).to have_output("2 Apartment")
      expect(process).to have_output("3 Private room")
      process.type '1'
      expect(process).to have_output("Address: ")
      process.type 'My address'
      expect(process).to have_output("Nightly rate in eur")
      process.type 'rate'
      expect(process).to have_output("")

      process.kill
      process.wait
    end
  end

  describe 'list' do
    let(:cmd) { "#{exe} list" }
    let(:process) { CliProcess.new(cmd) }

    it 'should display no offers msg' do
      expect(process).to have_output("No offers found.")

      process.kill
      process.wait
    end

    it 'should display completed places data' do
      place = Place.new
      place.title = "Test"
      place.type = "holiday_home"
      place.address = 'My address'
      place.nightly_rate_in_eur = 12
      place.complete

      place2 = Place.new
      place2.title = "Test2"
      place2.type = "apartment"
      place2.address = 'Addr'
      place2.nightly_rate_in_eur = 20
      place2.complete

      expect(process).to have_output("Title: Test")
      expect(process).to have_output("Type: holiday_home")
      expect(process).to have_output("Address: My address")
      expect(process).to have_output("Nightly rate in eur: 12")
      expect(process).to have_output("Id: #{place.id}")

      expect(process).to have_output("Title: Test2")
      expect(process).to have_output("Type: apartment")
      expect(process).to have_output("Address: Addr")
      expect(process).to have_output("Nightly rate in eur: 20")
      expect(process).to have_output("Id: #{place2.id}")

      process.kill
      process.wait
    end
  end

  describe 'continue' do
    let(:place) { Place.new }
    let(:cmd) { "#{exe} continue #{place.id}" }
    let(:process) { CliProcess.new(cmd) }

    it "#continue" do
      place.title = "Test"
      place.type = "holiday_home"
      place.save

      expect(process).to have_output("Continuing with #{place.id}")
      expect(process).to have_output("Address: ")
      process.type 'My address'
      expect(process).to have_output("Nightly rate in eur")
      process.type '12'

      place = Place.all.last
      expect(process).to have_output("Great job! Listing #{place.id} is complete!")
      expect(process).to have_output("Title: Test")
      expect(process).to have_output("Type: holiday_home")
      expect(process).to have_output("Address: My address")
      expect(process).to have_output("Nightly rate in eur: 12")
      expect(process).to have_output("Id: #{place.id}")

      process.kill
      process.wait
    end
  end
end

