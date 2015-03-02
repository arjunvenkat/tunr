require 'csv'

namespace :from_csv do
  desc "import csv data for podcasts"
  task :episodes => :environment do

    # unless Podcast.find_by(name: "TED Radio Hour")
    #   p = Podcast.new
    #   p.name = "TED Radio Hour"
    #   p.desc = "An idea is the one gift that you can hang onto even after you've given it away. Welcome to TED Radio Hour hosted by Guy Raz – a journey through fascinating ideas: astonishing inventions, fresh approaches to old problems, new ways to think and create. Based on Talks given by riveting speakers on the world-renowned TED stage, each show is centered on a common theme – such as the source of happiness, crowd-sourcing innovation, power shifts, or inexplicable connections – and injects soundscapes and conversations that bring these ideas to life."
    #   # p.save

    #   file_path = Rails.root.join('lib','scraper_data','ted_radio_hour_clean.csv').to_s
    #   CSV.foreach(file_path) do |row|
    #     puts "test"
    #   end
    # end


    unless Podcast.find_by(name: "Serial")
      p = Podcast.new
      p.name = "Serial"
      p.desc = "Serial is a podcast from the creators of This American Life, and is hosted by Sarah Koenig. Serial tells one story - a true story - over the course of an entire season. Each season, we'll follow a plot and characters wherever they take us. And we won’t know what happens at the end until we get there, not long before you get there with us. Each week we bring you the next chapter in the story, so it's important to listen to the episodes in order, starting with Episode 1."
      p.image_url = "http://mark.gg/assets/images/posts/2014-12-08/serial-logo.png"
      p.save
      puts "created podcast: #{p.name}"
    end

    p = Podcast.find_by(name: "Serial")
    unless p.episodes.present?
      created_count = 0
      file_path = Rails.root.join('lib','scraper_data','serial.csv').to_s
      CSV.foreach(file_path, headers: true) do |row|
        e = Episode.new
        e.podcast_id = p.id
        e.season = row[0]
        e.episode_num = row[1]
        e.title = row[2]
        e.desc = row[3]
        e.duration = 60
        e.published_date = Date.parse(row[5])
        e.url = row[6]
        e.explicit = true
        created_count += 1 if e.save
      end
      puts "#{p.episodes.count} episodes created for #{p.name}"
    end

    unless Podcast.find_by(name: "You Made It Weird")
      p = Podcast.new
      p.name = "You Made It Weird"
      p.desc = "Everybody has secret weirdness, Pete Holmes gets comedians to share theirs."
      p.image_url = "http://a5.mzstatic.com/us/r30/Music4/v4/a6/41/22/a6412228-2ed4-d29e-61f8-1b30d6a1bbb5/cover326x326.jpeg"
      p.save
      puts "created podcast: #{p.name}"
    end

    p = Podcast.find_by(name: "You Made It Weird")
    unless p.episodes.present?
      created_count = 0
      file_path = Rails.root.join('lib','scraper_data',"you_made_it_weird_clean.csv"
).to_s
      CSV.foreach(file_path, headers: true) do |row|
        e = Episode.new
        e.podcast_id = p.id
        e.season = row[1]
        e.episode_num = row[2]
        e.title = row[4].encode('UTF-8')
        e.desc = row[5].encode('UTF-8')

        duration_array = row[6].split(":")
        calc_duration = (duration_array[0].to_i*60) + duration_array[2].to_i

        e.duration = calc_duration
        puts row[7].inspect
        e.published_date = Date.strptime(row[7], "%m/%d/%y")
        puts e.published_date.inspect
        e.url = row[8]
        e.explicit = true
        puts e.inspect
        # created_count += 1 if e.save
      end
      puts "#{p.episodes.count} episodes created for #{p.name}"
    end


  end
end
