/*
    Copyright © 2019 Clipsey

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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