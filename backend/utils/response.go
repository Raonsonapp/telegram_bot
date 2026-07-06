package utils

import (
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// HTTPClient як client бо маҳдудияти суръат (rate limit) барои Jikan API
// (Jikan-и ройгон тахминан 3 дархост/сония ва 60 дархост/дақиқа иҷозат медиҳад)
type HTTPClient struct {
	client      *http.Client
	mu          sync.Mutex
	lastRequest time.Time
	minInterval time.Duration
}

// NewHTTPClient client-и нав месозад
func NewHTTPClient() *HTTPClient {
	return &HTTPClient{
		client:      &http.Client{Timeout: 15 * time.Second},
		minInterval: 400 * time.Millisecond, // ~2.5 дархост/сония, бехатар барои Jikan
	}
}

// throttle пеш аз ҳар дархост интизор мешавад, то аз rate-limit нагузарем
func (h *HTTPClient) throttle() {
	h.mu.Lock()
	defer h.mu.Unlock()
	elapsed := time.Since(h.lastRequest)
	if elapsed < h.minInterval {
		time.Sleep(h.minInterval - elapsed)
	}
	h.lastRequest = time.Now()
}

// Get дархости GET-ро месозад ва то 3 маротиба такрор мекунад агар хато рух диҳад
func (h *HTTPClient) Get(url string) ([]byte, error) {
	var lastErr error
	for attempt := 1; attempt <= 3; attempt++ {
		h.throttle()

		resp, err := h.client.Get(url)
		if err != nil {
			lastErr = err
			time.Sleep(time.Duration(attempt) * 500 * time.Millisecond)
			continue
		}

		body, readErr := io.ReadAll(resp.Body)
		resp.Body.Close()
		if readErr != nil {
			lastErr = readErr
			continue
		}

		if resp.StatusCode == http.StatusTooManyRequests {
			lastErr = fmt.Errorf("rate limited (429) by API")
			time.Sleep(time.Duration(attempt) * time.Second)
			continue
		}

		if resp.StatusCode == http.StatusNotFound {
			return nil, fmt.Errorf("not found (404)")
		}

		if resp.StatusCode != http.StatusOK {
			lastErr = fmt.Errorf("unexpected status code: %d", resp.StatusCode)
			continue
		}

		return body, nil
	}
	return nil, fmt.Errorf("failed after retries: %w", lastErr)
}
