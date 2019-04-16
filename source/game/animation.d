module game.animation;
import vibe.data.sdl : deserializeSDLang, Tag;
import sdlang.parser;

AnimationRoot fromSDL(string animations, string from = __MODULE__) {
	Tag source = parseSource(animations, from);
    return deserializeSDLang!AnimationRoot(source);
}

public struct Animationanimations {
	public int frame;
	public int animation;
	public int timeout;
}

public struct AnimationRoot {
	int width;
	int height;
	Animationanimations[][string] animations;
}

public class Animation {
	private string animation_name;
	private int frame;
	private int frame_counter;
	private int frame_timeout;

	AnimationRoot Animations;

	this(AnimationRoot animations) {
		this.Animations = animations;
	}

	public string AnimationName() {
		return animation_name;
	}

	public int AnimationFrame() {
		return frame;
	}

	public void ChangeAnimation(string name, bool seamless = false) {
		if (animation_name == name) return;
		this.animation_name = name;
		if (!seamless) this.frame = Animations.animations[animation_name][0].frame;
	}

	public bool IsLastFrame() {
		if ((frame)%Animations.animations[animation_name].length == Animations.animations[animation_name].length-1) return true;
		return false;
	}

	public int GetAnimationX(int offset = 0) {
		return (Animations.animations[animation_name][(frame+offset)%Animations.animations[animation_name].length].frame)*Animations.width;
	}

	public int GetAnimationY(int offset = 0) {
		return (Animations.animations[animation_name][(frame+offset)%Animations.animations[animation_name].length].animation)*Animations.height;
	}

	public int GetAnimationTimeout(int offset = 0) {
		return Animations.animations[animation_name][(frame+offset)%Animations.animations[animation_name].length].timeout;
	}

	public void Update(int timeoutForce = 0) {
		frame_timeout = timeoutForce > 0 ? timeoutForce : GetAnimationTimeout();
		if (frame_counter >= frame_timeout) {
			this.frame++;
			frame_counter = 0;
		}
		frame_counter++;
	}
}