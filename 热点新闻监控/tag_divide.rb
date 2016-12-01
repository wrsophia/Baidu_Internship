#!/sh work@cq01-testing-wiseh102.cq01.baidu.comin/usr/env ruby
# coding: gbk
#tag_divide.rb
#################################


require 'iconv'
require 'readline'
require 'fileutils'


t1 = Time.new.strftime("%Y%m%d%H%M")
p "-------------------------------------------------------"
p "#{t1}"

dir = ["quanguo", "beijing", "shanghai", "shenzhen", "guangzhou"]

p "fetching html starts..."
dir_num = Hash.new

for name in dir
    str = `./cs_client -c client.conf -f #{name} 2>&1`
    sleep 10
    file_id = /(task_id = )(\d+)/.match(str)
    dir_num["#{name}"] = file_id[2]
end
p "fetching html ends."


day = Time.new.strftime("%Y%m%d")

file_path = "./output/1067/output"

countlines = 0
if File.exist?("#{file_path}/#{day}")
    str_wc = `wc -l #{file_path}/#{day}`
    tmp = str_wc.split
    countlines = tmp[0].to_i
end

p "last: #{countlines} lines."

suffix="html_ruby.map"

p "analysis starts..."
for name in dir
    
    mapfile = "./output/1067/#{name}/#{suffix}"
    if File.exist?("#{mapfile}")
        file = File.open("#{mapfile}", "r")
        while line = file.gets
            line = line.chomp
            command_arr = line.split
            command = "ruby " + command_arr[0] + " " + command_arr[1] + dir_num["#{name}"] + command_arr[2] + " output/1067/output/#{day} " + command_arr[3] + " 2>>error_1067.log"
            res = system("#{command}")
            if (!res)
                print "false #{command}\n"
            end
        end
    else
        print "#{mapfile} does not exist!"
    end
    
end
p "analysis ends."


tag = Hash.new

["地震", "塌方", "塌陷", "积水", "车祸", "爆炸", "倒塌", "空难", "事故", "坠毁", "坠亡"].each do |item|
    tag[item] = "accident"
end

["限行", "交通事故", "交通管制", "拥堵", "临时措施", "施工", "地铁", "路况", "轨道交通", "禁行", "摇号", "油价", "机场", "公交线路", "追尾", "停运", "晚高峰", "临时封闭", "马拉松", "严重晚点", "火车票", "春运", "京津冀"].each do |item|
    tag[item] = "traffic"
end

["台风", "暴雨", "雾霾", "防汛", "寒潮", "预警"].each do |item|
    tag[item] = "weather"
end

["百度地图", "高德地图", "杨洋"].each do |item|
    tag[item] = "others"
end


tag_name = ["accident", "traffic", "weather", "others"]


file_hash = Hash.new
file_hash = {"accident" => $accident, "traffic" => $traffic, "weather" => $weather, "others" => $others}

file_new_hash = Hash.new
file_new_hash = {"accident" => $accident_new, "traffic" => $traffic_new, "weather" => $weather_new, "others" => $others_new}

array_hash = Hash.new
array_hash = {"accident" => $arr_accident, "traffic" => $arr_traffic, "weather" => $arr_weather, "others" => $arr_others}


for name in tag_name
    array_hash[name] = Array.new
    if File.exist?("#{file_path}/#{day}_#{name}")
        array_hash[name] = IO.readlines("#{file_path}/#{day}_#{name}")
    end
    file_hash[name] = File.open("#{file_path}/#{day}_#{name}","w+:gbk")
    file_new_hash[name] = File.open("#{file_path}/#{day}_#{name}_new","w+:gbk")
end



file = File.open("#{file_path}/#{day}", "r:gbk")
arr_now = file.readlines
arr_new = arr_now.drop(countlines)

p "now: #{arr_now.size} lines."
p "new: #{arr_new.size} lines."


p "classification starts..."

arr_new.each do |line|
    has_written = Hash.new
    has_written = {"accident" => false, "traffic" => false, "weather" => false, "others" => false}
    line = Iconv.iconv("GBK//IGNORE", "GBK", line)[0]
    tag.each do |key, value|
        if line.include? "#{key}" and has_written[value] == false 
            file_hash[value].puts("#{line}")
            file_new_hash[value].puts("#{line}")
            has_written[value] = true
        end
    end
    has_written.clear
end

for name in tag_name
    array_hash[name].each do |line|
        line = Iconv.iconv("GBK//IGNORE", "GBK", line)[0]
        file_hash[name].puts("#{line}")
    end
end


file_hash.each_value do |value|
    value.close
end 

file_new_hash.each_value do |value|
    value.close
end 
p "classification ends."



p "sending email starts..."

res = system("cp html_head.html #{t1}.html")
if (!res)
    print "html_head.html dosen't exist."
end

email = File.open("#{t1}.html", "a+")



flag = false

#news
for name in tag_name
    if File.exist?("#{file_path}/#{day}_#{name}_new") && File.size("#{file_path}/#{day}_#{name}_new") > 0
        flag = true
        file = File.open("#{file_path}/#{day}_#{name}_new", "r")
        email.puts("<h3 align=\"center\">#{day}_#{name}</h3>\n")
        email.puts("<table align=\"center\" border=\"1\" cellpadding=\"0\" cellspacing=\"0\" width=\"90%\" style=\"border-collapse\: collapse;\">\n")
        email.puts("<tr><th>title</th><th>released-time</th><th>grabbed-time</th></tr>\n")

        while line = file.gets
            line = line.chomp
            arr = line.split("\t")
            email.puts("<tr>\n")
            for i in 1 ... arr.length
                if i == 1
                    #email.puts(Iconv.iconv("UTF-8//IGNORE", "GBK","<td><a target='_blank' href='#{arr[0]}'>#{arr[i]}</a></td>\n")[0])
                    email.puts("<td><a target='_blank' href='#{arr[0]}'>#{arr[i]}</a></td>\n")
                else
                    #email.puts(Iconv.iconv("UTF-8//IGNORE", "GBK","<td>#{arr[i]}</td>\n")[0])
                    email.puts("<td>#{arr[i]}</td>\n")
                end
            end
            email.puts("</tr>\n")
        end
        email.puts("</table><br />\n")
    end
end

#weibo
for name in tag_name
    if File.exist?("../../../weibo/output/#{name}_cut") && File.size("../../../weibo/output/#{name}_cut") > 0
        flag = true
        file = File.open("../../../weibo/output/#{name}_cut", "r")
        email.puts("<h3 align=\"center\">#{day}_weibo_#{name}</h3>\n")
        email.puts("<table align=\"center\" border=\"1\" cellpadding=\"0\" cellspacing=\"0\" width=\"90%\" style=\"border-collapse\: collapse;\">\n")
        email.puts("<tr><th>title</th><th>released-time</th><th>grabbed-time</th></tr>\n")

        while line = file.gets
            line = line.chomp
            arr = line.split("\t")
            email.puts("<tr>\n")
            for i in 1 ... arr.length
                if i > 4
                    break
                end
                if i == 1
                    email.puts(Iconv.iconv("GBK//IGNORE", "UTF-8","<td><a target='_blank' href='#{arr[0]}'>#{arr[i]}</a></td>\n")[0])
                    #email.puts("<td><a target='_blank' href='#{arr[0]}'>#{arr[i]}</a></td>\n")
                else
                    email.puts(Iconv.iconv("GBK//IGNORE", "UTF-8","<td>#{arr[i]}</td>\n")[0])
                    #email.puts("<td>#{arr[i]}</td>\n")
                end
            end
            email.puts("</tr>\n")
        end
        email.puts("</table><br />\n")
    end
end

email.close

res = system("cat html_tail.html >> #{t1}.html")
if (!res)
    print "false on catenate html_tail.html."
end

if (flag)
    res = system("cat #{t1}.html | mutt -e 'set content_type=\"text/html\"' -e 'set charset=\"gbk\"' -e 'my_hdr from:WangRuishan@baidu.com' -s \"hot news\" \"map-hotspot@baidu.com;wangruishan@baidu.com\"")
    if (!res)
        print "false on sending email."
    end
end

p "sending email ends."

sleep 10
system("rm -f #{t1}.html")
system("rm -f 1067_387*")
system("rm -rf output/1067/387*")
