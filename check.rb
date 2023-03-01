require 'exif'
require 'date_core'

existing = File.open('./pictures.csv')
  .readlines
  .map { |line| 
    line.chomp.split(', ') => [time, filename]
    {filename: filename, time: time}
  }.group_by{|item| item[:filename]}
  .map {|filename, items|
    items = items.map{|item|
      item[:time]
    }
    [filename, items]
  }.to_h


  Dir.glob('./photos/**/*').each do |img|
    data = Exif::Data.new(File.open(img))
  
    datetime = DateTime.new(*data.date_time.sub("\s", ":").split(":").map(&:to_i), data.offset_time).new_offset(0)
    date = datetime.strftime("%FT%TZ")
    filename = File.basename(img) 

    pp existing[filename].include? date
  end

  puts "\n\n\n\n"
  # pp existing.keys

