FROM appsvc/php:7.4-apache_20210226.3

# WORKDIR /home/site/wwwroot

RUN mkdir -p /home/site/wwwroot/royaloak-react

RUN apt update

RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh

RUN bash nodesource_setup.sh

RUN apt-get install -y nodejs

#if we are using the below command to copy only the static content folders from local into the docker image, we can skip this below command
#since we are going to upload that via File Manager.However, if this copy command is used to copy required node dependencies then it should be there.
COPY . /home/site/wwwroot/

COPY init.sh /home/init.sh 

WORKDIR /home/site/wwwroot/royaloak-react

RUN npm install

RUN npm run build:prod

WORKDIR /home/site/wwwroot/royaloak-api

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/site/wwwroot/royaloak-api --filename=composer

RUN php composer install

RUN chmod -R 777 ./


EXPOSE 3000 
# RUN npm i --save @babel/polyfill express react react-router-config react-router compression react-dom react-router-dom react-redux serialize-javascript react-helmet react-lazy-load-image-component axios react-slick react-bootstrap react-bootstrap redux-thunk npm-install-all

ENTRYPOINT ["sh","/home/init.sh" ]
