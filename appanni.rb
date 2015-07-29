require 'anemone'

Pattern = /(apps|android)\/+(ios)\/+(app)/
Anemone.crawl("https://www.appannie.com/apps/ios/top/?_ref=header&device=iphone") do |anemone|
  titles = []

  anemone.on_pages_like(Pattern) do |page|
  puts page.doc.at('title')
  	puts page.url
  	titles.push page.doc.at('title') rescue nil
  end
end