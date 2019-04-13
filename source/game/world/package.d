module game.world;
import polyplex;
import win = polyplex.core.window;
import game.entities;
import game.world.room;

public class World {
private:
    SpriteBatch spriteBatch;





    Framebuffer EffectBuffer;
    Shader postProcessing;
    Rectangle FBOBounds;
    void drawFBO() {
        spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, RasterizerState.Default, postProcessing, Camera);
        spriteBatch.Draw(EffectBuffer, FBOBounds, FBOBounds, Color.White);
        spriteBatch.End();
    }

    void beginDraw(bool withCamera = true)() {
        static if (withCamera) {
            spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, RasterizerState.Default, null, Camera);
        } else {
            spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, RasterizerState.Default, null, null);
        }
    }

    void endDraw() {
        spriteBatch.End();
    }

public:
    /// The content
    ContentManager Content;

    /// The game window
    win.Window Window;
    
    /// The player
    Player ThePlayer;

    /// The camera
    static Camera2D Camera;

    /// The rooms in the map
    Room[] Rooms;

    this() {
        import gamemain : GameContext;

        Content = GameContext.content;
        spriteBatch = GameContext.spriteBatch;
        Window = GameContext.gameWindow;
    }

    void Init() {
        ThePlayer = new Player();
        ThePlayer.Init();
        Camera = new Camera2D(Vector2(0, 0));
        Camera.Zoom = 2.5f;
        FBOBounds = new Rectangle(0, 0, 0, 0);
        Rooms ~= [new Room("room0", 0, 0)];
    }

    void Update(GameTimes gameTime) {

        // Update the player
        ThePlayer.Update(gameTime);

        // Update camera position to match player position
        Camera.Position = Vector2(cast(int)ThePlayer.Position.X, cast(int)ThePlayer.Position.Y);
        Camera.Origin = Vector2(Window.ClientBounds.Width/2, Window.ClientBounds.Height/2);


        // Update FBO bounds (without much allocation)
        FBOBounds.X = Window.ClientBounds.X;
        FBOBounds.Y = Window.ClientBounds.Y;
        FBOBounds.Width = Window.ClientBounds.Width;
        FBOBounds.Height = Window.ClientBounds.Height;
    }

    void Draw(GameTimes gameTime) {
        //EffectBuffer = new Framebuffer(Window.ClientBounds.Width, Window.ClientBounds.Height);
        //EffectBuffer.Begin();

        beginDraw();
        foreach(room; Rooms) {
            room.Draw(spriteBatch);
        }
        endDraw();

        beginDraw();
        ThePlayer.Draw(spriteBatch, gameTime);
        endDraw();

        //EffectBuffer.End();


        //drawFBO();
    }
}