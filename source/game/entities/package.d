module game.entities;
public import game.entities.player;
public import game.content;
import polyplex;
import game.world;

abstract class Entity {
public:
    World parent;

    /// The position of the entity
    Vector2 Position;

    /// The hitbox of the entity
    Rectangle Hitbox;

    /// A rectangle used to define where to draw the entity
    Rectangle DrawArea;

    /// Wether this entity is alive
    bool Alive() {
        return Health <= 0;
    }

    /// Wether this entitiy is active
    bool Active;

    float Health = 100f;

    /// Update function
    abstract void Update(GameTimes gameTime);

    /// Draw function
    abstract void Draw(SpriteBatch spriteBatch, GameTimes gameTime);

    /// Initialization function
    abstract void Init();

    void playFootstep() {
        footStep.Pitch = 1+(random.NextFloat()/5);
        footStep.Play();
    }

    bool willCollideWithWorld(Vector2 pos) {
        return parent.Floor.doesFeetCollide(pos);
    }

    float layer() {
        return (parent.Floor.referenceHeight-Position.Y)/parent.Floor.referenceHeight;
    }
}



import polyplex.utils.random;
private __gshared SoundEffect footStep;
private __gshared Music music;
private __gshared Random random;

void loadSFX() {
    random = new Random();
    import std.conv : text;
    footStep = AssetCache.Get!SoundEffect("sfx/footstep/wood");
    footStep.Gain = 0.4f;

    immutable(int) num = random.Next(1, 8);
    music = AssetCache.Get!Music("music/0"~num.text);
    music.Play(true);
    Logger.Info("Playing track 0{0}!...", num);
}