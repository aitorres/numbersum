# Build
FROM node:26-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# Expose via httpd
FROM busybox:musl

COPY --from=builder /app/build /var/www

EXPOSE 80

CMD ["httpd", "-f", "-v", "-p", "80", "-h", "/var/www"]
