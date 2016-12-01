#!/sh work@cq01-testing-wiseh102.cq01.baidu.comin/usr/env ruby
# coding : gbk
#tag_divide.rb
#################################


require 'iconv'
require 'readline'
require 'fileutils'

file_path = "./output/1067/output"
day = Time.new.strftime("%Y%m%d")

file = File.open("#{file_path}/#{day}", "r")
arr_now = file.readlines


tag = Hash.new

["µØÕð", "Ëú·½", "ËúÏÝ", "»ýË®", "³µ»ö", "Í£ÔË"].each do |item|
    tag[item] = "accident"
end

["ÏÞÐÐ", "ÊÂ¹Ê", "½»Í¨¹ÜÖÆ", "Óµ¶Â", "ÁÙÊ±´ëÊ©", "Ê©¹¤", "µØÌú", "Â·¿ö", "¹ìµÀ½»Í¨", "½ûÐÐ", "Ò¡ºÅ", "ÓÍ¼Û"].each do |item|
    tag[item] = "traffic"
end

["Ì¨·ç", "±©Óê", "Îíö²", "·ÀÑ´", "º®³±"].each do |item|
    tag[item] = "weather"
end

["°Ù¶ÈµØÍ¼", "¸ßµÂµØÍ¼", "ÑîÑó"].each do |item|
    tag[item] = "others"
end

file_hash = Hash.new
file_hash = {"accident" => $accident, "traffic" => $traffic, "weather" => $weather, "others" => $others}

tag_name = ["accident", "traffic", "weather", "others"]

for name in tag_name
    file_hash[name] = File.open("#{file_path}/#{day}_#{name}","w+")
end

arr_now.each do |line|
    line = Iconv.iconv("GBK//IGNORE", "GBK", line)[0]
    tag.each do |key, value|
        if line.include? "#{key}"
            file_hash[value].puts("#{line}")
        end
    end
end

for name in tag_name
    file_hash[name].close
end