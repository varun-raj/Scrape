
require 'open-uri'
require 'openssl'
require 'nokogiri'
require 'json'
require 'mysql2'
require 'parallel'
require 'ruby-progressbar'

def getopapps
doc = Nokogiri::HTML(open("topapps.html"))
apps = doc.css(".details  .title")
log_data = Array.new
Parallel.each(apps,:in_threads => 10,:progress => "Getting Apps") do |app|
	log_data.push(app['href'][23..-1]) 
end
log_data
return log_data
end

def getdata(appid)
data = Hash.new
doc = Nokogiri::HTML(open("https://play.google.com/store/apps/details?id="+appid))
data["name"] = doc.css(".document-title>div").text.strip
data["package_id"] = appid
data["version"] = doc.css("div[itemprop='softwareVersion']").text.strip
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

def main
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "root", :database => "scraper")
topapps = getopapps
count = 0
Parallel.map(topapps,:in_threads => 1,:in_processes=>10,:progress => "Doing stuff") do |app|
	   	puts "checking " + app.to_s
     count = count + 1
     check = client.query("select package_id from apps where package_id = '#{app}'")
     if check.count == 0
 
     	data = getdata(app)
		result = client.query("INSERT INTO apps (name,version,company,package_id,description,date_published,minimum_android,dev_website,email,dev_address,downloads_count) VALUES ('#{client.escape(data['name'].to_s)}','#{data['version']}','#{client.escape(data['company'])}','#{data['package_id']}','#{client.escape(data['description'].to_s)}','#{data['date_published']}','#{data['minimum_android']}','#{data['dev_website']}','#{data['email']}','#{client.escape(data['dev_address'])}','#{data['downloads_count']}')")
		puts count.to_s + ". " + data['name'].to_s + " Added"
	else 
    	puts count.to_s + ". " + app.to_s + " Already Exisiting"
	end
     
 end
 end

 main
  puts "Everybody's done!"

