module game.entities.player;
import game.entity;
import polyplex;

public class Player : Entity {
private:
    Texture2D texture;
    KeyboardState kstate;

    enum MoveSpeedConst = 1f;

public:
    override void Init() {
        Position = Vector2(0, 0);
        this.texture = AssetCache.Get!Texture2D("textures/entities/player/player");
        this.DrawArea = new Rectangle(0, 0, 30, 30);
    }

    override void Update(GameTimes gameTime) {
        kstate = Keyboard.GetState();


        if (kstate.IsKeyDown(Keys.W)) {
            Position.Y -= MoveSpeedConst;
        }
        
        if (kstate.IsKeyDown(Keys.S)) {
            Position.Y += MoveSpeedConst;
        }

        if (kstate.IsKeyDown(Keys.A)) {
            Position.X -= MoveSpeedConst;
        }
        
        if (kstate.IsKeyDown(Keys.D)) {
            Position.X += MoveSpeedConst;
        }

        this.DrawArea.X = cast(int)Position.X;
        this.DrawArea.Y = cast(int)Position.Y;
    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {
        spriteBatch.Draw(this.texture, DrawArea, new Rectangle(
            0, 0, 32, 32
        ), 0f, Vector2(16, 16), Color.White);
    }
}