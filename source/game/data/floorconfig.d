module game.data.floorconfig;
public import game.data;

/// Size struct
struct Size {
    /// Width
    int width;

    /// Height
    int height;
}

/// Floor data
struct FloorData {

    /// The background of the floor
    string background;

    /// The size (in tiles) of the floor
    Size size;

    /// The available rooms
    string[] rooms;

    /// The entities in the game
    string[] entities;

    /// The items available in the shop
    @name("shop:items")
    string[] shopItems;
}

/// The floor config root node
struct FloorConfig {

    /// The floors of this config
    FloorData floors;
}