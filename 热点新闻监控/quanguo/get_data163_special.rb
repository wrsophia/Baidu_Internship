#!/bin/usr/env ruby
# coding: gbk
#get_data163_special
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'


html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"ul.post-list>li").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/"ul.post-list>li").each do |news|
    if (news/"a").inner_html.to_s != ""
        href = (news/"a")[0].attributes['href'].strip
        if (news/"em.cms-I_Blank_").inner_html.to_s == ""
            title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", (news/"h2").inner_html.to_s)[0].strip
        else
            title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", (news/"em.cms-I_Blank_").inner_html.to_s)[0].strip
        end
        time = " "
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
