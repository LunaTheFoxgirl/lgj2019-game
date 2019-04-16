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