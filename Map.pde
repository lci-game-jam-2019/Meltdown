
class Map {

    int VERTICAL = 0;
    int HORIZONTAL = 1;

    int w, h;
    ArrayList <IntList> terrain;
    ArrayList <PImage> tiles;

    PImage parallaxImg;

    float parallaxOffset = 0;

    Map(int _w, int _h) {

        terrain = new ArrayList();
        tiles = new ArrayList();
        tiles.add(loadImage("assets/images/map/floor.png"));
        tiles.add(loadImage("assets/images/map/puddle.png"));
        tiles.add(loadImage("assets/images/map/quarantine.png"));

        parallaxImg = loadImage("assets/images/map/parallax.png");

        w = _w;
        h = _h;

        proceduralGeneration();
    }

    void proceduralGeneration() {
      
        do {

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
        } while (!checkMap());
    }
    
    boolean checkMap() {

        for (int i = 0; i < w; i++) {

            for (int j = 0; j < h; j++) {

                if (getTile(i,j) != 1) {

                    fillMap(i, j);
                    boolean noRooms = true;

                    for (int k = 0; k < w; k++) {
                        
                        for (int l = 0; l < h; l++) {

                            if (getTile(k, l) == 0) {
                                noRooms = false;
                            }
                            if (getTile(k, l) == 2) {
                                setTile(k, l, 0);
                            }
                        }
                    }
                    return noRooms;
                }
            }
        }
        return false;
    }

    void fillMap(int tileX, int tileY) {

        if (getTile(tileX, tileY) == 0) {

            setTile(tileX, tileY, 2);
            fillMap((tileX - 1 + w) % w, tileY);
            fillMap(tileX, (tileY - 1 + h) % h);
            fillMap((tileX + 1 + w) % w, tileY);
            fillMap(tileX ,(tileY + 1 + h) % h);
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

    void updateParallax() {

        parallaxOffset = (parallaxOffset + 1 * (30 / frameRate)) % screenHeight;
    }

    void drawParallax() {

        image(parallaxImg, 0, parallaxOffset, screenWidth, screenHeight);
        image(parallaxImg, 0, parallaxOffset - screenHeight, screenWidth, screenHeight);
    }

    void drawTerrain() {

        for (int i = 0; i < h; i++) {

            for (int j = 0; j < w; j++) {

                int tile = getTile(j, i);

                if (tile != 1) {
                    image(tiles.get(tile), j * TS, i * TS, TS, TS * 2);
                }
            }
        }
    }

    boolean passableCoordinate(float posX, float posY) {

        int tileX = int(posX / TS);
        int tileY = int(posY / TS);

        if (getTile(tileX, tileY) == 0) {
            return true;
        }

        return false;
    }
}
