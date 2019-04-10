module game;
import polyplex;

public class MyGame : Game {
public:
    override void Init() {
        // Enable VSync
        Window.VSync = VSyncState.VSync;
        Window.Title = "Office Rouglike Game";
    }

    override void LoadContent() {
        // Load content here with Content.Load!T
        // You can prefix the path in the Load function to load a raw file.
    }

    override void UnloadContent() {
        // Use the D function destroy(T) to unload content.
    }

    override void Update(GameTimes gameTime) {

    }

    override void Draw(GameTimes gameTime) {

    }
}