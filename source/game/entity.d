module game.entity;
import polyplex;

public import game.content;

public:


abstract class Entity {
public:
    /// The position of the entity
    Vector2 Position;

    /// The hitbox of the entity
    Rectangle Hitbox;

    /// A rectangle used to define where to draw the entity
    Rectangle DrawArea;

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