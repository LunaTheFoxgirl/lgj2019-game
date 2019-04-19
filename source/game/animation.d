/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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

	public int AnimationFrameRaw() {
		return frame;
	}

	public int AnimationFrame() {
		return cast(int)(frame%Animations.animations[animation_name].length);
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

	public int FrameCounter() {
		return frame_counter;
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