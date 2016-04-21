### MacにインストールしたchefでvagrantのVMを管理する

![Alt Text](https://github.com/yhidetoshi/Pictures/raw/master/chef_mac/chef-icon.png)

### Vagrantをデプロイする
```
- 対象仮想マシンにChefをインストールする。
$ knife solo bootstrap vagrant@vmdev

- nodesディレクトリ : 
$ Vagrant/Base-OS-Cent/nodes/

- ファイルを作成
$ chef_client2.json

- cookbookの適用
$ knife solo cook root@chef_client2
```

### recipeの書き方メモ

- **ディレクトリリソース(作ったり、パーミッションだったり)**
```
directory '/usr/local/hogehoge/' do
 owner 'vagrant'
 group 'vagrant'
 mode 0755
 action :create
end
```
-> `action :create` : すでに作成済みならスキップする
```
* directory[/usr/local/hogehoge/] action create (up to date)
```

- **not if**
  - 指定した条件が真でないならコマンド実行
  
(実行ログ)`* yum_package[httpd] action install (skipped due to not_if)`

- **only_if**
  - 指定した条件が真の時のみコマンドを実行
 
- **case/when (OSの種類毎に処理を変える)**
```
case node[:platform]
 when 'redhat', 'centos'
   package "httpd" do
     action :install
   not_if 'which httpd'
 end

 when 'debian', 'ubuntu'
   package "apache2" do
    action :install
   not_if 'which apache'
 end

end
```

- **サービスの設定**
```
service "httpd" do
 action [:enable, :start]
 supports :status => true, :restart => true, :reload => true
end
```
-> サービスを起動し、自動起動を登録 : `action [:enable, :start]`
-> supports : `restart = >trueでなければchefはサービスのrestartを[stop + start]で代用するので可能であればrestartをtrueにした方が賢明`

- **Nofication(例)httpd.confが着替えられたら再起動する**
```
 template "httpd.conf" do
   path "/etc/httpd/conf/httpd.conf"
   owner "root"
   group "rout"
   mode 0644
   notifies :reload, 'service[httpd]'
 end
```
-> `notifies :reload, 'service[httpd]`:第一引数にアクション、第二引数にリソースタイプを書く.
-> 実行は一度、キューに入り、実行処理の終盤に行われる.
-> 即座に実行したい場合は`notifies :reload, 'service[httpd] :immediately`(immediatelyをつける)


- **Subscribe**
  - 何かのリソースに変化があった場合にアクションする

-> `subscribe :restart, "template[hoge.conf]"`

- **template**
 - Attributeの値をテンプレート内で展開したい場合に利用する
 - Attributeを一切使いない場合は`cookbook_file`を使って定義する
```
template "/etc/httpd/conf.d/mysite.conf" do
  source "mysite.conf.erb"
  owner	 "root"
  group  "root"
  mode   0644
  action :create
  variables({
	:hostname => `/bin/hostname`.chomp
  })
end
```
 
- **cookbook_fileの利用(静的ファイルを転送)**
 - クックブックに同封したファイルを任意のパスへ転送して配置できる

-> /cookbooks/httpd/files/default/配下に転送したいファイルを設置
```
cookbook_file "/usr/local/hogehoge/test_cookbook_file.txt" do
 mode 755
end
```

- **ifconfigの設定**
```
ifconfig "192.168.30.2" do
 device "eth0"
end
```

- **mount**
```
mount "/mnt/volume1" do
 device "volume1"
 device_type :label
 fstype "xfs"
 options "rw"
end
```
- **script**
 - 冪等性を保証しない。基本的には毎回実行される
  - createを1行書いて、毎回の実行を阻止する方法を取れる 
 -  `create` : すでにファイルがある場合は実行されない 

- *file*
 - `cookbook_file`はノードへ転送
 - `file`はノード上のファイルを扱う
<<<<<<< HEAD
```
file "/usr/local/hogehoge/test_cookbook_file.txt" do
 content "chef test for file"
 owner "root"
 group "root"
 mode 755
 action :create
end
```

- **route ルーティングテーブル**
```
route "10.0.1.10/32" do
 gateway "ipaddress"
 device eth1
end
```


- **Attribute**
 - テンプレートの中で変数が扱える

chef-repo/cookbooks/wordpress/attributes/default.rb
```
default['mysql']['db_name'] = 'hoge'
default['mysql']['user']['name']= 'hogeadmin'
default['mysql']['user']['password'] = 'hogepassword'
```

/chef-repo/cookbooks/wordpress/templates/default/wp-config.php.erb
```
define('DB_NAME', '<%= @db_name %>');
define('DB_USER', '<%= @db_user %>');
```

- **data_bags**
 - chefで管理している各ノードで共通の設定とかを定義する
  - user
  - 鍵情報など暗号化して格納してセキュアに使うこともできる
 
- roleを利用

roles/web.json

-> roleで'web'を作り、`recipe`を追加
```
{
  "name": "web",
  "chef_type": "role",
  "json_class": "Chef::Role",
  "run_list": [
	"recipe[httpd]"
  ]
}
```

cat nodes/chef_client3.json                                                                               
-> 上のroleで作った名前を`role[<role名>]`を書く

```
{
   "run_list": [
        "role[web]"
   ],
   "automatic":{
	"ipaddress": "chef_client3"
    }
}
```

### 外部のcookbookを利用する(opscode)
```
# pwd 
/Vagrant/Base-OS-Cent

# knife cookbook site install selinux
-> cookbooksディレクトリに追加されたので,site-cookbooksに移動
-> これでいつも通りにknifeコマンドを当てればいい
```

(ex)selinuxをOFFにする場合は`"recipe[selinux::disabled]"`とした。


### Vagrantから直接cookbookを適用する(chef自動プロビジョニング)
- vagrant-omnibus のインストール
```
vagrant plugin install vagrant-omnibus
```

Vagrantfile
```
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

 config.vm.define :chef_client1 do |chef_client1|
  chef_client1.vm.box = "Base-OS-Cent"
  config.vm.network "private_network", ip: "192.168.33.10"
 end

 config.vm.define :chef_client2 do |chef_client2|
  chef_client2.vm.box = "Base-OS-Cent"
  config.vm.network "private_network", ip: "192.168.33.11"
 end

 config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./cookbooks"

    chef.run_list = %w[
	recipe[httpd]
    ]
  end
 end
```
- プロビジョニングを実行
```
vagrant up --provision
```

- 随時プロビジョニングを実行
```
vagrant up --provision

```

### Serverspecの利用

![Alt Text](https://github.com/yhidetoshi/Pictures/raw/master/chef_mac/serverspec-icon.png)

rubyで書かれたサーバの状態をテストするテストフレームワーク

(参考) シナリオテストの検証を実施した環境:sakura-vps @CentOS release 6.7 (Final)
-> `spec/localhost/hoge_spec.rb`

- **インストール**
```
$ sudo gem install serverspec
```

- **serverspecの初期化**
```
$ serverspec-init
--- 
Select OS type:
  1) UN*X
  2) Windows
Select number: 1　　←テスト対象サーバのOS種別を選択
Select a backend type:
  1) SSH
  2) Exec (local)
Select number: 1　　←テスト実行のタイプを選択
Vagrant instance y/n: n ←Vagrantの管理下のインスタンスかどうかを選択
Input target host name: server-01 ←テスト対象サーバのホスト名を入力
 + spec/
 + spec/server-01/
 + spec/server-01/httpd_spec.rb
 + spec/spec_helper.rb
 + Rakefile
---

```
- `spec/spec_helper.rb`：Serverspecを使ってテストを実行する際のテスト設定などを記述
- `spec/<target_host>/<test_name>_spec.rb`：テストスクリプト本体. この_spec.rbにテストを書いていく
- デフォルトで下記のsample_spec.rbが置かれている

**[sample_spec.rb]**
```
require 'spec_helper'

describe package('httpd'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('httpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
end

describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

describe service('org.apache.httpd'), :if => os[:family] == 'darwin' do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
```

**[確認したテスト ※()は未検証 ]**
(参考:RESOURCE TYPES)-> http://serverspec.org/resource_types.html#cron

(serverspecではRspec2ではなくRspec3が対応している模様 ※書き方が異なるので注意)

-> http://serverspec.org/changes-of-v2.html

- service
  - should be_enabled
  - should be_running
- package
  - should be_installed
  - should be_installed.with_version('X.X.X')
  - should be_installed.by('gem').with_version('X.X.X')
- port
  - should be_listening
  - should be_listening.with('tcp')
- command
  - :exit_status 
  - :stdout
    - should match
    - should eq
- host
  - should be_reachable  
  - should be_resolvable
- file
  - should be_executable
  - should contain
- default_gateway
  - :interface
  - :ipaddress
- interface
  - should have_ipv4_address 
- selinux
  - should be_disabled
  - shoudl be_enforcing
  - should be_permissive
- 
- (routing_table)
- (monitored_by)

**[_spec.rb]**
```
require 'spec_helper'

# サービスが起動&自動起動設定されているかを確認
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

# packageがインストールされているか確認
describe package('python') do
 it { should be_installed }
end

# gemとして指定のバージョンがインストールされているか確認
describe package('bundler') do
  it { should be_installed.by('gem').with_version('1.11.2') }
end

# インストールしたパッケージのバージョン確認
describe package('nginx') do
  it { should be_installed.with_version('1.8.1')}
end

# ポートがListenしているかを確認
describe port(80) do
  it { should be_listening}
  it { should be_listening.with('tcp') }
end

# コマンドを使って確認
describe command('which perl') do
  its(:exit_status){should eq 0}
end

# dnsの確認
describe command('cat /etc/resolv.conf') do
  its(:stdout) { should match /X.X.X.X/ }
end

# ユーザの確認
describe command('whoami') do
  its(:stdout) { should eq "root\n" }
end

# インストールされているrubyのバージョンを確認
describe command('ruby -v') do
  its(:stdout) { should match /ruby 2\.3\.0p0/ }
end

# リーチャビリティのテスト
describe host('8.8.8.8') do
  it { should be_reachable}
end

# 名前解決のテスト
describe host('www.google.com') do
  it { should be_resolvable}
end

# デフォゲのテスト
describe default_gateway do
  its(:interface) { should eq 'eth0'}
  its(:ipaddress) { should eq 'X.X.X.X'}
end

# 実行可能かテスト
describe file('/etc/init.d/nginx') do
  it { should be_executable}
end

# config設定の確認テスト
describe file('/etc/nginx/conf.d/default.conf') do
  it { should contain 'server_name localhost'}
end

# インターフェースの確認
describe interface('eth0') do
  it { should have_ipv4_address('X.X.X.X') }
end

# selinuxの状態確認
describe selinux do
  it { should be_disabled}
#  it { should be_enforcing }
#  it { should be_permissive }
end

```

- **serverspecを実行する**
```
# rake spec
```


### Wordpressの自動構築のrun_list
nodes/target_host.json
```
{
   "run_list": [
        "recipe[yum::epel]",
        "recipe[yum::remi]",
	"recipe[yum::remi-php56]",
	"recipe[php56::php]",
	"recipe[nginx]",
	"recipe[git::git]",
  	"recipe[mysqld]",
	"recipe[wordpress-built]"
   ],
   "automatic":{
	"ipaddress": "chef_client3"
    }
}
```
各cookbookの役割はコード参照。

### Data_bagsは複数のノードで共有やデータの暗号化などで使う
- ユーザ作成をする。(パスワードはopensslでハッシュ化)
 ->.jsonで定義するカ所のpassword`ハッシュ化`が必要. 平文だと無理だった。

`# knife data bag create users -z` : databagsにuserディレクトリを作成
-> `-z`を使うとオプションで鍵を無視できる。

</data_bags/users/test1.json>
`password:`は『password』を`openssl passwd -1 'password'`でハッシュ化。
```
{
  "id": "test2",
  "groups": [
    {
      "name": "test",
      "gid": 2001
    }
  ],
  "users": [
    {
      "name": "test2",
      "home": "/home/test2",
      "shell": "/bin/bash",
      "password": "$1$23z7JGCv$9dHBNA3FmOLTfb.RAvdgQ.",
      "uid": 2002,
      "gid": 2001
    }
  ]
}
```

[adduser]をcookbookを作成してrecipeに書きを書いた
```
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
```
- suコマンドで確認
```
[vagrant@chef-client2 ~]$ su - test2
Password:
[test2@chef-client2 ~]$
```
