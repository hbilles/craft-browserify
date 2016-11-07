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
mkdir dist dist/public
cp -rp craft dist/craft
rm -rf tmp craft public

craftDir=dist/craft
publicDir=dist/public

permLevel=774
chmod $permLevel $craftDir/app
chmod $permLevel $craftDir/config
chmod $permLevel $craftDir/storage
echo ''
coloredEcho "  chmod $permLevel $craftDir/app" magenta
coloredEcho "  chmod $permLevel $craftDir/config" magenta
coloredEcho "  chmod $permLevel $craftDir/storage" magenta

echo ''
coloredEcho 'Downloading craft-browserify-template...' green
echo ''

git clone https://github.com/hbilles/craft-browserify-template.git

templateDir=craft-browserify-template
cp -rp $templateDir/src ./src
rm -rf $craftDir/templates
rm -rf $publicDir/htaccess
rm -rf $publicDir/web.config
mv $templateDir/gitignore .gitignore
rm -rf $publicDir/index.php
mv $templateDir/composer.json composer.json
cp -rp $templateDir/gulpfile.babel.js ./gulpfile.babel.js
mv $templateDir/.babelrc .babelrc
mv $templateDir/.eslintrc .eslintrc
mv $templateDir/env.example ./dist/.env.example
rm -rf $craftDir/config/db.php
mv $templateDir/db.php $craftDir/config/db.php
mv $templateDir/README.md README.md

mkdir _database
mkdir _database/dump

coloredEcho "  mv $templateDir/src ./src" magenta
coloredEcho "  mv $templateDir/gitignore .gitignore" magenta
coloredEcho "  rm $publicDir/index.php" magenta
coloredEcho "  mv $publicDir/composer.json composer.json" magenta
coloredEcho "  mv $publicDir/gulpfile.babel.js ./gulpfile.babel.js" magenta
coloredEcho "  mv $templateDir/.babelrc .babelrc" magenta
coloredEcho "  mv $templateDir/.eslintrc .eslintrc" magenta
coloredEcho "  mv $templateDir/env.example ./dist/.env.example" magenta
coloredEcho "  mv $templateDir/db.php $craftDir/config/db.php" magenta
coloredEcho "  mv $templateDir/README.md README.md" magenta
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
echo '------------------'
echo ''

coloredEcho "Writing package.json using provided settings..." green
sed "s/\<\%\= domainName \%\>/$domainName/g" <$templateDir/_package.json >package.json
sed -i '' "s/\<\%\= siteName \%\>/$siteName/g" package.json

coloredEcho "Writing gulpfile config.js using provided settings..." green
sed "s/\<\%\= domainName \%\>/$domainName/g" $templateDir/_config.js >gulpfile.babel.js/config.js

coloredEcho "Writing Craft general.php config using provided settings..." green
rm -rf $craftDir/config/general.php
sed "s/\<\%\= siteName \%\>/$siteName/g" <$templateDir/_general.php >$craftDir/config/general.php

coloredEcho "Cleaning up..." green
rm -rf craft-browserify-template

echo ''
echo '------------------'
echo ''

coloredEcho 'Next steps:' white
coloredEcho ' - Create a database with charset `utf8` and collation `utf8_unicode_ci`' magenta
coloredEcho ' - Copy dist/.env.example to .env and update with your database credentials' magenta
coloredEcho " - Run the installer at $domainName.dev/admin" magenta
coloredEcho '' magenta
coloredEcho 'Happy Crafting!' white