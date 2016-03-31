yum_repository 'remi-php56' do
  description 'for php 5.6'
  mirrorlist 'http://rpms.remirepo.net/enterprise/6/php56/mirror'
  gpgkey 'http://rpms.famillecollet.com/enterprise/remi.repo'
  action :create
end
