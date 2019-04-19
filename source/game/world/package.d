/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module game.world;
import polyplex;
import win = polyplex.core.window;
import game.entities;
//import game.world.room;
import game.world.floor;
import polyplex.core.render.gl.debug2d;
import game.ui.arrow;

public class World {
private:
    SpriteBatch spriteBatch;

    // UI
    UIArrow uiArrow;

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
        ThePlayer = new Player(this);
        ThePlayer.Init();
        Camera = new Camera2D(Vector2(0, 0), -5f, 0f, 3f, 0f, 1f);
        Camera.Zoom = 2.8f;
        FBOBounds = new Rectangle(0, 0, 0, 0);
        depthTestShader = Content.Load!Shader("shaders/spr_depth");

        Floor = new FloorManager(this);

        Floor.Generate();


        uiArrow = new UIArrow();
        uiArrow.endRoom = this.Floor.endRoom;
        uiArrow.world = this;
    }

    void Update(GameTimes gameTime) {

        // Update the player
        ThePlayer.Update(gameTime);

        // Update camera position to match player position
        Camera.Position = Vector2(ThePlayer.Position.X, ThePlayer.Position.Y-(ThePlayer.DrawArea.Height/2));
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
            Floor.DrawFloor(spriteBatch);
        endDraw();

        beginDraw();
        ThePlayer.Draw(spriteBatch, gameTime);
        endDraw();

        beginDraw();
        Floor.Draw(spriteBatch);
        endDraw();

        //EffectBuffer.End();


        //drawFBO();

        // UI
        spriteBatch.Begin();
        uiArrow.Draw(spriteBatch);
        spriteBatch.End();
    }
}