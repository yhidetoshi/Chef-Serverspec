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

- **chef-server/clientで(例)httpd.confが着替えられたら再起動する**
```
 template "httpd.conf" do
 28  path "/etc/httpd/conf/httpd.conf"
 29  owner "root"
 30  group "rout"
 31  mode 0644
 32  notifies :reload, 'service[httpd]'
 33 end
```
-> `notifies :reload, 'service[httpd]`:第一引数にアクション、第二引数にリソースタイプを書く
