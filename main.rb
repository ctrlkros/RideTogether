# frozen_string_literal: true

require_relative 'auth'
require_relative 'db_helpers'
require_relative 'trips'
require_relative 'admin'

ADMIN_SECRET = 'admin2026'

def auth_menu
  loop do
    puts "\n=== ВХІД У СИСТЕМУ RIDE TOGETHER ==="
    puts '1. Увійти в акаунт | 2. Зареєструватися | 0. Вихід'
    choice = gets.chomp.strip

    return nil if choice == '0'

    if choice == '1'
      puts 'Введіть номер телефону:'
      phone = gets.chomp.strip
      puts 'Введіть пароль:'
      password = gets.chomp.strip

      user = login_user(phone, password)
      return user if user

    elsif choice == '2'
      puts "Введіть ваше ім'я:"
      name = gets.chomp.strip
      puts 'Введіть номер телефону:'
      phone = gets.chomp.strip
      puts 'Придумайте пароль:'
      password = gets.chomp.strip

      puts 'Оберіть роль (1 - Пасажир, 2 - Водій, 3 - Адмін):'
      role_choice = gets.chomp.strip

      role = case role_choice
             when '1' then 'passenger'
             when '2' then 'driver'
             when '3'
               puts 'Введіть секретний код адміністратора:'
               secret = gets.chomp.strip
               if secret != ADMIN_SECRET
                 puts 'Помилка: Невірний секретний код!'
                 next
               end
               'admin'
             else
               puts 'Помилка: Оберіть коректну роль (1, 2 або 3)!'
               next
             end

      if name.empty? || phone.empty? || password.empty?
        puts 'Помилка: Усі поля мають бути заповнені!'
        next
      end

      user = register_user(name, phone, password, role)
      return user if user
    else
      puts 'Оберіть коректний пункт меню.'
    end
  end
end

loop do
  current_user = auth_menu
  break if current_user.nil?

  if current_user[:role] == 'admin'
    admin_menu(current_user)
    next
  end

  loop do
    trips = load_records('db/trips.yml')
    requests = load_records('db/requests.yml')

    puts "\n=== КАБІНЕТ: #{current_user[:name]} (#{current_user[:role]}) ==="

    if current_user[:role] == 'passenger'
      puts '1. Знайти поїздку та подати заявку | 0. Вийти з акаунту'
      action = gets.chomp.strip
      break if action == '0'

      if action == '1'
        puts 'Куди їдете? (Enter - показати всі напрямки):'
        city = gets.chomp.strip
        found_trips = trips.select do |t|
          t[:free_seats].to_i.positive? && t[:to_city].downcase.include?(city.downcase)
        end

        if found_trips.empty?
          puts 'Активних поїздок не знайдено.'
          next
        end

        found_trips.each_with_index do |trip, index|
          puts "#{index + 1}. #{trip[:from_city]} → #{trip[:to_city]} | Водій ID: #{trip[:driver_id]} | Місць: #{trip[:free_seats]} | Ціна: #{trip[:price]} грн"
        end

        puts 'Введіть номер поїздки для бронювання (0 - скасувати):'
        num = gets.chomp.to_i
        next if num < 1 || num > found_trips.size

        selected_trip = found_trips[num - 1]
        new_req_id = requests.empty? ? 1 : requests.map { |r| r[:id].to_i }.max + 1

        requests << {
          id: new_req_id,
          trip_id: selected_trip[:id],
          passenger_name: current_user[:name],
          passenger_id: current_user[:id],
          approved: false
        }
        save_records('db/requests.yml', requests)
        puts 'Заявку на 1 місце надіслано водієві!'
      end

    elsif current_user[:role] == 'driver'
      puts '1. Створити поїздку | 2. Переглянути та підтвердити заявки | 0. Вийти з акаунту'
      action = gets.chomp.strip
      break if action == '0'

      if action == '1'
        puts 'Звідки їдете?'
        from_city = gets.chomp.strip
        puts 'Куди їдете?'
        to_city = gets.chomp.strip
        puts 'Дата та час (наприклад, 25.11 14:00):'
        date_time = gets.chomp.strip
        puts 'Кількість вільних місць:'
        seats = gets.chomp.to_i
        puts 'Ціна за місце (грн):'
        price = gets.chomp.to_f

        if from_city.empty? || to_city.empty? || seats < 1
          puts 'Помилка: Перевірте правильність маршруту та кількості місць!'
          next
        end

        create_trip(current_user[:id], from_city, to_city, date_time, seats, price)

      elsif action == '2'
        my_requests = requests.select do |req|
          trip = trips.find { |t| t[:id] == req[:trip_id] }
          trip && trip[:driver_id] == current_user[:id] && req[:approved] == false
        end

        if my_requests.empty?
          puts 'Нових заявок на ваші поїздки немає.'
          next
        end

        my_requests.each_with_index do |req, index|
          trip = trips.find { |t| t[:id] == req[:trip_id] }
          puts "#{index + 1}. Пасажир: #{req[:passenger_name]} | Маршрут: #{trip[:from_city]} → #{trip[:to_city]}"
        end

        puts 'Введіть номер заявки для підтвердження (0 - назад):'
        num = gets.chomp.to_i
        next if num < 1 || num > my_requests.size

        selected_req = my_requests[num - 1]
        trip = trips.find { |t| t[:id] == selected_req[:trip_id] }

        if trip && trip[:free_seats].positive?
          trip[:free_seats] -= 1
          selected_req[:approved] = true
          save_records('db/trips.yml', trips)
          save_records('db/requests.yml', requests)
          puts "Заявку підтверджено! Залишилось вільних місць: #{trip[:free_seats]}."
        else
          puts 'Помилка: У машині більше немає вільних місць.'
        end
      end
    end
  end
end
