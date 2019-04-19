/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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