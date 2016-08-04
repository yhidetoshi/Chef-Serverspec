node_name "localhost"

base = File.expand_path('..', __FILE__)

nodes_path                File.join(base, 'nodes')
role_path                 File.join(base, 'roles')
data_bag_path             File.join(base, 'data_bags')
encrypted_data_bag_secret File.join(base, 'data_bag_key')
environment_path          File.join(base, 'environments')
environment               "_default"
ssl_verify_mode           :verify_peer

cookbook_path []
cookbook_path << File.join(base, 'cookbooks-1') # /root/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/knife-solo-0.6.0/lib/knife-solo/resources/patch_cookbooks
cookbook_path << File.join(base, 'cookbooks-2') # /root/.berkshelf/knife-solo/400cc40db62be5cff3202663cbafad99851ce1d3
cookbook_path << File.join(base, 'cookbooks-3') # /root/chef-solo/cookbooks

