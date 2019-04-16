module game.entities.player;
import game.entity;
import game.animation;
import game.world;
import polyplex;

public class Player : Entity {
private:
    Texture2D texture;
    KeyboardState kstate;
    KeyboardState lkstate;

    SpriteFlip flip = SpriteFlip.None;
    Animation animation;

    enum MoveSpeedConst = 1f;
    enum RunMultConst = 1.8f;

public:
    this(World parent) {
        this.parent = parent;
    }

    override void Init() {
        Position = Vector2(0, 0);
        this.texture = AssetCache.Get!Texture2D("textures/entities/player/player");
        
        import std.file : readText;
        animation = new Animation(fromSDL(readText("content/anim/anim_player.sdl")));
        
        animation.ChangeAnimation("idle");

        this.DrawArea = new Rectangle(0, 0, 30, 30);
        lkstate = Keyboard.GetState();
    }

    override void Update(GameTimes gameTime) {
        kstate = Keyboard.GetState();
        bool running = (kstate.IsKeyDown(Keys.LeftShift) || kstate.IsKeyDown(Keys.Right));
        immutable(float) moveSpeedMultiplier = running ? RunMultConst : 1f;

        animation.ChangeAnimation("idle", true);
        float diagSpeed = kstate.IsKeyDown(Keys.A) || kstate.IsKeyDown(Keys.D) ? 2 : 1;
        if (kstate.IsKeyDown(Keys.W)) {
            Position.Y -= (MoveSpeedConst/diagSpeed)*moveSpeedMultiplier;
            animation.ChangeAnimation("walk", true);
        }
        
        if (kstate.IsKeyDown(Keys.S)) {
            Position.Y += (MoveSpeedConst/diagSpeed)*moveSpeedMultiplier;
            animation.ChangeAnimation("walk", true);
        }

        if (kstate.IsKeyDown(Keys.A)) {
            flip = SpriteFlip.None;
            Position.X -= MoveSpeedConst*moveSpeedMultiplier;
            animation.ChangeAnimation("walk", true);
        }
        
        if (kstate.IsKeyDown(Keys.D)) {
            Position.X += MoveSpeedConst*moveSpeedMultiplier;
            flip = SpriteFlip.FlipVertical;
            animation.ChangeAnimation("walk", true);
        }
        if (!lkstate.IsKeyDown(Keys.R) && kstate.IsKeyDown(Keys.R)) {
            parent.Floor.Clear();
            parent.Floor.Generate();
        }

        this.DrawArea.X = cast(int)Position.X-(this.DrawArea.Width/2);
        this.DrawArea.Y = cast(int)Position.Y-this.DrawArea.Height;

        animation.Update(running ? cast(int)(cast(float)animation.GetAnimationTimeout()/RunMultConst) : 0);
        lkstate = kstate;
    }

    override void Draw(SpriteBatch spriteBatch, GameTimes gameTime) {
        //Logger.Info("PlayerDepth={0}", this.DrawArea.Y/parent.Floor.referenceHeight);
        
        float layer = (parent.Floor.referenceHeight-Position.Y)/parent.Floor.referenceHeight;
        
        spriteBatch.Draw(this.texture, DrawArea, new Rectangle(
            animation.GetAnimationX(), animation.GetAnimationY(), 30, 30
        ), 0f, Vector2(15, 15), Color.White, flip, layer);
    }
}