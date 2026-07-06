# ---------- Марҳилаи сохтан (build) ----------
FROM golang:1.21-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o anime-bot -ldflags="-s -w" .

# ---------- Марҳилаи иҷро (runtime) ----------
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/anime-bot .

RUN mkdir -p /app/data

VOLUME ["/app/data"]

CMD ["./anime-bot"]
