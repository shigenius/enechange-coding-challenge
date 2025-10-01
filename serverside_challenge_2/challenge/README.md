# これは
電気料金のシミュレーションを行えるサービスです。

# 構成
- Back-end
    - Ruby 3.1.2, Ruby on Rails 7.0.8
- DB
    - PostgreSQL
- Front-end
    - erb, Stimulus, CSS
- Asset
    - importmap, propshaft
- Test
    - Rspec, FactoryBot, Shoulda Matchers
- Dev
    - annotate gem

# 開発環境
## railsサーバー起動
```sh
docker compose up -d
```

## データベース作成
```sh
docker compose run -it web rails db:create
```

## データベース初期化、データ作成
```sh
docker compose run -it web rails db:reset
```

## rspec実行
```sh
docker compose run -it web rspec
```

## 電気料金のシミュレーション

http://localhost:3000/plans にアクセス
