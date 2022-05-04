# iOS

## Compile Your Own App
Compile sample app [Textor](https://github.com/lencap/textor), an **iOS** text editor application, on **macOS**. Should use a different open-source app since this one is no longer maintained.

1. Confirm Xcode is installed:
```
xcode-select -p
/Library/Developer/CommandLineTools
or
/Applications/Xcode.app/Contents/Developer
```

2. Checkout the code: `git clone https://github.com/lencap/textor`

3. Open `.xcodeproj` file

4. Update the `Bundle Identifer` to `mydomain.com.MYAPP`

5. Connect iPhone via USB

6. Build/test on iPhone

7. Enable app on iPhone: Settings > General > Device Management > Apple Development

- **References**
  - <https://cocoacasts.com/what-are-app-ids-and-bundle-identifiers/>
  - <https://learnappmaking.com/how-to-create-a-free-apple-developer-account/>
  - <https://support.apple.com/en-us/HT204460>
  - <https://developer.apple.com/account/resources/>
  - <https://codewithchris.com/deploy-your-app-on-an-iphone/>
