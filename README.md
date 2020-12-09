# bs_overlay_loader

Nice and Simple overlay progress loader.
It suits both material, cupertino design.

## Getting Started

You just call the code below when you want to show overlay loading screen.

```Dart
BsOverlayLoader.show(context, text: 'Uploading');
```
Call update() When you want to update progress value.
progress value must be ranged in 0 ~ 1
```Dart
BsOverlayLoader.update(progress); // BsOverlayLoader.update(0.3);
```

Call hide() When you want to hide overlay loading screen.

```Dart
BsOverlayLoader.hide();
```

Very easy right?