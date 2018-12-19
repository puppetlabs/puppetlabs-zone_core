# zone

#### 目次

1. [説明](#description)
2. [セットアップ - zoneモジュール導入の基本](#setup)
    * [セットアップ要件](#setup-requirements)
3. [使用 - 設定オプションと追加機能](#usage)
4. [参考 - モジュールの機能と動作について](#reference)
5. [制約 - OS互換性など](#limitations)
6. [開発 - モジュール貢献についてのガイド](#development)

<a id="description"></a>
## 説明

zone_coreモジュールは、Solarisゾーンリソースの管理に使用されます。

<a id="setup"></a>
## セットアップ

<a id="setup-requirements"></a>
### セットアップ要件

zone_coreモジュールはzfs_coreモジュールに依存します。これは、ゾーンがzfsリソースプールに関連していることがあるためです。

<a id="usage"></a>
## 使用

`running`ステートおよび`/tstzones/mnt`のゾーンファイルシステムのルートで`tstzone`という名前のゾーンリソースを作成するには 、以下のコードを使用します。

```
zone { 'tstzone' :
  ensure => running,
  path   => '/tstzones/mnt'
}
```

<a id="reference"></a>
## リファレンス

リファレンス文書については、REFERENCE.mdを参照してください。

このモジュールは、Puppet Stringsを用いて文書化されています。

Stringsの仕組みの簡単な概要については、Puppet Stringsに関する[こちらのブログ記事](https://puppet.com/blog/using-puppet-strings-generate-great-documentation-puppet-modules)または[README.md](https://github.com/puppetlabs/puppet-strings/blob/master/README.md)を参照してください。

文書をローカルで作成するには、以下のコマンドを実行します。

```
bundle install
bundle exec puppet strings generate ./lib/**/*.rb
```

このコマンドにより、閲覧可能な`\_index.html`ファイルが`doc`ディレクトリに作成されます。ここで利用可能なリファレンスはすべて、コードベースに埋め込まれたYARD形式のコメントから生成されます。このモジュールに関して何らかの開発をする場合は、影響を受ける文書も更新する必要があります。

<a id="limitations"></a>
## 制約

このモジュールは、Solarisプラットフォームでのみ使用できます。

<a id="development"></a>
## 開発

Puppet ForgeのPuppet Labsモジュールは、オープンプロジェクトです。プロジェクトをさらに発展させるには、コミュニティへの貢献が不可欠です。Puppetが役立つ可能性のある膨大な数のプラットフォーム、無数のハードウェア、ソフトウェア、デプロイメント構成に我々がアクセスすることはできません。

弊社は、できるだけ変更に貢献しやすくして、弊社のモジュールがユーザの環境で機能する状態を維持したいと考えています。弊社では、状況を把握できるよう、貢献者に従っていただくべきいくつかのガイドラインを設けています。

詳細については、[モジュール貢献ガイド](https://docs.puppetlabs.com/forge/contributing.html)を参照してください。
