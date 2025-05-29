# ---------- Build stage ----------
FROM golang:1.24.3 AS builder

WORKDIR /app

# Copy module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code and Makefile
COPY *.go Makefile ./

# Build the binary
RUN make build

# ---------- Final stage ----------
FROM alpine:3.21

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/whoami .

# Expose application port
EXPOSE 80

# Set the command
CMD ["./whoami", "-port", "443"]
