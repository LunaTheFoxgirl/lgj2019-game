module game.animation;
import vibe.data.sdl : deserializeSDLang, Tag;
import sdlang.parser;

AnimationData[][string] fromSDL(string data, string from = __MODULE__) {
	Tag source = parseSource(data, from);
    return deserializeSDLang!(AnimationData[][string])(source);
}

public struct AnimationData {
	public int frame;
	public int animation;
	public int timeout;
}

public class Animation {
	private string animation_name;
	private int frame;
	private int frame_counter;
	private int frame_timeout;

	AnimationData[][string] Animations;

	this(AnimationData[][string] animations) {
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
		if (!seamless) this.frame = Animations[animation_name][0].frame;
	}

	public bool IsLastFrame() {
		if ((frame)%Animations[animation_name].length == Animations[animation_name].length-1) return true;
		return false;
	}

	public int GetAnimationX(int offset = 0) {
		return Animations[animation_name][(frame+offset)%Animations[animation_name].length].frame;
	}

	public int GetAnimationY(int offset = 0) {
		return Animations[animation_name][(frame+offset)%Animations[animation_name].length].animation;
	}

	public int GetAnimationTimeout(int offset = 0) {
		return Animations[animation_name][(frame+offset)%Animations[animation_name].length].timeout;
	}

	public void Update() {
		frame_timeout = GetAnimationTimeout();
		if (frame_counter >= frame_timeout) {
			this.frame++;
			frame_counter = 0;
		}
		frame_counter++;
	}
}