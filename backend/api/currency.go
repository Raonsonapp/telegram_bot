package api

import (
	"encoding/json"
	"fmt"
	"net/url"
	"strings"

	"anime-bot/backend/utils"
)

// currencyEndpoint API-и ройгону бе калиди Frankfurter (аз рӯи нархҳои ECB)
const currencyEndpoint = "https://api.frankfurter.app/latest"

// CurrencyClient client барои мубодилаи асъор
type CurrencyClient struct {
	http *utils.HTTPClient
}

// NewCurrencyClient client-и нав месозад
func NewCurrencyClient() *CurrencyClient {
	return &CurrencyClient{http: utils.NewHTTPClient()}
}

// Convert amount-и додашударо аз асъори from ба асъори to табдил медиҳад
func (c *CurrencyClient) Convert(amount float64, from, to string) (float64, error) {
	from = strings.ToUpper(strings.TrimSpace(from))
	to = strings.ToUpper(strings.TrimSpace(to))

	endpoint := fmt.Sprintf("%s?amount=%s&from=%s&to=%s",
		currencyEndpoint, url.QueryEscape(fmt.Sprintf("%v", amount)), url.QueryEscape(from), url.QueryEscape(to))

	body, err := c.http.Get(endpoint)
	if err != nil {
		return 0, fmt.Errorf("currency conversion failed: %w", err)
	}

	var result struct {
		Rates map[string]float64 `json:"rates"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return 0, fmt.Errorf("failed to parse currency response: %w", err)
	}

	rate, ok := result.Rates[to]
	if !ok {
		return 0, fmt.Errorf("no rate found for currency %q", to)
	}
	return rate, nil
}
