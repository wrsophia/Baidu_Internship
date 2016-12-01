#!/bin/usr/env ruby
# coding : gbk
#test_loop.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'

html_in = File.open("#{ARGV[0]}","r").read
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+")

if (doc/"li.listNews-item-s1").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end
    

(doc/"li.listNews-item-s1").each do |news|
    href = news.search("h3/a")[0].attributes['href']
    title = "[beijing]" + Iconv.iconv("GBK","UTF-8",news.search("h3/a").inner_html.to_s)[0].strip
    time = Iconv.iconv("GBK","UTF-8",(news/"p.from").inner_html.to_s)[0].strip
    now = Time.now
    
    catch :doc_each do
        f_out.pos = 0
        while line = f_out.gets
            str = line.split
            if str[0] == href
                throw :doc_each
            end
        end
        f_out.puts("#{href}\t#{title}\t#{time}\t#{now}\n")
    end

end

f_out.close
