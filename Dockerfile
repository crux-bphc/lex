FROM debian:latest AS build

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 sed
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
RUN flutter build web --no-tree-shake-icons

FROM nginx:1.21.1-alpine

COPY --from=build /app/build/web /usr/share/nginx/html
