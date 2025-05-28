# foobar-api

Tiny Go webserver that prints os information and HTTP request to output

Original [repo](https://github.com/containous/foobar-api)

## Setup

1. Install Go: https://go.dev/doc/install
2. Create a self signed certificate:
   ```bash
   cd cert
   openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout key.pem \
    -out cert.pem \
    -subj "/C=US/ST=Local/L=Local/O=Local/CN=localhost"
   ```
3. Build the docker image (from the the ./api directory):
   ```bash
   docker build -t foobar-api .
   ```

4. Run the docker container:
   ```bash
    docker run -d --name foobar-api -p 8080:80 foobar-api
    ```

5. Test the API:
    ```bash
    curl -k https://localhost:8080/
    ```
    or visit: https://localhost:8080/