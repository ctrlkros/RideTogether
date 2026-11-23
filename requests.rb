# frozen_string_literal: true

require_relative 'db_helpers'
require_relative 'trips'

def next_request_id(requests)
  return 1 if requests.empty?

  requests.map { |r| r[:id] }.max + 1
end

def create_request(current_user, trip_id, seats_requested)
  unless current_user && current_user[:role] == 'passenger'
    puts 'Помилка: Тільки пасажир може подавати заявку на бронювання.'
    return nil
  end

  trips = load_records('db/trips.yml')
  trip = trips.find { |t| t[:id] == trip_id.to_i }
  unless trip
    puts 'Помилка: Поїздку не знайдено.'
    return nil
  end

  if trip[:driver_id] == current_user[:id]
    puts 'Помилка: Водій не може бронювати власну поїздку!'
    return nil
  end

  seats = seats_requested.to_i
  if seats <= 0 || seats > available_seats_for(trip)
    puts 'Помилка: Некоректна кількість місць або недостатньо вільних місць.'
    return nil
  end

  requests = load_records('db/requests.yml')
  new_request = {
    id: next_request_id(requests),
    trip_id: trip[:id],
    passenger_id: current_user[:id],
    seats_requested: seats,
    status: 'pending'
  }

  requests << new_request
  save_records('db/requests.yml', requests)
  puts "Заявку ##{new_request[:id]} створено (статус: pending)."
  new_request
end

def manage_request(current_user, request_id, new_status)
  unless %w[approved rejected].include?(new_status)
    puts 'Помилка: Невірний статус (дозволено лише approved або rejected).'
    return nil
  end

  requests = load_records('db/requests.yml')
  request = requests.find { |r| r[:id] == request_id.to_i }
  unless request
    puts 'Помилка: Заявку не знайдено.'
    return nil
  end

  trips = load_records('db/trips.yml')
  trip = trips.find { |t| t[:id] == request[:trip_id] }
  if !trip || trip[:driver_id] != current_user[:id]
    puts 'Помилка: Ви можете керувати заявками тільки для власних поїздок!'
    return nil
  end

  if new_status == 'approved' && request[:seats_requested] > available_seats_for(trip)
    puts 'Помилка: Недостатньо вільних місць для підтвердження цієї заявки!'
    return nil
  end

  request[:status] = new_status
  save_records('db/requests.yml', requests)
  puts "Статус заявки ##{request[:id]} змінено на #{new_status}."
  request
end
