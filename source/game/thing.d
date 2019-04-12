module game.ingame.thing;
import polyplex;

public abstract class Thing {

    abstract void Update(GameTimes gameTime);
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);
    abstract void Init();
}