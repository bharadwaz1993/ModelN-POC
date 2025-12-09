# Very simple hello-world app using Nginx
FROM nginx:alpine

# Remove default html
RUN rm -rf /usr/share/nginx/html/*

# Copy our simple hello page
COPY index.html /usr/share/nginx/html/index.html

# Expose HTTP
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
