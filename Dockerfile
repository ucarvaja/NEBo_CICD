# This is based on Debian and includes the Go toolchain.
FROM golang:1.22.2-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /api


# Copy the source from API folder to the Working Directory inside the container
COPY /data/* .

# Build the Go app
RUN go build -v -o api .

FROM alpine

WORKDIR /app

COPY --from=builder /api/api .
COPY --from=builder /api/cities_canada-usa.tsv .

# This container exposes port 9090 to the outside world
EXPOSE 9090

# Run the binary program produced by `go build` 
CMD ["./api"]