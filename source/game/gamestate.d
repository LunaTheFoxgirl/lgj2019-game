/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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