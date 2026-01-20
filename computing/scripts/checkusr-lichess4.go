//
// checkusr-lichess4.go 1.0.0
// Checks available 4-letter usernames in liches.org

package main

import (
	"fmt"
	"net/http"
	"time"
)

var vowels = []rune{'a', 'e', 'i', 'o', 'u'}
var mandatory = []rune{'q', 'k'}

var client = &http.Client{
	Timeout: 5 * time.Second,
}

func isAvailable(username string) bool {
	url := fmt.Sprintf("https://lichess.org/@/%s", username)

	backoff := 100 * time.Millisecond
	maxRetries := 5

	for i := 0; i < maxRetries; i++ {
		resp, err := client.Head(url)
		if err != nil {
			// Network or timeout error: retry with backoff
			time.Sleep(backoff)
			backoff *= 2
			continue
		}

		resp.Body.Close()

		switch resp.StatusCode {
		case http.StatusNotFound:
			return true
		case http.StatusTooManyRequests:
			time.Sleep(backoff)
			backoff *= 2
			continue
		default:
			return false
		}
	}

	// Give up after retries
	return false
}

func main() {
	allWords := []string{}

	// Generate 4-letter usernames [m][v][m][v] without repeats
	for _, m1 := range mandatory {
		for _, v1 := range vowels {
			for _, m2 := range mandatory {
				if m2 == m1 {
					continue
				}
				for _, v2 := range vowels {
					if v2 == v1 {
						continue
					}
					word := string([]rune{m1, v1, m2, v2})
					allWords = append(allWords, word)
				}
			}
		}
	}

	fmt.Printf("Generated %d usernames. Checking availability...\n\n", len(allWords))

	counter := 0
	for _, w := range allWords {
		if isAvailable(w) {
			fmt.Printf("%-6s", w)
			counter++
			if counter%4 == 0 {
				fmt.Println()
			}
		}
	}

	if counter%4 != 0 {
		fmt.Println()
	}

	fmt.Printf("\nDone checking %d usernames. %d available.\n", len(allWords), counter)
}
