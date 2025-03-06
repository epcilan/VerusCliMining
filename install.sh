#!/bin/sh
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget

# Устанавливаем libssl1.1
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb

# Создаем папку для майнера
mkdir -p ~/ccminer
cd ~/ccminer

# Загружаем JSON с релизами
GITHUB_RELEASE_JSON=$(curl --silent "https://raw.githubusercontent.com/epcilan/VerusCliMining/main/verus_miner_config.json")

# Получаем URL для загрузки
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r '.assets[0].browser_download_url')
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r '.assets[0].name')

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

# Скачиваем майнер
wget ${GITHUB_DOWNLOAD_URL} -O ~/ccminer/ccminer

# Скачиваем конфигурацию
wget https://raw.githubusercontent.com/epcilan/VerusCliMining/main/config_luckpool.json -O ~/ccminer/config_luckpool.json

# Даем права на выполнение
chmod +x ~/ccminer/ccminer

# Создаем стартовый скрипт
cat << EOF > ~/ccminer/start2.sh
#!/bin/sh
~/ccminer/ccminer -c ~/ccminer/config_luckpool.json
EOF

chmod +x ~/ccminer/start2.sh

echo "Setup nearly complete."
echo "Edit the config with \"nano ~/ccminer/config_luckpool.json\""
echo "Go to line 15 and change your worker name."
echo "Use \"CTRL-X\" to exit, press \"Y\" to save, and \"Enter\" to confirm."
echo "Start the miner with: cd ~/ccminer && ./start2.sh"
