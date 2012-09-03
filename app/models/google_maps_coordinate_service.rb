class GoogleMapsCoordinateService < Struct.new(:record)
  def perform
    binding.pry
    coords = Geocoder.coordinates(record.full_address)
    record.update_attributes(:latitude=> coords[0], :longitude => coords[1])
  end
end
