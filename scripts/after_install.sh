#!/bin/bash
set -e

# ============================================================
# デプロイ後処理
# ============================================================

LARAVEL_ROOT="/var/www/laravel"

# --- composer install（vendor ディレクトリを構築）---
if [ -f "${LARAVEL_ROOT}/composer.json" ]; then
    composer install \
        --working-dir="${LARAVEL_ROOT}" \
        --no-dev \
        --no-interaction \
        --optimize-autoloader \
        --no-progress
fi

# --- .env がなければ .env.example からコピー ---
if [ ! -f "${LARAVEL_ROOT}/.env" ]; then
    cp "${LARAVEL_ROOT}/.env.example" "${LARAVEL_ROOT}/.env"
fi

# --- アプリケーションの初期化---
if [ -f "${LARAVEL_ROOT}/artisan" ]; then
    php "${LARAVEL_ROOT}/artisan" migrate --force
    php "${LARAVEL_ROOT}/artisan" key:generate --force
fi

# --- オーナー・パーミッション設定 ---
chown -R nginx:nginx "${LARAVEL_ROOT}"
find "${LARAVEL_ROOT}" -type f -exec chmod 644 {} \;
find "${LARAVEL_ROOT}" -type d -exec chmod 755 {} \;

# storage と bootstrap/cache は書き込み可能にする
chmod -R 775 "${LARAVEL_ROOT}/storage"
chmod -R 775 "${LARAVEL_ROOT}/bootstrap/cache"

# --- nginx 再起動（設定反映）---
systemctl restart nginx

# --- PHP-FPM 再起動（コード変更を反映）---
systemctl restart php-fpm

# --- Laravel キャッシュクリア ---
if [ -f "${LARAVEL_ROOT}/artisan" ]; then
    php "${LARAVEL_ROOT}/artisan" config:cache
    php "${LARAVEL_ROOT}/artisan" route:cache
    php "${LARAVEL_ROOT}/artisan" view:cache
fi