module game.gamestate;
import polyplex;

/// The manager of game states owo
class GameStateManager {
private:
    __gshared GameState[] gameStateStack;

public static:
    void Push(GameState state) {
        gameStateStack ~= state;
    }

    void Pop() {
        if (gameStateStack.length > 0) {
            gameStateStack.length--;
        }
    }

    void Update(GameTimes gameTime, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Update(gameTime);
    }

    void Draw(SpriteBatch spriteBatch, GameTimes gameTime, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Draw(spriteBatch, gameTime);
    }

    void Init(ContentManager content, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Init(content);
    }
}

abstract class GameState {
public:
    abstract void Update(GameTimes gameTime);
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);
    abstract void Init(ContentManager content);
}