# Rails 8 + Tailwind CSS + DaisyUI テンプレート

Rails 8、Tailwind CSS v4、DaisyUI を導入済みのテンプレートです。

新しい Rails アプリを作成する際の初期構築を省略することを目的としています。

## 使用技術

* Ruby
* Rails 8
* Tailwind CSS v4
* DaisyUI
* SQLite3
* Node.js
* mise

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/GoneTarou/rails-template.git railsTemplate
```

```bash
cd railsTemplate
```

## mise の設定を信頼

このテンプレートは mise.toml を使用しています

```bash
mise trust
```

### 2. Ruby と Node.js をインストール

`mise.toml` に記載されたバージョンをインストールします。

```bash
mise install
```

### 3. Gem をインストール

```bash
bundle install
```

```bash
bundle update
```

### 4. npm パッケージをインストール

```bash
npm install
```

### 5. データベースを作成

```bash
bin/rails db:prepare
```

### 6. アプリケーションを起動

```bash
bin/dev
```

ブラウザで以下にアクセスします。

```text
http://localhost:3000
```

## DaisyUI の動作確認

以下のコードを任意のビューに記述してください。

```erb
<button class="btn btn-primary">
  DaisyUI Test
</button>
```

ボタンがスタイリングされて表示されれば正常に動作しています。

## Tailwind CSS の動作確認

以下のコードを任意のビューに記述してください。

```erb
<h1 class="text-6xl font-bold text-red-500">
  Tailwind OK
</h1>
```

文字が大きく赤色で表示されれば正常です。

## ディレクトリ構成

```text
app/
├── controllers/
├── models/
├── views/
├── helpers/
└── assets/
```

## 8. GitHub リポジトリを作成

テンプレートから作成したアプリは、最初はテンプレートリポジトリを参照しています。

新しい GitHub リポジトリを作成し、リモートリポジトリを変更してください。

### 現在のリモートリポジトリを確認

```bash
git remote -v
```

### GitHubで新しいリポジトリを作成

GitHub上で任意の名前のリポジトリを作成します。

例:

```text
my-app
```

### リモートリポジトリを変更

```bash
git remote remove origin
git remote add origin https://github.com/<ユーザー名>/<リポジトリ名>.git
```

### リモートリポジトリを確認

```bash
git remote -v
```

### GitHubへプッシュ

```bash
git push -u origin main
```
