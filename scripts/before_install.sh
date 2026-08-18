#!/bin/bash
# デプロイ前処理：既存ファイルのバックアップ・クリーンアップ

# /var/www/laravel 以下の既存コンテンツを削除（必要に応じてコメントアウト）
rm -rf /var/www/laravel
