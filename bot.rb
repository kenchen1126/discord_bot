require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'discordrb'
def find_beauty(articles, queue)
    articles.each do |article|
        queue << article["href"].delete_prefix("/bbs/Beauty/") if article.content.match?("[正妹]")
    end
end

def open_articles(queue)
    image_list = []
    queue.each do |article|
        page = RestClient.get("https://pttent.com/beauty/#{article}")
        page_doc = Nokogiri::HTML(page)
        images = page_doc.css('div.bbs-content a')
        image_list << images[0]["href"] if images[0]["href"][-4..-1] == ".jpg" || ".png"
    end
    image_list
end


bot = Discordrb::Bot.new token: 'Nzk0ODA3Mjc4NjQ0NjI1NDA4.X_AL9g.C4b09PaFK3BpQ5sfSqRipedGYvY'

queue = ["https://www.ptt.cc/bbs/Beauty/index.html"]

# 通過18禁頁面
rs = RestClient::Request.execute(method: :post, url: 'https://www.ptt.cc/ask/over18',
                                payload: {from: '/bbs/Beauty/index.html', yes: 'yes'}
                                ) do |response|
                                case response.code
                                when 301, 302, 307
                                response.follow_redirection
                                else
                                response.return!
                                end
                                end 
raw_cookie = {"over18": rs.cookies["over18"]}
cookie = raw_cookie.to_a.map{|key,val| "%s=%s" % [key, val]}.join '; '
uri = URI.open(queue.shift, header = "Cookie" => cookie)

# 找到頁面中的文章的連結
home_page_doc = Nokogiri::HTML(uri)
articles = home_page_doc.css('div.r-ent div.title a')
find_beauty(articles, queue)

# 找到頁面中圖片的連結
all_img_urls = open_articles(queue)

bot.message(with_text: '貓') do |e|
    e.respond '喵'
end
bot.message(with_text: "宣庭") do |e|
    e.respond "大蟀哥"
end
bot.message(with_text: "beauty") do |e|
    all_img_urls.each do |img|
        e.respond img
    end
end



bot.run






