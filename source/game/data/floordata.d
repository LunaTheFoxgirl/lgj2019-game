module game.data.floordata;
import vibe.data.serialization : optional;


deprecated("Don't use this kthxbye")
enum WallOrientation {
    North = 0,
    East = 1,
    NorthEast = 2,
    West = 3,
    South = 4,
    SouthWest = 5,
    NorthWest = 6,
    SouthEast = 7,
    All = 8
}

struct FloorItem {
    /// Position on floor (in tiles)
    int x;

    /// Position on floor (in tiles)
    int y;

    /// classname of item to place (if any)
    /// set to door or DESTROY to add doors.
    @optional
    string classname;

    /// Attributes
    @optional
    string[] attributes;
}

struct Point {
    /// X coordinate
    int x;

    /// Y coordinate
    int y;
}

struct ExWall {
    /// Where the wall starts
    Point start;

    /// Where the wall ends
    Point end;

    /// The texture of the wall
    @optional
    string classname;
}

struct RoomData {
    /// Name of the room (for caching purposes)
    @optional
    string name;

    /// The name of the texture to use for the room
    string roomTexture;

    /// The classname of the walls (what texture they should use)
    string classname;

    /// Width of room (in tiles)
    int width;

    /// Height of room (in tiles)
    int height;

    /// Wether the room has walls
    @optional
    bool hasWalls = true;

    /// The floor plan (what stuff to place where)
    //int[][] floorPlan;
    FloorItem[] floorPlan;

    /// Extra walls
    @optional
    ExWall[] extraWalls;
}

RoomData fromString(string data, string origin = __MODULE__) {
    import sdlang.parser : parseSource;
    import vibe.data.sdl : deserializeSDLang;
    return deserializeSDLang!RoomData(parseSource(data, origin));
}


struct RoomWall {
    string textureName;
}