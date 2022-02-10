# Start the Go app build
FROM public.ecr.aws/docker/library/golang:latest AS build

# Copy source
WORKDIR /app/hello
COPY . .

# If packages are installed in ./vendor (using dep), we do not need a `go get`
RUN go mod tidy

# Build a statically-linked Go binary for Linux
RUN CGO_ENABLED=0 GOOS=linux go build -a -o hello .

# New build phase -- create binary-only image
FROM public.ecr.aws/docker/library/alpine:latest

# Add support for HTTPS and time zones
RUN apk update && \
    apk upgrade && \
    apk add ca-certificates && \
    apk add tzdata

WORKDIR /app/hello

# Copy files from previous build container
COPY --from=build /app/hello/hello .
# COPY --from=build /go/src/github.com/jamespearly/hello/assets ./assets/

RUN pwd && find .

# Start the application
CMD ["./hello"]
