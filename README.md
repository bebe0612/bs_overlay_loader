# bs_overlay_loader

Nice and Simple overlay progress loader.
It suits both material, cupertino design.

## Getting Started

You just call the code below when you want to show overlay loading screen.

```Dart
BsOverlayLoader.show(context, text: 'Uploading');
```
Call update() When you want to update progress value.

```Dart
BsOverlayLoader.update(progress);
```

Call hide() When you want to hide overlay loading screen.

```Dart
BsOverlayLoader.hide();
```

Very easy right?