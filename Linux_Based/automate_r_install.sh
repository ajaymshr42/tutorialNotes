#!/bin/bash
# Adds R to apt and install it
#
# Instructions:
# sudo chmod 700 InstallR.sh
# ./FirstTimeInstallR.sh

# Install R

sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" | sudo tee -a /etc/apt/sources.list

gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y r-base r-base-dev r-cran-xml r-cran-rjava libcurl4-openssl-dev
sudo apt-get install -y libssl-dev libxml2-dev openjdk-7-* libgdal-dev libproj-dev libgsl-dev
sudo apt-get install -y xml2 default-jre default-jdk mesa-common-dev libglu1-mesa-dev freeglut3-dev 
sudo apt-get install -y mesa-common-dev libx11-dev r-cran-rgl r-cran-rglpk r-cran-rsymphony r-cran-plyr 
sudo apt-get install -y  r-cran-reshape  r-cran-reshape2 r-cran-rmysql

sudo R CMD javareconf 

# install RStudio 1-0.143-amd64
# Link and version at: https://www.rstudio.com/products/rstudio/download2/

sudo apt-get install gdebi-core
wget https://download1.rstudio.org/rstudio-1.0.143-amd64.deb
sudo gdebi -n rstudio-1.0.143-amd64.deb
rm rstudio-1.0.143-amd64.deb
