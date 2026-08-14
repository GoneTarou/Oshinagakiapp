# 即売会巡回リスト共有Webアプリ

同人即売会の一般参加者が、買いたいサークルの巡回リストを作成し、Xで共有・閲覧するためのWebアプリです。

## 技術構成

- Ruby 3.4
- Ruby on Rails 8.1
- CSS：Tailwind CSS
- UIコンポーネント：daisyUI

## 開発環境の起動

初回セットアップ：

```bash
bin/setup
bin/rails db:seed
```

開発サーバーの起動：

```bash
bin/dev
```

## ドキュメント

- [アプリ仕様](docs/specification.md)
- [デザインルール](docs/design.md)
- [データベース構成](mermaid.md)
