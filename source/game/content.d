module game.content;
import polyplex;


private class GameContentCache {
private:
    ContentManager content;
    Object[string] cachedContent;

    void destroySelf() {
        destroy(cachedContent);
        destroy(this);
    }

public:
    /// Unloads content from the cache
    void Unload(string name) {
        cachedContent.remove(name);
    }

    /// Gets a peice of content, if it isn't loaded yet a load will be attempted.
    T Get(T)(string name) if (is(T == class)) {
        if (name in cachedContent) {
            return cast(T)cachedContent[name];
        }
        cachedContent[name] = content.Load!T(name);
        return Get!T(name);
    }

    /// Removes all content
    void Clear() {
        foreach(content; cachedContent) {
            destroy(content);
        }

        // Collect all memory from removed instances
        import core.memory : GC;
        GC.collect();
    }
}

/// Set up the game content cache
void setupGameCache() {
    Logger.Info("Setting up game asset cache...");
    AssetCache = new GameContentCache();

    import gamemain : GameContext;
    AssetCache.content = GameContext.content;
    Logger.Success("Asset cache ready!");
}

/// Clean up game cache by removing all loaded content then destroying it
void cleanupGameCache() {
    // Clear cache and self destruct
    AssetCache.Clear();
    AssetCache.destroySelf();
    Logger.Success("Destroyed asset cache...");
}

/// The shared game content cache
__gshared GameContentCache AssetCache;