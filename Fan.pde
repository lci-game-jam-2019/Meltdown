
class Fan {

    PImage bladeSprite, gridSprite, quarantineSprite;

    float x, y;
    int w, h;
    float angle, spinSpeed;

    boolean irradiated = false, quarantined = false;

    Fan(float _x, float _y, int _w, int _h) {

        x = _x;
        y = _y;
        w = _w;
        h = _h;
        
        spinSpeed = random(8, 16);

        bladeSprite = loadImage("assets/images/map/fan-blade.png");
        gridSprite = loadImage("assets/images/map/fan-grid.png");
        quarantineSprite = loadImage("assets/images/map/fan-quarantine.png");

        if (irradiated) {
            activeFans++;
        }
    }
    
    void updateRotation() {

        angle = (angle + spinSpeed * (30 / frameRate)) % 360;
    }

    void draw() {

        if (!quarantined) {

            pushMatrix();

            translate(x, y);
            rotate(radians(angle));
            translate(-w / 2, -h / 2);
            image(bladeSprite, 0, 0, w, h);

            popMatrix();

            image(gridSprite, x - w / 2, y - h / 2, w, h);
        }
        else {

            image(quarantineSprite, x - w / 2, y - h / 2, w, h);
        }

        if (irradiated) {

            //fill(255, 0, 0);
            //ellipse(x, y, 32, 32);
        }
    }

    boolean touchingCoordinate(float posX, float posY) {

        if (abs(posX - x) <= w / 2 && abs(posY - y) <= h / 2) {
            return true;
        }
        return false;
    }

    void remove() {

        if (!touchingCoordinate(gameMouseX(), gameMouseY())) {
            return;
        }

        if (!irradiated) {

            currentScreen = GAMEOVER;
            return;
        }

        quarantined = true;
        fansQuarantined++;
        activeFans--;

        if (fansQuarantined == numFans) {

            currentScreen = WIN;
            return;
        }

        // (tileX, tileY) is the bottom-right corner
        int tileX = int(x / TS);
        int tileY = int(y / TS);

        map.setTile(tileX - 1, tileY - 1, 2);
        map.setTile(tileX - 1, tileY, 2);
        map.setTile(tileX, tileY - 1, 2);
        map.setTile(tileX, tileY, 2);
    }
}
