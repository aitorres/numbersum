# Build
FROM node:24-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# Expose through NGINX
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html
