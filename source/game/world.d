module game.world;
import polyplex;
import win = polyplex.core.window;

import game.entities;

public class World {
private:
    SpriteBatch spriteBatch;

public:
    /// The content
    ContentManager Content;

    /// The game window
    win.Window Window;
    
    /// The player
    Player ThePlayer;


    this() {
        import gamemain : GameContext;

        Content = GameContext.content;
        spriteBatch = GameContext.spriteBatch;
        Window = GameContext.gameWindow;
    }

    void Init() {

    }

    void Update() {

    }

    void Draw() {

    }
}