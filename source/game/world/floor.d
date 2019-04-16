module game.world.floor;
import game.world.room;
import game.data.floordata;
import game.data.floorconfig;
import polyplex;
import game.world;

/// Get the offset for a wall segment
Vector2i getWallOffset(Vector2i position, Vector2i size) {
    Vector2 posx = calculatePosition(position, size);
    return Vector2i(cast(int)posx.X, cast(int)posx.Y+(size.Y/2)-size.Y);
}

/// Calculate position of object on the isometric grid
Vector2 calculatePosition(Vector2i pos, Vector2i size) {
    import isometric.isomath : setIsometricSize, isoTranslate;
    setIsometricSize(size.X, size.Y/2);
    return isoTranslate(pos);
}

class FloorManager {
private:
    FloorConfig config;
    Floor currentFloor;
    size_t currentLevel = 0;
    World parent;

    void generateLevelGeometry(FloorData floor) {
        Logger.Info("Generating level geometry...");
        currentFloor = new Floor(parent, floor.size.width, floor.size.height, 60, 60);

        RoomData data = fromResource!RoomData("rooms/room0");

        ptrdiff_t x = 0;
        ptrdiff_t y = floor.size.height;
        while(y > 0) {
            if (y < 0) break;

            while(x < floor.size.width) {
                if (x > floor.size.width) break;

                Room room = new Room(currentFloor, data);
                room.walls = new Wall[][](data.width, data.height);

                room.Generate(Vector2i(cast(int)x, cast(int)y));
                Logger.Info("placed {0} at {1},{2}", data.name_, x, y);
                currentFloor.rooms ~= room;
                x += data.width;
            }
            y -= data.height;
            x = 0;
        }
        
        /*foreach(x; 0..room.walls.length) {
            foreach(y; 0..room.walls[x].length) {

                Rectangle pos = new Rectangle();
                Vector2i posx = calculatePosition(Vector2i(cast(int)x, cast(int)y), Vector2i(60, 60));
                pos.X = posx.X;
                pos.Y = posx.Y+((floor.size.height/2)*60);
                pos.Width = 60;
                pos.Height = 60;

                room.walls[x][y] = new Wall(room, pos, data.classname);
            }
        }*/


        referenceHeight = currentFloor.referenceHeight;

        Logger.Info("Geometry generated!");
    }

    void generateLevelCollission(FloorData floor) {

    }

    void generateLevelEntities(FloorData floor) {

    }

    void generateNavMesh(FloorData floor) {

    }
public:
    float referenceHeight;

    this(World parent) {
        config = fromResource!FloorConfig("floorconfig");
        Logger.Debug("{0}", config);
        this.parent = parent;
    }

    void Generate(size_t levelId = 0) {
        if (levelId == 0) {
            levelId = currentLevel;
        }

        // repeat last floor forever.
        if (levelId >= config.floors.length) {
            levelId = config.floors.length-1;
        }

        
        generateLevelGeometry(config.floors[levelId]);
        generateLevelCollission(config.floors[levelId]);
        generateLevelEntities(config.floors[levelId]);
        generateNavMesh(config.floors[levelId]);
    }

    void Draw(SpriteBatch spriteBatch) {
        if (currentFloor !is null) currentFloor.Draw(spriteBatch);
    }

    void DrawFloor(SpriteBatch spriteBatch) {
        if (currentFloor !is null) currentFloor.DrawFloor(spriteBatch);
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        return currentFloor.doesFeetCollide(feetPosition);
    }
}

/// A floor (level) of the building
class Floor {
private:
    bool[][] collissionMask;

public:
    /// Reference height used for calculating depth
    float referenceHeight;
    Room[] rooms;
    Vector2 position;

    World parent;

    this(World parent, size_t maxWidth, size_t maxHeight, size_t tileWidth, size_t tileHeight) {
        referenceHeight = maxHeight*tileHeight;
        collissionMask = new bool[][](maxWidth*tileWidth, cast(size_t)referenceHeight);
        this.parent = parent;
    }

    void Draw(SpriteBatch spriteBatch) {
        foreach(room; rooms) {
            room.Draw(spriteBatch);
        }
    }

    void DrawFloor(SpriteBatch spriteBatch) {
        foreach_reverse(room; rooms) {
            room.DrawFloor(spriteBatch);
        }
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        if (feetPosition.X < 0 || feetPosition.X > collissionMask.length) return false;
        if (feetPosition.Y < 0 || feetPosition.Y > collissionMask[0].length) return false;
        return collissionMask[cast(int)feetPosition.X][cast(int)feetPosition.Y];
    }
}