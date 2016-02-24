#!/bin/bash
function coloredEcho(){
    local exp=$1;
    local color=$2;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput setaf $color;
    echo $exp;
    tput sgr0;
}

###############################################################################
#  ______   ______   ______   ______  ______  ______   __    __   ______
# /\  ___\ /\  == \ /\  __ \ /\  ___\/\__  _\/\  ___\ /\ "-./  \ /\  ___\
# \ \ \____\ \  __< \ \  __ \\ \  __\\/_/\ \/\ \ \____\ \ \-./\ \\ \___  \
#  \ \_____\\ \_\ \_\\ \_\ \_\\ \_\     \ \_\ \ \_____\\ \_\ \ \_\\/\_____\
#   \/_____/ \/_/ /_/ \/_/\/_/ \/_/      \/_/  \/_____/ \/_/  \/_/ \/_____/
#
# Installer Script v0.1.0
# By Hite Billes (hitebilles.com)
#
###############################################################################

mkdir -p tmp

echo ''
coloredEcho "Do you accept Craft's license? [http://buildwithcraft.com/license]"
read -p "[y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo ''

echo ''
coloredEcho 'Downloading and installing the latest version of Craft...' green
echo ''

curl -L http://buildwithcraft.com/latest.zip?accept_license=yes -o tmp/Craft.zip
unzip tmp/Craft.zip
rm -rf tmp

permLevel=774
chmod $permLevel craft/app
chmod $permLevel craft/config
chmod $permLevel craft/storage
echo ''
coloredEcho "  chmod $permLevel craft/app" magenta
coloredEcho "  chmod $permLevel craft/config" magenta
coloredEcho "  chmod $permLevel craft/storage" magenta

echo ''
coloredEcho 'Downloading and craft-browserify-template...' green
echo ''

git clone git@bitbucket.org:hbilles/craft-browserify-template.git

templateDir=craft-browserify-template
cp -rp $templateDir/src ./src
cp -rp $templateDir/ui ./public
rm -rf craft/templates
cp -rp $templateDir/templates ./craft
rm -rf ./public/htaccess
rm -rf ./public/web.config
mv $templateDir/htaccess ./public/.htaccess
mv $templateDir/gitignore .gitignore

mkdir _database
mkdir _database/dump

coloredEcho "  mv $templateDir/src ./src" magenta
coloredEcho "  mv $templateDir/ui ./public" magenta
coloredEcho "  mv $templateDir/templates ./craft" magenta
coloredEcho "  mv $templateDir/htaccess ./public/.htaccess" magenta
coloredEcho "  mv $templateDir/gitignore .gitignore" magenta
coloredEcho "  mkdir _database" magenta
coloredEcho "  mkdir _database/dump" magenta

mv $templateDir/dbPullProduction.sh dbPullProduction.sh
mv $templateDir/dbPullStaging.sh dbPullStaging.sh
mv $templateDir/dbPushStaging.sh dbPushStaging.sh
chmod +x dbPullProduction.sh
chmod +x dbPullStaging.sh
chmod +x dbPushStaging.sh

echo ''
coloredEcho "  mv $templateDir/dbPullProduction.sh dbPullProduction.sh" magenta
coloredEcho "  mv $templateDir/dbPullStaging.sh dbPullStaging.sh" magenta
coloredEcho "  mv $templateDir/dbPushStaging.sh dbPushStaging.sh" magenta
echo ''
coloredEcho "  chmod +x dbPullProduction.sh" magenta
coloredEcho "  chmod +x dbPullStaging.sh" magenta
coloredEcho "  chmod +x dbPushStaging.sh" magenta

echo ''
echo '------------------'
echo ''
coloredEcho 'NOTE:' red
coloredEcho 'Setting craft/app, craft/config, and craft/storage permissions to be 774; change to your desired permission set.' red
echo ''
coloredEcho 'See the docs for your options: http://buildwithcraft.com/docs/installing' red

echo ''
coloredEcho "What is the name of this website? (normal name with spaces and capitalization)"
read siteName

echo ''
coloredEcho "What is the root domain name of this website? (no TLD extension)"
read domainName

echo ''
coloredEcho "What is the TLD for the production website? (com, org, edu, ...)"
read productionTLD

echo ''
coloredEcho "What is the staging domain for this website? (e.g., line58.com)"
read stagingDomain

echo ''
echo '------------------'
echo ''

coloredEcho "Writing package.json using provided settings..." green
sed "s/\<\%\= domainName \%\>/$domainName/g" <$templateDir/_package.json >package.json
sed -i '' "s/\<\%\= siteName \%\>/$siteName/g" package.json

coloredEcho "Writing gulpfile.js using provided settings..." green
sed "s/\<\%\= domainName \%\>/$domainName/g" $templateDir/_gulpfile.js >gulpfile.js

coloredEcho "Writing Craft general.php config using provided settings..." green
rm -rf craft/config/general.php
sed "s/\<\%\= domainName \%\>/$domainName/g" <$templateDir/_general.php >craft/config/general.php
sed -i '' "s/\<\%\= stagingDomain \%\>/$stagingDomain/g" craft/config/general.php
sed -i '' "s/\<\%\= productionTLD \%\>/$productionTLD/g" craft/config/general.php

coloredEcho "Writing Craft db.php config using provided settings..." green
rm -rf craft/config/db.php
sed "s/\<\%\= domainName \%\>/$domainName/g" <$templateDir/_db.php >craft/config/db.php
sed -i '' "s/\<\%\= stagingDomain \%\>/$stagingDomain/g" craft/config/db.php
sed -i '' "s/\<\%\= productionTLD \%\>/$productionTLD/g" craft/config/db.php

coloredEcho "Cleaning up..." green
rm -rf craft-browserify-template

echo ''
echo '------------------'
echo ''

coloredEcho 'Next steps:' white
coloredEcho ' - Create a database with charset `utf8` and collation `utf8_unicode_ci`' magenta
coloredEcho ' - Update craft/config/db.php with your database credentials' magenta
coloredEcho " - Run the installer at $domainName.dev/admin" magenta
coloredEcho '' magenta
coloredEcho 'Happy Crafting!' white