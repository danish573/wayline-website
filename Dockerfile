<<<<<<< HEAD
FROM nginx:latest
COPY wayline-website/ /usr/share/nginx/html/
EXPOSE 80
=======
FROM nginx:latest
COPY wayline-website/ /usr/share/nginx/html/
EXPOSE 80
>>>>>>> 521f1da (prject)
CMD [ "nginx", "-g", "daemon off;" ]