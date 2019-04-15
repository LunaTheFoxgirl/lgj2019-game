module game.world;
import polyplex;
import win = polyplex.core.window;
import game.entities;
//import game.world.room;
import game.world.floor;
import polyplex.core.render.gl.debug2d;

public class World {
private:
    SpriteBatch spriteBatch;

    // Music
    Music track0;

    // Rendering stuff
    Framebuffer EffectBuffer;
    Shader postProcessing;
    Rectangle FBOBounds;
    RasterizerState rast;
    Shader depthTestShader;
    void drawFBO() {
        spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, rast, postProcessing, Camera);
        spriteBatch.Draw(EffectBuffer, FBOBounds, FBOBounds, Color.White);
        spriteBatch.End();
    }

    void beginDraw(bool withCamera = true)(bool useRasterizer = true) {
        static if (withCamera) {
            spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, useRasterizer ? rast : RasterizerState.Default, useRasterizer ? depthTestShader : null, Camera);
        } else {
            spriteBatch.Begin(SpriteSorting.Immediate, Blending.NonPremultiplied, Sampling.PointClamp, useRasterizer ? rast : RasterizerState.Default, useRasterizer ? depthTestShader : null, null);
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

    FloorManager Floor;

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
        Camera.Zoom = 3f;
        FBOBounds = new Rectangle(0, 0, 0, 0);
        depthTestShader = Content.Load!Shader("shaders/spr_depth");

        Floor = new FloorManager();

        /*foreach_reverse(y; 0..1) {
            foreach(x; 0..1) {
                Rooms ~= new Room(this, "room0", y*20, x*20);
            }
        }*/

        // track0 = Content.Load!Music("music/02");
        // track0.Play(true);
    }

    void Update(GameTimes gameTime) {

        // Update the player
        ThePlayer.Update(gameTime);

        // Update camera position to match player position
        Camera.Position =ThePlayer.DrawArea.Center; // Vector2(cast(int).X, cast(int)ThePlayer.Position.Y);
        Camera.Origin = Vector2(Window.ClientBounds.Width/2, Window.ClientBounds.Height/2);


        // Update FBO bounds (without much allocation)
        FBOBounds.X = Window.ClientBounds.X;
        FBOBounds.Y = Window.ClientBounds.Y;
        FBOBounds.Width = Window.ClientBounds.Width;
        FBOBounds.Height = Window.ClientBounds.Height;

        rast = RasterizerState.Default();
        rast.DepthTest = true;
    }

    void Draw(GameTimes gameTime) {
        //EffectBuffer = new Framebuffer(Window.ClientBounds.Width, Window.ClientBounds.Height);
        //EffectBuffer.Begin();
        beginDraw(false);
            // Draw the floor
            //foreach(room; Rooms) room.Draw(spriteBatch);
            Floor.Draw(spriteBatch);
        endDraw();

        beginDraw();
        ThePlayer.Draw(spriteBatch, gameTime);
        endDraw();

        beginDraw();
        /*foreach(room; Rooms) {
            room.DrawWalls(spriteBatch);
        }*/
        endDraw();

        //EffectBuffer.End();


        //drawFBO();
    }
}