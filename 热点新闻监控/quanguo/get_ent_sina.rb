#!/bin/usr/env ruby
# coding: gbk
#get_ent_sina.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/'div.news_list').inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/'div.news_list').each do |news|
    date = (news/"span.news_date")
    news = (news/"a.plate_title")
    if news.inner_html.to_s != ""
        href = news[0].attributes['href'].strip
        title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "UTF-8", news.inner_html.to_s)[0].strip
        time = Iconv.iconv("GBK//IGNORE", "UTF-8", date.inner_html.to_s)[0].strip
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
end

f_out.close

