groups = data_bag_item("eol-users", "groups")

exit unless groups

groups["groups"].each do |group|
  eol_users_manage group["group_name"] do
    group_id group["group_id"] if group["group_id"]
    action group["action"] || [:remove, :create]
  end
end
