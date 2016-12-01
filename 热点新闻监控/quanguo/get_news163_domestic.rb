#!/bin/usr/env ruby
# coding: gbk
#get_news163_domestic.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"div.na_detail div.news_title").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/"div.na_detail").each do |news|
    news_path = (news/"div.news_title")
    time_path = (news/"div.news_tag")
        
    href = news_path.search('/h3/a')[0].attributes['href'].strip
    title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", news_path.search('/h3/a').inner_html.to_s)[0].strip
    time = Iconv.iconv("GBK//IGNORE", "GBK", time_path.search('/span').inner_html.to_s)[0].strip
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
