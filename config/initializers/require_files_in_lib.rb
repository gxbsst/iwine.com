Dir[Rails.root + 'lib/core_ext/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'lib/validators/*.rb'].each do |file|
  require file
end