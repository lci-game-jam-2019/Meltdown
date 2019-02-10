
class Map {

    int VERTICAL = 0;
    int HORIZONTAL = 1;

    int w, h;
    ArrayList <IntList> terrain;
    ArrayList <PImage> tiles;

    int puddleOffset = 0;

    Map(int _w, int _h) {

        terrain = new ArrayList();
        tiles = new ArrayList();
        tiles.add(loadImage("assets/images/map/floor.png"));
        tiles.add(loadImage("assets/images/map/puddle.png"));
        tiles.add(loadImage("assets/images/map/quarantine.png"));

        w = _w;
        h = _h;

        proceduralGeneration();
    }

    void proceduralGeneration() {

        terrain.clear();

        // create blank map
        for (int i = 0; i < h; i++) {

            IntList row = new IntList();

            for (int j = 0; j < w; j++) {
                row.append(0);
            }

            terrain.add(row);
        }

        IntList hWalls = new IntList();
        IntList vWalls = new IntList();

        int buffer = 4;  // maximum width of corridor - 1
    
        // draw horizontal walls
        for (int i = 0; i < 4; i++) {

            int randomX = randomWallPos(w, buffer);
            int randomY;

            do {
                randomY = randomWallPos(h, buffer);
            } while(hWalls.hasValue(randomY));

            hWalls.append(randomY);
            addWall(HORIZONTAL, randomX, randomY, int(random(2, 4)) * buffer + 1);
        }

        // draw vertical walls
        for (int i = 0; i < 4; i++) {

            int randomX;
            int randomY = randomWallPos(w, buffer);

            do {
                randomX = randomWallPos(h, buffer);
            } while(vWalls.hasValue(randomX));

            vWalls.append(randomX);
            addWall(VERTICAL, randomX, randomY, int(random(2, 4)) * buffer + 1);
        }
    }

    int randomWallPos(int bound, int buffer) {

        int randVal = int(random(0, (bound - buffer) / buffer));
        return randVal * buffer + buffer / 2;
    }

    void addWall(int direction, int wallX, int wallY, int length) {

        for (int i = 0; i < length; i++) {

            int tileX = wallX, tileY = wallY;

            if (direction == HORIZONTAL) {
                tileX += i;
            }
            else {
                tileY += i;
            }

            setTile(tileX % w, tileY % h, 1);
        }
    }

    int getTile(int tileX, int tileY) {

        return terrain.get(tileY).get(tileX);
    }

    void setTile(int tileX, int tileY, int val) {

        terrain.get(tileY).set(tileX, val);
    }

    void draw() {

        // draw puddles
        for (int i = 0; i < h; i++) {

            for (int j = 0; j < w; j++) {

                int tile = getTile(j, i);

                if (tile == 1) {
                    image(tiles.get(tile), j * 32, i * 32 + puddleOffset, 32, 32);
                    image(tiles.get(tile), j * 32, (i - 1) * 32 + puddleOffset, 32, 32);
                }
            }
        }

        puddleOffset = (puddleOffset + 1) % 32;

        // draw non-puddles
        for (int i = 0; i < h; i++) {

            for (int j = 0; j < w; j++) {

                int tile = getTile(j, i);

                if (tile != 1) {
                    image(tiles.get(tile), j * 32, i * 32, 32, 32);
                }
            }
        }
    }

    boolean passableCoordinate(float posX, float posY) {

        int tileX = int(posX / 32);
        int tileY = int(posY / 32);

        if (getTile(tileX, tileY) == 1) {
            return false;
        }

        return true;
    }
}
