# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG BASE_URL=/unwrap/
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
RUN rm /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html/unwrap
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
