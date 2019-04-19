/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module game.data.floorconfig;
public import game.data;

/// Size struct
struct Size {
    /// Width
    int width;

    /// Height
    int height;
}

struct Shop {
    string[] items;

    @optional
    Dialogue[] dialogue;
}

struct Dialogue {
    string actor;
    string says;
}

struct DialogueEvent {
    string type;
    Dialogue[] dialogue;
}

struct RoomConfig {
    string start;
    string end;
    string[] rooms;
}

/// Floor data
struct FloorData {

    /// The background of the floor
    string background;

    /// The size (in tiles) of the floor
    Size size;
    
    /// The available rooms
    RoomConfig rooms;

    /// The entities in the game
    string[] entities;

    /// The items available in the shop
    @optional
    Shop shop;

    @optional
    DialogueEvent[] dialogs;
}

/// The floor config root node
struct FloorConfig {

    /// The floors of this config
    FloorData[] floors;
}