fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios match_configuration
```
fastlane ios match_configuration
```
Setup code signing and App Store Connect
### ios test
```
fastlane ios test
```
Perform Tests
### ios build
```
fastlane ios build
```
Build for upload, either to TestFlight or to the AppStore
### ios cleanup
```
fastlane ios cleanup
```

### ios beta
```
fastlane ios beta
```
Upload to TestFlight
### ios release
```
fastlane ios release
```
Release to App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
