data_ids = data_bag('users')

data_ids.each do |id|
  item = data_bag_item('users',id)

  item['groups'].each do |g|
    group g['name'] do
      gid g['gid']
      action :create
    end
  end

  item['users'].each do |u|
    user u['name'] do
      home  u['home']
      shell u['shell']
      password u['password']
      uid   u['uid']
      gid   u['gid']
      supports :manage_home => true
      action :create
    end
  end

end

