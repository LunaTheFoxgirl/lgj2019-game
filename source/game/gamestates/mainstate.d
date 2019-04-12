module game.gamestates.mainstate;
import polyplex;
import game.gamestate;

/// The main game state that is the root of the game
class MainGameState : GameState {
public:
    this() {
        this.Name = "State Bootstrapper";
    }

    ~this() {

    }

    override void Update(GameTimes gameTime) {

    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {

    }

    override void Init() {
        import game.gamestates.ingamestate;
        GameStateManager.Push(new IngameState());
    }
}