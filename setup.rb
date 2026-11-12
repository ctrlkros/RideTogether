# frozen_string_literal: true

require 'fileutils'

FileUtils.mkdir_p('db')

files = ['db/users.yml', 'db/trips.yml', 'db/requests.yml']

files.each do |file|
  if File.exist?(file)
    puts "Файл #{file} вже існує, пропущено."
  else
    File.write(file, "--- []\n")
    puts "Файл #{file} успішно створено."
  end
end

puts 'Ініціалізація бази даних завершена успішно!'
