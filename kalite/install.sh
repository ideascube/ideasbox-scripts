URL=https://github.com/learningequality/ka-lite
ROOT=/home/ideasbox/Scripts/ka-lite
CURRENT=$PWD

# Clone repository
if [ ! -d "$ROOT" ]
then
    echo "Cloning $URL"
    git clone $URL $ROOT
fi

cd $ROOT
./setup_unix.sh

# Install Nginx vhost
cd $CURRENT
sudo cp kalite/nginx.vhost /etc/nginx/sites-available/kalite
sudo ln -fs /etc/nginx/sites-available/kalite /etc/nginx/sites-enabled/kalite
sudo service nginx restart

