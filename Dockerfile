FROM node:14.20.0-alpine3.16 AS build

RUN apk add git --no-cache
WORKDIR "/src"

COPY . /src
RUN yarn install && \
	yarn cache clean
RUN	yarn gulp build

FROM scratch AS export
WORKDIR /
COPY --from=build /src/index.html .
COPY --from=build /src/build ./build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html/
COPY . .
# Override the local source with the built artifacts
COPY --from=export . . 

# Add nginx configuration for port 8181
RUN echo 'server { \
    listen 8181; \
    server_name _; \
    root /usr/share/nginx/html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8181
