package utils

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// HTTPClient як client бо маҳдудияти суръат (rate limit) барои API-ҳои беруна
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

// Get дархости GET-ро месозад
func (h *HTTPClient) Get(url string) ([]byte, error) {
	return h.do(func() (*http.Request, error) {
		return http.NewRequest(http.MethodGet, url, nil)
	})
}

// Post дархости POST-ро бо баданаи JSON месозад (масалан барои GraphQL-и AniList)
func (h *HTTPClient) Post(url string, jsonBody []byte) ([]byte, error) {
	return h.do(func() (*http.Request, error) {
		req, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(jsonBody))
		if err != nil {
			return nil, err
		}
		req.Header.Set("Content-Type", "application/json")
		return req, nil
	})
}

// do дархостро месозад ва то 4 маротиба такрор мекунад агар хато рух диҳад
// (Jikan-и ройгон зуд-зуд 429/504 бармегардонад, барои ҳамин backoff лозим аст)
func (h *HTTPClient) do(buildReq func() (*http.Request, error)) ([]byte, error) {
	var lastErr error
	for attempt := 1; attempt <= 4; attempt++ {
		h.throttle()

		req, err := buildReq()
		if err != nil {
			return nil, fmt.Errorf("failed to build request: %w", err)
		}
		// Баъзе провайдерҳо (масалан Cloudflare дар пеши Jikan) дархостҳои
		// бе User-Agent-и муайянро дар вақти сербории сервер рад мекунанд
		req.Header.Set("User-Agent", "appbuilder-bot/1.0 (+https://github.com)")
		req.Header.Set("Accept", "application/json")

		resp, err := h.client.Do(req)
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
			time.Sleep(time.Duration(attempt) * 500 * time.Millisecond)
			continue
		}

		return body, nil
	}
	return nil, fmt.Errorf("failed after retries: %w", lastErr)
}
