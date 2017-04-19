# SoundCloudMemoryGame

### Requirements

- iOS 9.3+
- Xcode 8.3+
- Swift 3.1+


### How to run the project

The project uses [Carthage](https://github.com/Carthage/Carthage) for dependency management.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```
After the installation, run the following command in the root directory of the project:
```bash
carthage bootstrap --platform iOS --no-use-binaries
```
When Carthage install all dependencies, you can open ```SoundCloudMemoryGame.xcodeproj```. 

**⚠️ SoundCloudAPI Client ID ⚠️**
Before running the project, make sure to add the value for ```SCAPIClientID``` key into the ```info.plist``` file.


### Architecture

When possible (and suitable), SoundCloudMemoryGame follows MVVM architecture and functional reactive programming principles. [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift/) is used in the majority of the app to make the code simpler and more expressive.

### Project structure

Instead of having root folders like ```ViewControllers``` ```Views``` etc. with all view controllers and views inside them, I decided to group them according to the scene they belong to. It's much easier to work on the particular scene when all the elements are at the one place. Elements, which are meant to be reusable, are then located inside corresponding root folders.

![Project structure](/Doc/structure.png)

**Tests are first class citizens!** Inspired by this interesting [article](https://kickstarter.engineering/why-you-should-co-locate-your-xcode-tests-c69f79211411), I placed test files to the same folder as the implementation files. It's much easier to work on a given class when you don't have to jump up and down in the project structure.

### Testing

The project has two levels of tests:

#### Behavior tests
The project uses [Quick](https://github.com/Quick/Quick) for behavior-driven testing and [Nimble](https://github.com/Quick/Nimble) as a matcher framework. Behavioral tests are focused on testing the proper behavior of the system. They are used mainly for non-view classes.

#### Snapshot tests
Snapshot tests are meant to be used for testing views. The project uses [FBSnapshotTestCase](https://github.com/facebook/ios-snapshot-test-case) for generating and comparing snapshots. For seamless integration with Quick, there's [Nimble-Snapshots](https://github.com/ashfurrow/Nimble-Snapshots),  a Nimble matcher wrapping FBSnapshotTestCase.

If you want to test the project for various system versions and devices, you can use [Fastlane](https://github.com/fastlane/fastlane) and simply run: 
```bash
fastlane scan
```
Please note, that you have to have the following simulators installed in the system: ["iPhone 6 (9.3)", "iPhone 6 Plus (9.3)", "iPhone 6 (10.3)", "iPhone 6 Plus (10.3)"].
