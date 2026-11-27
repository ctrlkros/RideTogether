# frozen_string_literal: true

require_relative 'db_helpers'

def admin_menu(current_user)
  loop do
    users = load_records('db/users.yml')
    trips = load_records('db/trips.yml')
    requests = load_records('db/requests.yml')

    puts "\n=== ПАНЕЛЬ АДМІНІСТРАТОРА: #{current_user[:name]} ==="
    puts '1. Переглянути всіх користувачів'
    puts '2. Переглянути всі поїздки'
    puts '3. Видалити поїздку (за ID)'
    puts '4. Переглянути всі заявки'
    puts '5. Видалити користувача (за ID)'
    puts '0. Вийти з акаунту'

    choice = gets.chomp.strip
    break if choice == '0'

    case choice
    when '1'
      puts "\n=== УСІ КОРИСТУВАЧІ ==="
      users.each do |u|
        puts "ID: #{u[:id]} | Ім'я: #{u[:name]} | Тел: #{u[:phone]} | Роль: #{u[:role]}"
      end

    when '2'
      puts "\n=== УСІ ПОЇЗДКИ ==="
      puts 'Поїздок немає.' if trips.empty?
      trips.each do |t|
        puts "ID: #{t[:id]} | #{t[:from_city]} → #{t[:to_city]} | Водій ID: #{t[:driver_id]} | Місць: #{t[:free_seats]}/#{t[:total_seats]} | Ціна: #{t[:price]} грн"
      end

    when '3'
      puts 'Введіть ID поїздки для видалення:'
      trip_id = gets.chomp.to_i
      initial_size = trips.size
      trips.reject! { |t| t[:id] == trip_id }

      if trips.size < initial_size
        requests.reject! { |r| r[:trip_id] == trip_id }
        save_records('db/trips.yml', trips)
        save_records('db/requests.yml', requests)
        puts "Поїздку ##{trip_id} та пов'язані заявки успішно видалено!"
      else
        puts "Помилка: Поїздку з ID #{trip_id} не знайдено."
      end

    when '4'
      puts "\n=== УСІ ЗАЯВКИ ==="
      puts 'Заявок немає.' if requests.empty?
      requests.each do |r|
        status = r[:approved] ? 'Підтверджено' : 'Очікує'
        puts "ID: #{r[:id]} | Поїздка ##{r[:trip_id]} | Пасажир: #{r[:passenger_name]} | Статус: #{status}"
      end

    when '5'
      puts 'Введіть ID користувача для видалення:'
      user_id = gets.chomp.to_i
      if user_id == current_user[:id]
        puts 'Помилка: Ви не можете видалити власний акаунт!'
        next
      end

      initial_size = users.size
      users.reject! { |u| u[:id] == user_id }

      if users.size < initial_size
        save_records('db/users.yml', users)
        puts "Користувача ##{user_id} видалено!"
      else
        puts "Помилка: Користувача з ID #{user_id} не знайдено."
      end

    else
      puts 'Невірний вибір.'
    end
  end
end
