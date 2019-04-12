module game.world;
import polyplex;
import win = polyplex.core.window;

public class World {
private:
    SpriteBatch spriteBatch;

public:
    ContentManager Content;
    win.Window Window;

    this() {
        import gamemain : GameContext;

        Content = GameContext.content;
        spriteBatch = GameContext.spriteBatch;
        Window = GameContext.gameWindow;
    }

    void Init() {

    }

    void LoadContent() {

    }

    void UnloadContent() {

    }

    void Update() {

    }

    void Draw() {

    }
}