require 'fileutils'

FileUtils.mkdir_p('db')

files = ['db/users.yml', 'db/trips.yml', 'db/requests.yml']

files.each do |file|
  unless File.exist?(file)
    File.write(file, "--- []\n")
    puts "Файл #{file} успішно створено."
  else
    puts "Файл #{file} вже існує, пропущено."
  end
end

puts "Ініціалізація бази даних завершена успішно!"
