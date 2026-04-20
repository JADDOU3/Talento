FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY Frontend/web/pubspec.yaml .
COPY Frontend/web/pubspec.lock .

RUN flutter pub get

COPY Frontend/web .

RUN flutter build web --release

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY Docker/web/nginx-frontend.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
