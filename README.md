# swiftris

For some odd reason, setting the `size:` of the scene to `skView.bounds.size` doesn't set the scene to the size of the ... skView. My fix was to use the actual size of the background image instead `size: CGSize(width: 320, height: 568)`.

## Known Bugs
* When navigating back to the home view from another view, the nav bar stays at the top when it should disappear.
* When navigating away from a game back to the home view, the music continues even on the home view. When navigating back to a game, another (additional) iteration of the music plays. This is true every time the user leaves a game and goes back into a game; a new (additional) interation of the music begins each time.
