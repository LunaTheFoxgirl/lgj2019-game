module game.entities.player;
import game.entity;
import game.animation;
import polyplex;

public class Player : Entity {
private:
    Texture2D texture;
    KeyboardState kstate;

    SpriteFlip flip = SpriteFlip.None;
    Animation animation;

    enum MoveSpeedConst = 1f;

public:
    override void Init() {
        Position = Vector2(0, 0);
        this.texture = AssetCache.Get!Texture2D("textures/entities/player/player");
        
        import std.file : readText;
        animation = new Animation(fromSDL(readText("content/anim/anim_player.sdl")));
        
        animation.ChangeAnimation("idle");

        this.DrawArea = new Rectangle(0, 0, 30, 30);
    }

    override void Update(GameTimes gameTime) {
        kstate = Keyboard.GetState();


        animation.ChangeAnimation("idle", true);
        float diagSpeed = kstate.IsKeyDown(Keys.A) || kstate.IsKeyDown(Keys.D) ? 2 : 1;
        if (kstate.IsKeyDown(Keys.W)) {
            Position.Y -= MoveSpeedConst/diagSpeed;
            animation.ChangeAnimation("walk", true);
        }
        
        if (kstate.IsKeyDown(Keys.S)) {
            Position.Y += MoveSpeedConst/diagSpeed;
            animation.ChangeAnimation("walk", true);
        }

        if (kstate.IsKeyDown(Keys.A)) {
            flip = SpriteFlip.None;
            Position.X -= MoveSpeedConst;
            animation.ChangeAnimation("walk", true);
        }
        
        if (kstate.IsKeyDown(Keys.D)) {
            Position.X += MoveSpeedConst;
            flip = SpriteFlip.FlipVertical;
            animation.ChangeAnimation("walk", true);
        }

        this.DrawArea.X = cast(int)Position.X;
        this.DrawArea.Y = cast(int)Position.Y;

        animation.Update();
    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {
        spriteBatch.Draw(this.texture, DrawArea, new Rectangle(
            animation.GetAnimationX()*30, animation.GetAnimationY()*30, 30, 30
        ), 0f, Vector2(15, 15), Color.White, flip, 5f);
    }
}