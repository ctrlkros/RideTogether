# frozen_string_literal: true

require 'yaml'

def save_records(file_path, data_array)
  yaml_text = data_array.to_yaml
  File.write(file_path, yaml_text)
  true
rescue StandardError => e
  puts "Помилка при збереженні у файл #{file_path}: #{e.message}"
  false
end

def load_records(file_path)
  return [] unless File.exist?(file_path)

  raw_text = File.read(file_path)
  parsed_data = YAML.safe_load(raw_text)

  parsed_data || []
rescue StandardError => e
  puts "Помилка при завантаженні з файлу #{file_path}: #{e.message}"
  []
end
