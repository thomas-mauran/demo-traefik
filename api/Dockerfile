FROM golang:1.24.3

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY *.go Makefile ./

COPY ./cert /cert

RUN make build

EXPOSE 80

CMD [ "./whoami" ]