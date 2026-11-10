require 'yaml'

def save_records(file_path, data_array)

  yaml_text = data_array.to_yaml
  File.write(file_path, yaml_text)
  return true
  
rescue => e

  puts "Помилка при збереженні у файл #{file_path}: #{e.message}"
  return false
end

def load_records(file_path)
  unless File.exist?(file_path)
    return []
  end

  raw_text = File.read(file_path)
  parsed_data = YAML.load(raw_text)

  return parsed_data || []
rescue => e

  puts "Помилка при завантаженні з файлу #{file_path}: #{e.message}"
  return []
end
