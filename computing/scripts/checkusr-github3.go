//
// checkusr-github3.go 1.0.0
// Checks available 3-letter usernames in Github.com

package main

import (
	"fmt"
	"net/http"
	"time"
)

var alphabet = []rune{'a', 'e', 'o', 'u', 'q', 'k', 't', 'p', 'm'}

var client = &http.Client{
	Timeout: 5 * time.Second,
}

// Generate all length-N strings from alphabet (with repetition)
func generateStrings(alphabet []rune, length int) []string {
	var result []string
	var helper func(pos int, buf []rune)

	helper = func(pos int, buf []rune) {
		if pos == length {
			result = append(result, string(buf))
			return
		}
		for _, ch := range alphabet {
			buf[pos] = ch
			helper(pos+1, buf)
		}
	}

	helper(0, make([]rune, length))
	return result
}

// Check availability with rate-limit handling
func isAvailable(username string) bool {
	url := fmt.Sprintf("https://github.com/%s", username)

	backoff := 100 * time.Millisecond
	maxRetries := 5

	for i := 0; i < maxRetries; i++ {
		resp, err := client.Head(url)
		if err != nil {
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

	return false
}

func main() {
	words := generateStrings(alphabet, 3)

	fmt.Printf("Generated %d usernames. Checking availability...\n\n", len(words))

	counter := 0
	for _, w := range words {
		if isAvailable(w) {
			fmt.Printf("%-5s", w)
			counter++
			if counter%6 == 0 {
				fmt.Println()
			}
		}
	}

	if counter%6 != 0 {
		fmt.Println()
	}

	fmt.Printf("\nDone checking %d usernames. %d available.\n", len(words), counter)
}
