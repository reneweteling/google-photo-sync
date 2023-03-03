require 'pry'
require 'exif'
require 'date_core'
require 'mini_exiftool'

# sudo apt install exiftool

Dir.glob('./photos/f*').each do |img|
  file = File.open(img)
  begin
    data = Exif::Data.new(file)
    datetime = DateTime.new(*data.date_time.sub("\s", ':').split(':').map(&:to_i), data.offset_time).new_offset(0)
  rescue StandardError
    datetime = file.ctime.to_datetime

    exif = MiniExiftool.new(img)
    exif.date_time_original = datetime
    exif.save
  end

  pp img
  pp datetime

  #
  # date = datetime.strftime("%FT%TZ")
  # filename = File.basename(img)

  puts "\n\n"
end

puts "\n\n\n\n"
# pp existing.keys
