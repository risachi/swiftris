# swiftris

For some odd reason, setting the `size:` of the scene to `skView.bounds.size` doesn't set the scene to the size of the ... skView. My fix was to use the actual size of the background image instead `size: CGSize(width: 320, height: 568)`.
