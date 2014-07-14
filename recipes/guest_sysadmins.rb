#
# Cookbook Name:: eol-users-wrapper
# Recipe:: default
#

include_recipe('users::sysadmins')

users_manage "guest_sysadmin" do
  data_bag "guest_users"
  group_name "sysadmin"
  action [:create]
  group_id 2300
end
