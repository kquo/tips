## AI
AI tips.

### Run DeepSeek Locally

Use [ollama](https://github.com/ollama/ollama) for this.

Pick what DeepSeek R1 model you want to play with: 7b (4.7GB) - 14b (9G) - 32b (20GB) - 70b (43GB) - 671b (404GB)

```bash
brew install ollama                   # Install ollama
allama serve                          # Start ollama - in a diff shell window
ollama pull deepseek-r1:7b            # Pull deepseek-r1:7b
ollama run deepseek-r1:7b             # Run it
alias r1='ollama run deepseek-r1:7b'  # Setup a shell alias to prompt question
```
