yum_repository 'remi' do
  description 'Les RPM de Remi - Repository'
  baseurl 'http://rpms.famillecollet.com/enterprise/6/remi/x86_64/'
  gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
  fastestmirror_enabled true
  action :create
end

yum_repository 'remi-php56' do
  description 'for php 5.6'
  mirrorlist 'http://rpms.remirepo.net/enterprise/6/php56/mirror'
  gpgkey 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi'
  action :create
end
