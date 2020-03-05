FROM nginx:mainline-alpine

# Configure nginx
COPY docker/nginx/nginx.conf /etc/nginx/conf.d/

# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf
