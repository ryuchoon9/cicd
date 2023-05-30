FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./aejin /usr/share/nginx/html/aejin
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80
