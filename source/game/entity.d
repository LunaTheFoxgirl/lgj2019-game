module game.entity;
import polyplex;

public:


abstract class Entity {
public:
    /// Wether this entity is alive
    bool Alive;

    /// Wether this entitiy is active
    bool Active;

    /// Update function
    abstract void Update(GameTimes gameTime);

    /// Draw function
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);

    /// Initialization function
    abstract void Init();
}