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

- not if
  - 指定した条件が真でないなら実行
  `* yum_package[httpd] action install (skipped due to not_if)`
