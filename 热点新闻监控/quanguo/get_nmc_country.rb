#!/bin/usr/env ruby
# coding: gbk
#get_nmc_country.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"div.p-nav>ul>li").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/"div.p-nav>ul>li").each do |news|
    href = "http://www.nmc.gov.cn" + news.search('/a')[0].attributes['href'].strip
    title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "UTF-8", news.search('/a').inner_html.to_s)[0].strip
    
    res = Net::HTTP.get_response(URI.parse("#{href}"))
    tmp_doc = Hpricot(res.body)
        
    year = Iconv.iconv("GBK//IGNORE", "UTF-8", (tmp_doc/"div.author").search('b[1]').inner_html.to_s)[0].strip + "年"
    month = Iconv.iconv("GBK//IGNORE", "UTF-8", (tmp_doc/"div.author").search('b[2]').inner_html.to_s)[0].strip + "月"
    day = Iconv.iconv("GBK//IGNORE", "UTF-8", (tmp_doc/"div.author").search('b[3]').inner_html.to_s)[0].strip + "日"
    hour = Iconv.iconv("GBK//IGNORE", "UTF-8", (tmp_doc/"div.author").search('b[4]').inner_html.to_s)[0].strip + "时"
    
    time = year + month + day + hour
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
