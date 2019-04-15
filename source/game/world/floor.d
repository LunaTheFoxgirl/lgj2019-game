module game.world.floor;
import game.world.room;
import game.data.floordata;
import game.data.floorconfig;
import polyplex;

struct FloorTile {
    WallData data;
}

class FloorManager {
private:
    Floor currentFloor;
    size_t currentLevel = 0;

    void generateLevelGeometry(FloorData floor) {

    }

    void generateLevelCollission(FloorData floor) {

    }

    void generateLevelEntities(FloorData floor) {

    }

    void generateNavMesh(FloorData floor) {

    }

public:

    void Generate(size_t levelId = 0) {
        if (levelId == 0) {
            levelId = currentLevel;
        }

        FloorData data;

        generateLevelGeometry(data);
        generateLevelCollission(data);
        generateLevelEntities(data);
        generateNavMesh(data);
    }

    void Draw(SpriteBatch spriteBatch) {
        if (currentFloor !is null) currentFloor.Draw(spriteBatch);
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        return currentFloor.doesFeetCollide(feetPosition);
    }
}

/// A floor (level) of the building
class Floor {
private:
    Room[] rooms;
    FloorTile[][] tiles;
    bool[][] collissionMask;

public:
    /// Reference height used for calculating depth
    float referenceHeight;

    this(size_t maxWidth, size_t maxHeight, size_t tileWidth, size_t tileHeight) {
        tiles = new FloorTile[][](maxWidth, maxHeight);
        referenceHeight = maxHeight*tileHeight;

        collissionMask = new bool[][](maxWidth*tileWidth, cast(size_t)referenceHeight);

    }

    void Draw(SpriteBatch spriteBatch) {
        foreach(room; rooms) {
            room.Draw(spriteBatch);
        }
    }

    bool doesFeetCollide(Vector2 feetPosition) {
        if (feetPosition.X < 0 || feetPosition.X > collissionMask.length) return false;
        if (feetPosition.Y < 0 || feetPosition.Y > collissionMask[0].length) return false;
        return collissionMask[cast(int)feetPosition.X][cast(int)feetPosition.Y];
    }
}