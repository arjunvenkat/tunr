namespace :scrape do
  desc "Scrape WTF data"
  task :wtf => :environment do
    require 'mechanize'
    require 'open-uri'


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

    podcast = Podcast.find_by(name: "WTF")
    unless podcast
      podcast = Podcast.new
      podcast.name = "WTF"
      podcast.desc = "Comedian Marc Maron is tackling the most complex philosophical question of our day - WTF? He'll get to the bottom of it with help from comedian friends, celebrity guests and the voices in his own head."
      podcast.image_url = "http://upload.wikimedia.org/wikipedia/en/8/8f/WTF_with_Marc_Maron.png"
      podcast.save
    end

    agent = Mechanize.new
    url = "http://www.wtfpod.com/podcast/"

    while url != nil
      current_page = agent.get(url)
      ep_listings = current_page.search('#main .podcast-listing')
      ep_listings.each do |ep_listing|
        ep_heading =  ep_listing.search('h2 a')
        if ep_heading.text.include?("-") && ep_heading.text.include?("Episode") && ep_heading.text.include?("FLASHBACK") == false
          split_heading = ep_heading.text.split("-")
          ep_num = split_heading[0].split("Episode")[1].strip
          ep_title = split_heading[1].strip
        else
          ep_num = ""
          ep_title = ep_heading.text
        end
        ep_link = ep_heading.attr('href')
        unformatted_date = ep_listing.search('.entry-date').text
        date_array = unformatted_date.split(",")
        season = date_array[2].strip
        ep_date = "#{date_array[1].strip}, #{date_array[2].strip}"
        ep_desc = ep_listing.search('p').text

        matched_episodes = podcast.episodes.where(title: ep_title)
        unless matched_episodes.present?
          e = Episode.new
          e.podcast_id = podcast.id
          e.title = ep_title
          e.season = season
          e.episode_num = ep_num
          e.desc = ep_desc.strip
          e.duration = 90
          e.published_date = Date.parse(ep_date)
          e.url = ep_link
          e.explicit = true
          e.save
          puts "season: #{season} ep:#{ep_num} - #{ep_title} ** completed **"
        else
          puts "#{matched_episodes.first.title} already present in database"
        end

      end


      pagination_links = current_page.search('.pagination a')
      url = nil
      pagination_links.each do |link|
        if link.text == ">"
          url = link.attr('href')
          puts url
        end
      end
    end

    puts
    puts
    puts "Completed scrape of WTF data"


  end
end
