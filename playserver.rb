require 'sinatra'
require 'sinatra/reloader'

require 'open-uri'
require 'nokogiri'
require 'json'





get '/android/:appid' do

def getdata(url)
data = Hash.new
doc = Nokogiri::HTML(open(url))
version = 
data["name"] = doc.css(".document-title>div").text.strip
data["version"] = doc.css("div[itemprop='softwareVersion']").text.strip
data["package_id"] = params['appid']
data["company"] = doc.css(".primary > span").text.strip
data["description"] = doc.css(".id-app-orig-desc").text.strip
data["date_published"] = doc.css("div[itemprop='datePublished']").text.strip
data["minimum_android"] = doc.css("div[itemprop='operatingSystems']").text.strip
data["dev_website"] = doc.css(".dev-link")[0]['href'] ? doc.css(".dev-link")[0]['href'] : "No Website" 
data["email"] = doc.css(".dev-link")[1] ? doc.css(".dev-link")[1]['href'] : "No Email" 
data["dev_address"] = doc.css(".physical-address") ? doc.css(".physical-address").text.strip : "No Address"
data["downloads_count"] = doc.css("div[itemprop='numDownloads']").text.strip
log = doc.css(".recent-change")
log_data = Array.new
log.each do |l|
	log_data.push(l.text.strip)
end
data["change_log"] = log_data
return data
end

content_type :json
     data = getdata("https://play.google.com/store/apps/details?id="+params['appid'])
 "#{data.to_json}"
end