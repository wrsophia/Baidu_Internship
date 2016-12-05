#!/bin/usr/env ruby
# coding: gbk
#get_sztb_gjcx.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"div.list>ul>li").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end
    

(doc/"div.list>ul>li").each do |news|
    if (news/"a").inner_html.to_s != ""
        p_href = (news/"a")[0].attributes['href'].strip
        href = "http://www.sztb.gov.cn/bsfw/wycx/gjcx/cxtx" + p_href[1 ... p_href.length]
        title = "[shenzhen]" + Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"a").inner_html.to_s)[0].strip
        time = Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"span").inner_html.to_s)[0].strip
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
