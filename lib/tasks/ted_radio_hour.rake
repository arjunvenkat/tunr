namespace :scrape do
  desc "Scrape TED radio hour data"
  task :ted_radio_hour => :environment do
    require 'rss'
    require 'mechanize'
    require 'open-uri'
    require 'csv'
    require "net/http"
    require "sanitize"
    require 'date'


     fallback = {
            'Š'=>'S', 'š'=>'s', 'Ð'=>'Dj','Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A',
            'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I',
            'Ï'=>'I', 'Ñ'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U',
            'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss','à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a',
            'å'=>'a', 'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i',
            'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 'ö'=>'o', 'ø'=>'o', 'ù'=>'u',
            'ú'=>'u', 'û'=>'u', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y', 'ƒ'=>'f', '’' => '', '…' => '...', '”' => '"',
            '“' => '"', '—' => '-'
          }

    agent = Mechanize.new

    url = "http://www.npr.org/programs/ted-radio-hour/archive"
    month_hash = {"1" => "January",
                  "2" => "February",
                  "3" => "March",
                  "4" => "April",
                  "5" => "May",
                  "6" => "June",
                  "7" => "July",
                  "8" => "August",
                  "9" => "September",
                  "10" => "October",
                  "11" => "November",
                  "12" => "December"}


    page = agent.get(url)
    years = page.search('.archive-nav .year')


    years.each do |year|
      season = year.search('h1').text
      months = year.search('li')
      months.each do |month|
        month_link = month.search('a').attr('href')
        month_link = "http://npr.org#{month_link}"
        date_marker = month_link.split("date=")[1]
        month_marker = date_marker.split("-")[0]
        month_page = agent.get(month_link)

        month_eps = month_page.search('#episodelist article')
        month_eps.each do |month_ep|
          unformatted_ep_date = month_ep.search('h1').text
          ep_date =  unformatted_ep_date.strip.split("\n")[1].strip
          if ep_date.include?(month_hash[month_marker])
            ep_link = month_ep.search('h1 a').attr('href')
            ep_title = month_ep.search('.title').text
            ep_desc = month_ep.search('.teaser').text
                                                  .gsub('&amp;', '&')
                                                  .gsub('&nbsp;', ' ')
                                                  .gsub('&ldquo;', '\"')
                                                  .gsub('&rdquo;', '\"')
                                                  .gsub('&rsquo;', '\'')
                                                  .gsub('&rsquo;', '\"')


            podcast = Podcast.find_by(name: "TED Radio Hour")
            unless podcast
              podcast = Podcast.new
              podcast.name = "TED Radio Hour"
              podcast.desc = "Welcome to TED Radio Hour hosted by Guy Raz – a journey through fascinating ideas: astonishing inventions, fresh approaches to old problems, new ways to think and create. Based on Talks given by riveting speakers on the world-renowned TED stage, each show is centered on a common theme – such as the source of happiness, crowd-sourcing innovation, power shifts, or inexplicable connections – and injects soundscapes and conversations that bring these ideas to life."
              podcast.image_url = "http://mediad.publicbroadcasting.net/p/wrkf/files/201301/trh_logo_442.png"
              podcast.save
              puts "created podcast: #{podcast.name}"
            end

            unless podcast.episodes.where(title: ep_title).present?
              e = Episode.new
              e.podcast_id = podcast.id
              e.season = season
              e.episode_num = ""
              e.title = ep_title
              e.desc = ep_desc
              e.duration = 60
              e.published_date = Date.parse(ep_date)
              e.url = ep_link
              e.explicit = false
              e.save
              puts "#{season} - #{ep_title} - #{ep_date} ** completed **"
            end


            # CSV.open("ted_radio_hour.csv", "a+") do |csv|
            #   csv << [season, "", ep_title, ep_desc, "60", ep_date, ep_link, ""]
            # end
          end
        end
      end
    end


    podcast = Podcast.find_by(name: "TED Radio Hour")
    podcast.episodes.order('published_date').each_with_index do |ep, index|
      ep.episode_num = index + 1
      ep.save
    end

    puts
    puts
    puts "Completed scrape of Ted Radio Hour data"
  end
end
