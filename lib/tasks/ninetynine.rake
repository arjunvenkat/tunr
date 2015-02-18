namespace :scrape do
  desc "Scrape 99% invisible data"
  task :ninetynine => :environment do
    require 'mechanize'
    require 'open-uri'
    require 'csv'
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


    # CSV.open("99percent_invisible.csv", "wb") do |csv|
    #   csv << ["season", "episode_num", "title", "description", "duration", "published_date", "url", "explicit"]
    # end
    agent = Mechanize.new

    url = "http://99percentinvisible.org/category/episode/"


    while url != nil
      current_page = agent.get(url)
      episodes = current_page.search('.content-area article')
      episodes.each do |ep|
        heading = ep.search('h1').text
        if heading.include?(":")
          split_heading = heading.split(":")
          ep_num = split_heading[0].strip
          ep_title = split_heading[1].strip
        else
          ep_num = ""
          ep_title = heading
        end
        ep_link = ep.search('h1 a').attr("href")
        ep_date = ep.search('time').text
        season = ep_date.split(',')[1].strip
        desc_page = agent.get(ep_link)
        ep_desc = desc_page.search('.entry-content p:nth-of-type(1)').text

        podcast  = Podcast.find_by(name: "99% Invisible")
        e = Episode.new
        e.podcast_id = podcast.id
        e.season = season
        e.episode_num = ep_num
        e.title = ep_title.encode('utf-8', :fallback => fallback)
        e.desc = ep_desc.encode('utf-8', :fallback => fallback)
        e.duration = 20
        e.published_date = ep_date
        e.url = ep_link
        e.explicit = false
        e.save


        # CSV.open("99percent_invisible.csv", "a+") do |csv|
        #   csv << [season, ep_num, ep_title, ep_desc, 20, ep_date, ep_link, ""]
        # end
        puts "#{ep_num} #{ep_title} ** completed **"
      end


      next_page = current_page.search('.nav-previous a')
      if next_page.empty? == false
        url = next_page.attr('href')
      else
        url = nil
      end
    end


    puts
    puts
    puts "Completed scrape of 99% invisible data"
  end
end
