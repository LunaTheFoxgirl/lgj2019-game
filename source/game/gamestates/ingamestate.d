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

        //TODO: generate world based on data
    }

    override void LoadContent(ContentManager content) {

    }

    override void UnloadContent() {
        
    }

    override void Update(GameTimes gameTime) {

    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {

    }
}