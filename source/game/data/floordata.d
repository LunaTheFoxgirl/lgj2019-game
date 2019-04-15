module game.data.floordata;
public import game.data;


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
    string classname = "parent";

    /// The variant of the wall texture to use.
    @optional
    string variant = "default";
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

    Connection[] connections;

    /// Extra walls
    @optional
    ExWall[] extraWalls;
}

enum ConnectionDirection : string {
    Left = "left",
    Right = "right",
    Up = "up",
    Down = "down"
}

/// A connection point for a wall
struct Connection {
    /// X coordinate for the connection
    int x;

    /// Y Coordinate for the connection
    int y;

    /// Direction for the connection
    ConnectionDirection direction;
}

import polyplex;
struct WallData {
    /*
        Essential
    */
    /// Name of the texture resource associated with this wall
    string textureName;

    /// The variant of the texture associated with this wall
    string variant;


    /*
        Cosmetic
    */

    /// The color used for this wall segment
    Color selfColor;

    /// The step the color is at transparency wise
    float colorStep;


    /// The constructor (duh!)
    this(string textureName, string variant = "default") {
        this.textureName = textureName;
        this.variant = variant;
        this.selfColor = Color.White;
        this.colorStep = 1f;
    }
}