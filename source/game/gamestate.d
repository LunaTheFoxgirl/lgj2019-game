module game.gamestate;
import polyplex;

/// The manager of game states owo
class GameStateManager {
private:
    __gshared GameState[] gameStateStack;

public static:
    void Push(GameState state, string from = __MODULE__) {
        Logger.Debug("Pushed {0} from {1}!", state.Name, from);
        gameStateStack ~= state;
        state.Init();
    }

    void Pop() {
        if (gameStateStack.length > 0) {
            destroy(gameStateStack[$-1]);

            /// Force GC to collect the memory of the now ready state
            ForceFree();

            gameStateStack.length--;
        }
    }

    void ForceFree() {
        import core.memory : GC;
        GC.collect();
    }

    void Update(GameTimes gameTime, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Update(gameTime);
    }

    void Draw(SpriteBatch spriteBatch, GameTimes gameTime, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Draw(spriteBatch, gameTime);
    }

    void Init(size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].Init();
    }
}

abstract class GameState {
public:
    string Name;

    abstract void Update(GameTimes gameTime);
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);
    abstract void Init();
}