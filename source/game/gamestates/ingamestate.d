module game.gamestates.ingamestate;
import game.gamestate;
import polyplex;
import game.world;

// State active while in-game 
public class IngameState : GameState {
private:
    World gameWorld;

public:
    this() {
        this.Name = "Ingame State";
    }

    override void Init() {
        gameWorld = new World();
        gameWorld.Init();

        //TODO: generate world based on data
    }

    override void Update(GameTimes gameTime) {
        gameWorld.Update(gameTime);
    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {
        gameWorld.Draw(gameTime);
    }
}