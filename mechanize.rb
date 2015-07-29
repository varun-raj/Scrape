require 'rubygems'
require 'mechanize'

agent = Mechanize.new
agent.set_proxy '78.186.178.153', 8080
page = agent.get('http://www.google.com/')

google_form = page.form('f')
google_form.q = 'new york city council'

page = agent.submit(google_form, google_form.buttons.first)

page.links.each do |link|
    if link.href.to_s =~/url.q/
        str=link.href.to_s
        strList=str.split(%r{=|&}) 
        url=strList[1] 
        puts url
    end 
end