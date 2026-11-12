# frozen_string_literal: true

require 'bcrypt'
require_relative 'db_helpers'

def register_user(name, phone, password, role)
  users = load_records('db/users.yml')

  if users.any? { |user| user[:phone] == phone }
    puts 'Помилка: Користувач з таким номером телефону вже існує!'
    return nil
  end

  password_hash = BCrypt::Password.create(password)

  if users.empty?
    new_id = 1
  else
    max_id = users.map { |u| u[:id] }.max
    new_id = max_id + 1
  end

  new_user = {
    id: new_id,
    name: name,
    phone: phone,
    password_digest: password_hash.to_s,
    role: role
  }

  users << new_user
  save_records('db/users.yml', users)

  puts "Користувач #{name} успішно зареєстрований як #{role}!"
  { id: new_id, name: name, phone: phone, role: role }
end

def login_user(phone, password)
  users = load_records('db/users.yml')

  user = users.find { |u| u[:phone] == phone }
  if user.nil?
    puts 'Помилка: Користувача з таким номером телефону не знайдено!'
    return nil
  end

  bcrypt_password = BCrypt::Password.new(user[:password_digest])
  if bcrypt_password == password
    puts "Вхід успішний! Вітаємо, #{user[:name]}."

    { id: user[:id], name: user[:name], phone: user[:phone], role: user[:role] }
  else
    puts 'Помилка: Невірний пароль!'
    nil
  end
end
