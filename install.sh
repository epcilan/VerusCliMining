#!/bin/sh

# Обновление и установка необходимых пакетов (без sudo)
apt-get -y update && apt-get -y upgrade
apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget || echo "Ошибка: некоторые пакеты не установлены!"

# Создаем папку для майнера в доступной директории
mkdir -p ~/ccminer
cd ~/ccminer || exit

# Получаем последнюю версию майнера через API GitHub
GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/pangz-lab/verus_miner-release/releases/latest")

# Извлекаем URL для загрузки
GITHUB_DOWNLOAD_URL=$(echo "$GITHUB_RELEASE_JSON" | jq -r '.assets[0].browser_download_url')
GITHUB_DOWNLOAD_NAME=$(echo "$GITHUB_RELEASE_JSON" | jq -r '.assets[0].name')

# Проверяем, получена ли ссылка
if [ -z "$GITHUB_DOWNLOAD_URL" ] || [ "$GITHUB_DOWNLOAD_URL" = "null" ]; then
    echo "Ошибка: Не удалось получить ссылку на майнер."
    exit 1
fi

echo "Скачиваем последнюю версию: $GITHUB_DOWNLOAD_NAME"

# Скачиваем майнер
wget -O ~/ccminer/ccminer "$GITHUB_DOWNLOAD_URL"

# Проверяем, скачался ли файл
if [ ! -f ~/ccminer/ccminer ]; then
    echo "Ошибка: Файл майнера не скачался!"
    exit 1
fi

# Скачиваем конфигурацию
wget -O ~/ccminer/config_luckpool.json "https://raw.githubusercontent.com/epcilan/VerusCliMining/main/config_luckpool.json"

# Даем права на выполнение
chmod +x ~/ccminer/ccminer

# Создаем стартовый скрипт
cat << EOF > ~/ccminer/start.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config_luckpool.json
EOF

chmod +x ~/ccminer/start.sh

echo "✅ Установка завершена!"
echo "Редактируйте конфиг с помощью: nano ~/ccminer/config_luckpool.json"
echo "Измените имя воркера на строке 15."
echo "Для запуска майнера используйте:"
echo "cd ~/ccminer && ./start.sh"
