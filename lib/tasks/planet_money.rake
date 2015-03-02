namespace :scrape do
  desc "Scrape Planet Money data"
  task :planet_money => :environment do
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
    url = "http://www.npr.org/blogs/money/127413729/podcast/archive"

    page = agent.get(url)

    months = page.search('.archive-nav li')
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

    months.each do |month|
      month_link = month.search('a').attr('href')
      month_link = "http://www.npr.org#{month_link}"
      date_marker = month_link.split("date=")[1]
      month_marker = date_marker.split("-")[0]

      month_page = agent.get(month_link)
      month_eps = month_page.search('.archivelist article')
      month_eps.each do |month_ep|
        ep_heading = month_ep.search('h1').text
        if ep_heading.include?("Episode")
          ep_heading = ep_heading.split(":")
          ep_num = ep_heading[0].split("Episode ")[1]
          begin
            ep_title = ep_heading[1].strip
          rescue
            puts "error parsing title - #{ep_heading}"
          end
        else
          ep_title = ep_heading.strip
          ep_num = ""
        end

        ep_date = month_ep.search('time').text

        begin
          season = ep_date.split(",")[1].split("\u0095")[0].strip
        rescue
          puts "error parsing season"
        end

        ep_desc = month_ep.search('.teaser').text
        # sanitize date from description
        ep_desc.slice!(ep_date)
                          .gsub('&amp;', '&')
                          .gsub('&nbsp;', ' ')
                          .gsub('&ldquo;', '\"')
                          .gsub('&rdquo;', '\"')
                          .gsub('&rsquo;', '\'')
                          .gsub('&rsquo;', '\"')


        ep_link = month_ep.search('h1 a').attr('href')

        if ep_date.include?(month_hash[month_marker])
          podcast = Podcast.find_by(name: "Planet Money")
          unless podcast
            podcast = Podcast.new
            podcast.name = "Planet Money"
            podcast.desc = "Imagine you could call up a friend and say, \"Meet me at the bar and tell me what's going on with the economy.\" Now imagine that's actually a fun evening. That's what we're going for at Planet Money."
            podcast.image_url = "http://www.abrandao.com/wp-content/uploads/2013/10/planet_money_logo_mod.jpg"
            podcast.save
            puts "created podcast: #{podcast.name}"
          end

          unless podcast.episodes.where(title: ep_title).present?
            e = Episode.new
            e.podcast_id = podcast.id
            e.season = season
            e.episode_num = ep_num
            e.title = ep_title
            e.desc = ep_desc
            e.duration = 25
            e.published_date = Date.parse(ep_date)
            e.url = ep_link
            e.explicit = false
            e.save
            puts "#{ep_num} - #{ep_title} - #{ep_date} ** completed **"
          end

        end
      end

    end

    puts
    puts
    puts "Completed scrape of Planet Money data"



  end
end
