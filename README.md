eol-users Cookbook
==============
Creates nodes' specific users from databag configuration file


Requirements
------------
### Platforms
- Debian, Ubuntu
- CentOS, Red Hat, Fedora
- FreeBSD

A data bag populated with user objects must exist. The default data
bag in this recipe is `eol-users`. See USAGE.


Usage
-----

To configure your users add following to your cookbook:

```ruby
include_recipe "eol-users"
```

Use knife to create a data bag for eol-users.

```bash
$ knife data bag create eol-users
```
Create groups configuration in data_bag/eol-users/groups.json

(Only groups mentioned in this file will be created and configured)

``` javascript
{
  "id": "groups",
  "groups": [
    { 
      "group_name": "sysadmin",
      "group_id": 2300,
      "group_action": ["remove", "create"]
    },
    {
      "group_name": "docker",
      "group_id": 2331,
      "group_action": ["remove", "create"]
    },
    {
      "group_name": "dba",
      "group_id": 2332,
      "group_action": ["remove", "create"]
    }
  ]
}
```

Create a user in the data_bag/eol-users/ directory.

The main difference from users cookbook data bags -- for every user groups
you have to include not only groups name, but also nodes where this group
should be installed for a particular user. For example:

```javascript```
{
  "groups": [ { "name": "sysadmin", "nodes":[] },
              { "name": "docker", "nodes": ["docker1","docker2"] },
              { "name": "dba", "nodes": ["mariadb1"] } ]
}
```

When using an [Omnibus ruby](http://tickets.opscode.com/browse/CHEF-2848), 
one can specify an optional password hash. This will be used as the 
user's password.

The hash can be generated with the following command.

```bash
$ openssl passwd -1 "plaintextpassword"
```

Note: The ssh_keys attribute below can be either a String or an Array. 
However, we are recommending the use of an Array.

```javascript
{
  "id": "bofh",
  "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== bofh",
}
```

```javascript
{
  "id": "bofh",
  "password": "$1$d...HgH0",
  "ssh_keys": [
    "ssh-rsa AAA123...xyz== foo",
    "ssh-rsa AAA456...uvw== bar"
  ],
  "groups": [ { "name": "sysadmin", "nodes":[] },
              { "name": "docker", "nodes": ["docker1","docker2"] },
              { "name": "dba", "nodes": ["mariadb1"] } ],
  "uid": 2001,
  "shell": "\/bin\/bash",
  "comment": "BOFH",
  "nagios": {
    "pager": "8005551212@txt.att.net",
    "email": "bofh@example.com"
  },
  "openid": "bofh.myopenid.com"
}
```

You can pass any action listed in the 
[user](http://docs.opscode.com/chef/resources.html#id237) 
resource for Chef via the "action" option. For Example:

Lock a user, johndoe1.

```bash
$ knife data bag edit users johndoe1
```

And then change the action to "lock":

```javascript
{
  "id": "johndoe1",
  "groups": [ { "name": "sysadmin", "nodes":[] },
              { "name": "docker", "nodes": ["docker1","docker2"] },
              { "name": "dba", "nodes": ["mariadb1"] } ],
  "uid": 2002,
  "action": "lock", // <--
  "comment": "User violated access policy"
}
```

Remove a user, johndoe1.

```bash
$ knife data bag edit users johndoe1
```

And then change the action to "remove":

```javascript
{
  "id": "johndoe1",
  "groups": [ { "name": "sysadmin", "nodes":[] },
              { "name": "docker", "nodes": ["docker1","docker2"] },
              { "name": "dba", "nodes": ["mariadb1"] } ],
  "uid": 2002,
  "action": "remove", // <--
  "comment": "User quit, retired, or fired."
}
```

The latest version of knife supports reading data bags from a file
and automatically looks in a directory called +data_bags+ in the
current directory. The "bag" should be a directory with JSON files
of each item. For the above:

```bash
$ mkdir data_bags/users
$EDITOR data_bags/users/bofh.json
```

Paste the user's public SSH key into the ssh_keys value. Also make
sure the uid is unique, and if you're not using bash, that the shell
is installed. The default search, and Unix group is sysadmin.

The recipe, can also create the sysadmin group for users. If
you're using the opscode sudo cookbook, they'll have sudo access in
the default site-cookbooks template. They won't have passwords though,
so the sudo cookbook's template needs to be adjusted so the sysadmin
group has NOPASSWD.

The sysadmin group will be created with GID 2300. This may become an
attribute at a later date.

License & Authors
-----------------
- Author:: [Dmitry Mozzherin][1]
The code was heavily borrowed from [opscode/users cookbook][2]

```text
Copyright:: 2015, Marine Biological Laboratory

Licensed under the [MIT License][2]

[1]: https://github.com/dimus
[2]: https://github.com/opscode-cookbooks/users
[3]: https://github.com/EOL/eol-users-cookbook/blob/master/LICENSE
