require 'json'
require 'pry'
require 'date'

Dir.glob('/mnt/c/Users/ID055730/Downloads/Takeout/Google Foto_s/**/*.json').each do |json|
  JSON.parse(File.open(json).read, {:symbolize_names => true}) => {title:, photoTakenTime: {timestamp:}}
  
  data = "#{DateTime.strptime(timestamp,'%s').strftime("%FT%TZ")}, #{title.sub(/^ns_/, "")}\n"

  File.write("pictures.csv", data, mode: "a")
  puts "."
  rescue
    pp JSON.parse(File.open(json).read, {:symbolize_names => true})
    # binding.pry
end


