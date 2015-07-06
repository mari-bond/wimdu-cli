require "spec_helper"
require './place'

RSpec.describe "Place" do
  let(:place) { stub_model(Place).as_new_record }

  before do
    store = './wimdu.places'
    File.delete(store) if File.file?(store)
  end

  describe 'validation' do
    context 'nightly_rate_in_eur' do
      it 'should be invalid if nightly_rate_in_eur is not a number' do
        place.nightly_rate_in_eur = 'rate'
        expect(place).to be_invalid
      end

      it 'should be invalid if nightly_rate_in_eur is less than 0' do
        place.nightly_rate_in_eur = -20
        expect(place).to be_invalid
      end
    end

    it 'should be invalid if type is not valid' do
      place.type = 'building'
      expect(place).to be_invalid
    end
  end

  describe '#save' do
    it 'should save to store valid place' do
      place = stub_model(Place, valid?: true, save_to_store: true)
      place.save
      expect(place).to have_received(:save_to_store)
    end

    it 'should not save invalid place' do
      place = stub_model(Place, valid?: false, save_to_store: true)
      place.save
      expect(place).not_to have_received(:save_to_store)
    end
  end

  describe '#complete' do
    it 'should complete place if all properties are present' do
      place = stub_model(Place, has_all_properties?: true, save_to_store: true)
      place.complete
      expect(place).to have_received(:save_to_store)
      expect(place.completed).to eq true
    end

    it 'should not complete if not all properties are present' do
      place = stub_model(Place, has_all_properties?: false, save_to_store: true)
      place.complete
      expect(place).not_to have_received(:save_to_store)
      expect(place.completed).to eq nil
    end
  end

  describe '#find' do
    let(:place1) { Place.new }
    let(:place2) { Place.new }

    before do
      place1.save
      place2.save
    end

    it 'should return target place' do
      expect(Place.find(place1.id)).not_to eq nil
    end

    it 'place is not found' do
      expect(Place.find('test')).to eq nil
    end
  end

  describe '#all' do
    let(:place1) { Place.new }
    let(:place2) { Place.new }

    it 'should return all places' do
      place1.save
      place2.save
      expect(Place.all.count).to eq 2
    end

    it 'should return blank array' do
      expect(Place.all).to eq []
    end
  end

  describe '#completed' do
    it 'should return completed places' do
      place1 = stub_model(Place, completed: true)
      place2 = stub_model(Place)
      allow(Place).to receive(:all).and_return([place1, place2])

      expect(Place.completed.count).to eq 1
      expect(Place.completed.last.id).to eq place1.id
    end

    it 'should return blank array' do
      allow(Place).to receive(:all).and_return([stub_model(Place), stub_model(Place)])
      expect(Place.completed).to eq []
    end
  end
end