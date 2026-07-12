# ---------- Build ----------
FROM golang:1.21-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

# Copy all project files
COPY . .

# Generate/update dependencies automatically
RUN go mod tidy

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o appbuilder-bot -ldflags="-s -w" .

# ---------- Runtime ----------
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/appbuilder-bot .

RUN mkdir -p /app/data

VOLUME ["/app/data"]

CMD ["./appbuilder-bot"]
