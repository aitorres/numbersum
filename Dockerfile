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

USER 1001

EXPOSE 3000

CMD ["httpd", "-f", "-v", "-p", "3000", "-h", "/var/www"]
