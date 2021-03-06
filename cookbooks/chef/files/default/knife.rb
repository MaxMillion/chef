node_name 'chef-git'
client_key 'client.pem'
validation_client_name 'chef-validator'
validation_key '/etc/chef/validation.pem'
chef_server_url 'https://chef.openstreetmap.org'
cache_type 'BasicFile'
cache_options( :path => '.chef/checksums' )
cookbook_path [ 'cookbooks' ]
cookbook_copyright 'OpenStreetMap Administrators'
cookbook_email 'admins@openstreetmap.org'
cookbook_license 'apachev2'
