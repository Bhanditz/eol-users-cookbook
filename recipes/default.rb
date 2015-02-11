require "ostruct"

include_recipe("users")

# def create_user(name, data)
#
#   logrotate_app name do
#     cookbook "logrotate"
#
#     options ["missingok", "copytruncate"]
#     path "%s/*.log" % data.path.strip.gsub("/$", "")
#     rotate 20
#     create "0600 root root"
#     size "100k"
#     frequency "daily"
#   end
# end
#
# users = data_bag_item("eol-users-wrapper", "config") rescue {}
#
# users["users"].each do |name, data|
#   data = OpenStruct.new(data)
#   if data.nodes.empty? || data.nodes.include?(node.name)
#     create_user(name, data)
#   end
# end
