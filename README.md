### MacにインストールしたchefでvagrantのVMを管理する

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
rubyで書かれたサーバの状態をテストするテストフレームワーク

- インストール
```
$ sudo gem install serverspec
```

- serverspecの初期化
`$ serverspec-init`

```
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

```


- serverspecを実行する
```
# rake spec
```
