FROM debian:latest AS build

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 sed
RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

RUN flutter channel stable
RUN flutter config --enable-web
RUN flutter upgrade
RUN flutter pub global activate webdev

WORKDIR /app

COPY . /app
RUN flutter pub get
RUN flutter build web --no-tree-shake-icons --dart-define-from-file=.env

FROM nginx:1.25.3-alpine-slim
WORKDIR /usr/share/nginx/html

RUN mkdir /usr/log
RUN rm -rf ./*
COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=build /app/build/web .

CMD ["nginx", "-g", "daemon off;"]
