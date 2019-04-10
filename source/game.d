module game;
import polyplex;
import isometric.isofloorbuilder;

public class MyGame : Game {
public:
    FloorBuilder floorBuilder;

    Texture2D floorX;

    override void Init() {
        // Enable VSync
        Window.VSync = VSyncState.VSync;
        Window.Title = "Office Rouglike Game";
        Window.AllowResizing = true;
        
        floorBuilder = new FloorBuilder();
    }

    override void LoadContent() {
        // Load content here with Content.Load!T
        // You can prefix the path in the Load function to load a raw file.

        // Load placeholder ground
        floorBuilder.RegisterFloor("PLACEHOLDER", Content.Load!Texture2D("ph-ground"));

        // Create 32x32 floor
        floorX = floorBuilder.Build("PLACEHOLDER", 32, 32);
    }

    override void UnloadContent() {
        // Use the D function destroy(T) to unload content.
    }

    override void Update(GameTimes gameTime) {

    }

    override void Draw(GameTimes gameTime) {
        Renderer.ClearColor(Color.Black);
        sprite_batch.Begin();
        sprite_batch.Draw(floorX, new Rectangle(0, 0, floorX.Width, floorX.Height), floorX.Size, Color.White);
        sprite_batch.End();
    }
}