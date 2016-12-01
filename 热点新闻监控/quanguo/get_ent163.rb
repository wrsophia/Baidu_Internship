#!/bin/usr/env ruby
# coding: gbk
#get_ent163.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'


html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"div.data_row").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/"div.data_row").each do |news|
    title_path = (news/"div.news_title")
    time_path = (news/"span.time")
        
    if (title_path/"a").inner_html.to_s != "" 
        href = (title_path/"a")[0].attributes['href'].split
        title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", (title_path/"a").inner_html.to_s)[0].strip
        time = Iconv.iconv("GBK//IGNORE", "GBK", time_path.inner_html.to_s)[0].strip
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
