FROM nginx:latest
COPY Wayline-website/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
