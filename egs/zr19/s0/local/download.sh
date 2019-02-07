mkdir -p shared/databases
wget https://download.zerospeech.com/2019/english.tgz
tar xvfz english.tgz -C shared/databases
rm -f english.tgz

wget https://download.zerospeech.com/2019/english_small.tgz
tar xvfz english_small.tgz -C shared/databases
rm -f english_small.tgz

wget https://download.zerospeech.com/2019/surprise.zip
unzip -P 9kneopShevtat] surprise.zip -d shared/databases
# enter the password when prompted for
rm -f surprise.zip
