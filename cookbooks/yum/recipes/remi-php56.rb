yum_repository 'remi-php56' do
  description 'for php 5.6'
  mirrorlist 'http://rpms.remirepo.net/enterprise/$releasever/php56/mirror'
  gpgkey 'http://rpms.remirepo.net/RPM-GPG-KEY-remi'
  action :create
end
