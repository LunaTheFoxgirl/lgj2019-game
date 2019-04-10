module gamemain;
import polyplex;
import game.gamestate;

public class GameMain : Game {
private:

    ref getContent() {
        return Content;
    }

    ref getSpriteBatch() {
        return sprite_batch;
    }

public:
    override void Init() {
        // Enable VSync
        Window.VSync = VSyncState.VSync;
        Window.Title = "Office Rouglike Game";
        Window.AllowResizing = true;
    }

    override void LoadContent() {
        // Load content here with Content.Load!T
        // You can prefix the path in the Load function to load a raw file.

        // Initialize GameContext
        GameContext.initContext(this);

        // Start game state managment
        import game.gamestates.mainstate : MainGameState;
        GameStateManager.Push(new MainGameState());
        GameStateManager.Init(Content);
    }

    override void UnloadContent() {
        // Use the D function destroy(T) to unload content.
    }

    override void Update(GameTimes gameTime) {
        GameStateManager.Update(gameTime);
    }

    override void Draw(GameTimes gameTime) {
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

    ref ContentManager Content() {
        return game.getContent();
    }

    ref SpriteBatch spriteBatch() {
        return game.getSpriteBatch();
    }
}