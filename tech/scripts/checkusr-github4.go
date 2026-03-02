//
// checkusr-github4.go 1.0.0
// Checks available 4-letter usernames in Github.com

package main

import (
	"fmt"
	"net/http"
	"time"
)

var vowels = []rune{'a', 'e', 'o', 'u'}
var mandatory = []rune{'q', 'k'}

var client = &http.Client{
	Timeout: 5 * time.Second,
}

// Helper: generate all combinations of vowels of length k
func combinations(v []rune, k int) [][]rune {
	var result [][]rune
	var helper func(start int, comb []rune)

	helper = func(start int, comb []rune) {
		if len(comb) == k {
			tmp := make([]rune, k)
			copy(tmp, comb)
			result = append(result, tmp)
			return
		}
		for i := start; i < len(v); i++ {
			helper(i+1, append(comb, v[i]))
		}
	}

	helper(0, []rune{})
	return result
}

// Helper: generate all permutations of a slice of runes
func permutations(arr []rune) [][]rune {
	if len(arr) == 1 {
		return [][]rune{arr}
	}

	var result [][]rune
	for i, ch := range arr {
		rest := append([]rune{}, arr[:i]...)
		rest = append(rest, arr[i+1:]...)
		for _, p := range permutations(rest) {
			result = append(result, append([]rune{ch}, p...))
		}
	}
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
	allWords := []string{}

	// Generate all words
	vowelCombos := combinations(vowels, 2)
	for _, vc := range vowelCombos {
		letters := append(mandatory, vc...)
		perms := permutations(letters)
		for _, p := range perms {
			allWords = append(allWords, string(p))
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
