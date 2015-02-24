namespace :scrape do
  desc "Scrape This American Life data"
  task :tal => :environment do
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

    agent = Mechanize.new

    # find corresponding podcast
    p = Podcast.find_by(name: "This American Life")

    year_eps_url = "http://en.wikipedia.org/wiki/Lists_of_This_American_Life_episodes"
    year_eps_page = agent.get(year_eps_url)
    year_eps_page_links = year_eps_page.search('#mw-content-text ul li a')

    year_eps_page_links.each do |page_link|
      # pulls out just the episode links
      if page_link['href'].downcase.include?('list_of_1') || page_link['href'].downcase.include?('list_of_2')
        page_link_url = "http://en.wikipedia.org#{page_link['href']}"
        ep_list_page = agent.get(page_link_url)
        season = ep_list_page.search('#mw-content-text p b:nth-of-type(1)').text

        ep_info = ep_list_page.search('#mw-content-text ul a[rel=nofollow]')
        ep_info.each do |ep_info|
          if ep_info.text.downcase.include?("episode")
            ep_link = ep_info['href']
            # puts ep_link
            begin
              desc_page = agent.get(ep_link)
            rescue
              puts "error with #{ep_link}"
            end
            if desc_page == nil
              puts "page doesn't exist"
            else
              ep_heading_text = desc_page.search('h1').text
              ep_heading_array = ep_heading_text.split(':')
              unless ep_heading_array.empty?
                unless ep_heading_array[0] == nil
                  ep_num = ep_heading_array[0].strip
                end
                unless ep_heading_array[1] == nil
                  ep_name = ep_heading_array[1].strip
                end
              end
              ep_date = desc_page.search('.top .date').text
              # puts "#{ep_num} - #{ep_name}"

              act_grafs = desc_page.search('#episode-acts .act-body p')
              ep_desc = ""
              act_grafs.each do |act_graf|
                ep_desc << "#{act_graf.text}\n\n"
                # puts act_graf.text
                # puts
              end

              ep_desc.encode('utf-8', :fallback => fallback)
                            .gsub('&amp;', '&')
                            .gsub('&nbsp;', ' ')
                            .gsub('&ldquo;', '\"')
                            .gsub('&rdquo;', '\"')
                            .gsub('&rsquo;', '\'')
                            .gsub('&rsquo;', '\"')

              e = Episode.new
              e.podcast_id = p.id
              e.title = ep_name.encode('utf-8', :fallback => fallback)
              e.season = season
              e.episode_num = ep_num
              e.desc = ep_desc.encode('utf-8', :fallback => fallback)
              e.duration = 60
              e.published_date = Date.parse(ep_date)
              e.url = ep_link
              e.explicit = false

              e.save

              # CSV.open("tal.csv", "a+") do |csv|
              #   csv << [season, ep_num, ep_name, ep_desc, 60, ep_date, ep_link, ""]
              # end

              puts "season: #{season} ep:#{ep_num} - #{ep_name} ** completed **"
            end
          end
        end


      end
    end

    puts
    puts
    puts "Completed scrape of This American Life data"
  end
end
