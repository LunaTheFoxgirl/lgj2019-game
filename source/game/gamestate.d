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
            UnloadContent();

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

    void LoadContent(ContentManager content, size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].LoadContent(content);
    }

    void UnloadContent(size_t offset = 0) {
        if (gameStateStack.length == 0) return;
        gameStateStack[$-(1+offset)].UnloadContent();
    }
    
    void onDestroy() {
        foreach_reverse(state; gameStateStack) {
            state.UnloadContent();
        }

        /// Force GC to collect the memory of the now ready states
        ForceFree();

        // Then destroy the stack.
        destroy(gameStateStack);
    }
}

abstract class GameState {
public:
    abstract void Update(GameTimes gameTime);
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);
    abstract void Init();
    abstract void LoadContent(ContentManager content);
    abstract void UnloadContent();
}