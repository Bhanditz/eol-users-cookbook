use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def initialize(*args)
  super
  @action = :create
end

def chef_solo_search_installed?
  klass = ::Search.const_get("Helper")
  return klass.is_a?(Class)
rescue NameError
  return false
end

action :remove do
  if Chef::Config[:solo] && !chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. Chef Solo does not support "\
                   "search unless you install the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag,
           "action:remove AND NOT id:groups") do |rm_user|
      user rm_user["username"] ||= rm_user["id"] do
        action :remove
      end
    end
  end
end

action :create do
  security_group = []

  if Chef::Config[:solo] && !chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. "\
                   "Chef Solo does not support search unless you install "\
                   "the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag,
           "name:#{new_resource.search_group} "\
           "AND NOT action:remove") do |u|
      u["username"] ||= u["id"]
      group = u["groups"].select do |g|
        g["name"] == new_resource.search_group
      end
      nodes = group.first["nodes"]
      if nodes == [] || nodes.include?(node.name)
        security_group << u["username"]
      end
      # Set home_basedir based on platform_family
      case node["platform_family"]
      when "mac_os_x"
        home_basedir = "/Users"
      when "debian", "rhel", "fedora", "arch", "suse", "freebsd"
        home_basedir = "/home"
      end

      # Set home to location in data bag,
      # or a reasonable default ($home_basedir/$user).
      if u["home"]
        home_dir = u["home"]
      else
        home_dir = "#{home_basedir}/#{u['username']}"
      end

      # The user block will fail if the group does not yet exist.
      # See the -g option limitations in man 8 useradd for an explanation.
      # This should correct that without breaking functionality.
      group u["username"] do
        gid u["gid"]
        only_if { u["gid"] && u["gid"].is_a?(Numeric) }
      end

      # Create user object.
      # Do NOT try to manage null home directories.
      user u["username"] do
        uid u["uid"]
        gid u["gid"] if u["gid"]
        shell u["shell"]
        comment u["comment"]
        password u["password"] if u["password"]
        if home_dir == "/dev/null"
          supports manage_home: false
        else
          supports manage_home: true
        end
        home home_dir
        action u["action"] if u["action"]
      end

      if home_dir != "/dev/null"
        converge_by("would create #{home_dir}/.ssh") do
          directory "#{home_dir}/.ssh" do
            owner u["username"]
            group u["gid"] || u["username"]
            mode "0700"
          end
        end

        template "#{home_dir}/.ssh/authorized_keys" do
          source "authorized_keys.erb"
          cookbook new_resource.cookbook
          owner u["username"]
          group u["gid"] || u["username"]
          mode "0600"
          variables ssh_keys: u["ssh_keys"]
          only_if { u["ssh_keys"] }
        end

        if u["ssh_private_key"]
          key_type = "dsa"
          if u["ssh_private_key"].include?("BEGIN RSA PRIVATE KEY")
            key_type = "rsa"
          end
          template "#{home_dir}/.ssh/id_#{key_type}" do
            source "private_key.erb"
            cookbook new_resource.cookbook
            owner u["id"]
            group u["gid"] || u["id"]
            mode "0400"
            variables private_key: u["ssh_private_key"]
          end
        end

        if u["ssh_public_key"]
          key_type = u["ssh_public_key"].include?("ssh-rsa") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}.pub" do
            source "public_key.pub.erb"
            cookbook new_resource.cookbook
            owner u["id"]
            group u["gid"] || u["id"]
            mode "0400"
            variables public_key: u["ssh_public_key"]
          end
        end
      end
    end
  end

  group new_resource.group_name do
    gid new_resource.group_id if new_resource.group_id
    members security_group
  end
end
