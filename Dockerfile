FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./aejin.html /usr/share/nginx/html/aejin.html
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80
