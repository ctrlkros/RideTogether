# frozen_string_literal: true

require_relative 'db_helpers'

def create_trip(driver_id, from_city, to_city, date_time, total_seats, price)
  trips = load_records('db/trips.yml')

  new_id = if trips.empty?
             1
           else
             trips.map { |t| t[:id] }.max + 1
           end

  new_trip = {
    id: new_id,
    driver_id: driver_id,
    from_city: from_city,
    to_city: to_city,
    date_time: date_time,
    total_seats: total_seats.to_i,
    free_seats: total_seats.to_i,
    price: price.to_f,
    status: 'active'
  }

  trips << new_trip

  save_records('db/trips.yml', trips)

  puts "Поїздка з #{from_city} до #{to_city} успішно створена водієм з ID #{driver_id}!"
  new_trip
end

def search_trips(from_city, to_city)
  trips = load_records('db/trips.yml')

  found_trips = trips.select do |trip|
    trip[:from_city].downcase == from_city.downcase &&
      trip[:to_city].downcase == to_city.downcase &&
      trip[:free_seats].positive? &&
      trip[:status] == 'active'
  end

  if found_trips.empty?
    puts "На жаль, активних поїздок за маршрутом #{from_city} -> #{to_city} не знайдено."
  else
    puts "Знайдено поїздок: #{found_trips.size}"
  end

  found_trips
end
