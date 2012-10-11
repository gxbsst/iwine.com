class GoogleMapsCoordinateService < Struct.new(:record)
  def perform
    coords = Geocoder.coordinates(record.full_address)
    record.update_attributes(:latitude=> coords[0], :longitude => coords[1])
  end
end
