# Build
FROM node:26-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# Expose via httpd
FROM busybox:musl

RUN adduser -D appuser

COPY --from=builder --chown=appuser:appuser /app/build /var/www

USER appuser

EXPOSE 3000

CMD ["httpd", "-f", "-v", "-p", "3000", "-h", "/var/www"]
