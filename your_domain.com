#/etc/nginx/sites-available

server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;
#use the location of you own SSL certificate#
    ssl_certificate /etc/nginx/certificate/nginx-certificate.crt;
    ssl_certificate_key /etc/nginx/certificate/nginx.key;

    location / {

#Using for redirection
        proxy_pass http://localhost:49160;
       
#Using to set header name and value        
        proxy_set_header Host $host;

#"$remote_addr" variable will be replaced with the IP address of the client that initiated the request.
        proxy_set_header X-Real-IP $remote_addr;

##the backend server can see the original IP address of the client that initiated the request.
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

#used to bypass the cache for the request. When the value of the "$http_pragma" variable is not empty, the cache will be bypassed and the request will be forwarded to the backend server to obtain a fresh response.
        proxy_cache_bypass $http_pragma;

#used to bypass the cache for the request. When the value of the "$http_authorization" variable is not empty, the cache will be bypassed and the request will be forwarded to the backend server to obtain a fresh response.
        proxy_cache_bypass $http_authorization;

##In these cases, the "proxy_cache_bypass" directive can be used to bypass the cache for the request. When the value of the "$http_cache_control" variable is not empty, the cache will be bypassed and the request will be forwarded to the backend server to obtain a fresh response.
        proxy_cache_bypass $http_cache_control;

#used to add a new header to the response with the name "NewHeaderName" and the value "NEW".
         more_set_headers 'NewHeaderName:NEW';

#This means that the response should not be cached by any intermediate caches, including proxy servers, and the client must revalidate the response with the server for every request. The "max-age" directive is set to zero, indicating that the response should not be considered fresh and must be revalidated with the server for every request.        
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
        
#used to enforce the browser to connect HTTPS and redirect HTTP to HTTPS 
       add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";


    }
}

