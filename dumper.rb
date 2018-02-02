#!/usr/bin/env ruby

require "bundler/setup"
require "elasticsearch"
require "json"
require "getoptlong"

def help()
  puts "Usage : dashboard_dumper.rb [options]"
  puts "Options :"
  puts "  --host : specifies host to connect to. default is localhost"
  puts "  --port : port to connect to. default is 9200"
  puts "  --index : dashboard index name. default is kibana-int"
  puts "  --output-dir : output directory. default is './dashboards'"
  puts "  --user : username. default is foo"
  puts "  --password : password. default is bar"
  puts "  --help : this help"

  exit 0
end

opts = GetoptLong.new(
  [ "--host", "-H", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--port", "-p", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--index", "-i", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--output-dir", "-o", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--user", "-u", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--password", "-W", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--help", "-h", GetoptLong::NO_ARGUMENT ]
)

host = "localhost"
port = 9200
index = ".kibana"
outputdir = "./kibana"
user = "foo"
password = "bar"

opts.each do |opt, arg|
  case opt
    when "--host"
      host = arg
    when "--port"
      port = arg.to_i
    when "--index"
      index = arg
    when "--output-dir"
      outputdir = arg
    when "--user"
      user = arg
    when "--password"
      password = arg
    when "--help"
      help()
    end
end

Dir::mkdir(outputdir) unless Dir.exists?(outputdir)

client = Elasticsearch::Client.new hosts: [ { host: host, port: port } ]


## Dashboards
  count = client.count(index: index, body: { query: { match: { _type: "dashboard" } }})
  #puts count
  if count.has_key?("count")
    size = count["count"].to_i
    begin
        rslt = client.search(index: index, body: { query: { match: { _type: "dashboard" } }, size: size })
    rescue Exception => e
        puts "An error occured : #{e.message}"
        exit 1
    end
    if rslt.has_key?("hits")
        rslt["hits"]["hits"].each do |dash|
            name = dash["_id"].gsub(" ","_").downcase
            puts name
            File.open(File.join(outputdir, "dash_#{name}.json"), "w") do |fp|
                fp.write(JSON.pretty_generate( dash ))
            end
        end
    end
  end  

## Visualizations
  count = client.count(index: index, body: { query: { match: { _type: "visualization" } }})
  #puts count
  if count.has_key?("count")
    size = count["count"].to_i
    begin
        rslt = client.search(index: index, body: { query: { match: { _type: "visualization" } }, size: size })
    rescue Exception => e
        puts "An error occured : #{e.message}"
        exit 1
    end
    if rslt.has_key?("hits")
        rslt["hits"]["hits"].each do |dash|
            id = dash["_id"].gsub("-","_").downcase
			#title = dash['_source']['title'].gsub("-","_").downcase
            name =  id
			puts name
            File.open(File.join(outputdir, "visual_#{name}.json"), "w") do |fp|
                fp.write(JSON.pretty_generate( dash ))
            end
        end
    end
  end
