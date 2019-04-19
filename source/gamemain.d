/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module gamemain;
import polyplex;
import game.gamestate;
import game.content;
import game.data;
import game.data.texdef;
import game.entities;

public class GameMain : Game {
private:

    ref getContent() {
        return Content;
    }

    ref getSpriteBatch() {
        return sprite_batch;
    }

public:
    ~this() {
        UnloadContent();
    }

    override void Init() {
        // Enable VSync
        Window.VSync = VSyncState.VSync;
        Window.Title = "No Promo (Prototype)";
        Window.AllowResizing = true;
    }

    override void LoadContent() {
        // Load content here with Content.Load!T
        // You can prefix the path in the Load function to load a raw file.

        // Initialize GameContext
        GameContext.initContext(this);
        setupGameCache();
        initializeSDLLoader();
        initializeTexdef();
        loadSFX();

        // Start game state managment
        import game.gamestates.mainstate : MainGameState;
        GameStateManager.Push(new MainGameState());
    }

    override void UnloadContent() {
        // Use the D function destroy(T) to unload content.
        cleanupGameCache();
    }

    override void Update(GameTimes gameTime) {
        GameStateManager.Update(gameTime);
    }

    override void Draw(GameTimes gameTime) {
        Renderer.ClearDepth();
        Renderer.ClearColor(Color.CornflowerBlue);
        GameStateManager.Draw(sprite_batch, gameTime);
    }
}


public class GameContext {
private static:
    GameMain game;

    static void initContext(GameMain game) {
        this.game = game;
    }
public static:

    ref ContentManager content() {
        return game.getContent();
    }

    ref SpriteBatch spriteBatch() {
        return game.getSpriteBatch();
    }

    Window gameWindow() {
        return game.Window();
    }
}