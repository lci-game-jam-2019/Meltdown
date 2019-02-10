
class Person {

    int MOVING = 0;
    int STOPPING = 1;
    
    PImage[] sprites;

    int id;
    float x, y;
    int w, h;
    float direction, tendDirection;
    float speed;

    int radiationDurationCheck;
    int greenCountdown = 5000, deathCountdown = 8000;

    int animationDuration = 250, animationDurationCheck;

    int moveDuration, moveDurationCheck;
    int[] moveDurationRange = { 1000, 2000 };

    int stopDuration, stopDurationCheck;
    int[] stopDurationRange = { 200, 500 };

    boolean irradiated = false;
    boolean green = false;
    boolean dead = false;

    int state = MOVING;
    int frame = 0, numFrames = 2;

    Person(int _id, float _x, float _y, int _w, int _h, float _direction, float _speed) {

        id = _id;
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        direction = _direction;
        speed = _speed;
        
        tendDirection = random(360);

        sprites = new PImage[numFrames];
        for (int i = 0; i < numFrames; i++) {
            sprites[i] = loadImage("assets/images/people/" + id + "-" + i + ".png");
        }

        animationDuration = millis();

        moveDuration = getRandomMoveDuration();
        moveDurationCheck = millis();
    }

    void draw() {

        float imgX = x - w / 2;
        float imgY = y - h;

        if (green) {
            tint(0, 255, 0);
        }

        image(sprites[frame], imgX, imgY, w, h);
        image(sprites[frame], imgX + screenWidth, imgY, w, h);
        image(sprites[frame], imgX, imgY + screenHeight, w, h);
        image(sprites[frame], imgX - screenWidth, imgY, w, h);
        image(sprites[frame], imgX, imgY - screenHeight, w, h);

        tint(255, 255, 255);
    }

    void die() {

        if (irradiated && millis() > radiationDurationCheck + deathCountdown) {

            dead = true;
            peopleKilled++;

            if (peopleKilled == numPeople) {

                currentScreen = END;
                return;
            }
        }
    }

    void turnGreen() {

        if (irradiated && millis() > radiationDurationCheck + greenCountdown) {
            green = true;
        }
    }

    void irradiate() {

        if (irradiated) {
            return;
        }

        for (Fan fan : fanList) {

            if (fan.irradiated) {

                if (fan.touchingCoordinate(x, y)) {

                    irradiated = true;
                    radiationDurationCheck = millis();
                }
            }
        }
    }

    void move() {

        // change state from moving to stopping
        if (state == MOVING && millis() > moveDurationCheck + moveDuration) {

            state = STOPPING;

            stopDuration = getRandomStopDuration();
            stopDurationCheck = millis();
        }

        // change state from stopping to moving
        else if (state == STOPPING && millis() > stopDuration + stopDurationCheck) {

            state = MOVING;

            direction = getRandomDirection();
            moveDuration = getRandomMoveDuration();
            moveDurationCheck = millis();
        }

        // move
        else if (state == MOVING) {

            float dXYMultiplier = speed * (TS / 32.0) * (30.0 / frameRate);
            float dX = cos(radians(direction)) * dXYMultiplier;
            float dY = sin(radians(direction)) * dXYMultiplier;
            
            dX = (9 * dX + cos(tendDirection)) / 10;
            dY = (9 * dY + cos(tendDirection)) / 10;

            float newX = (x + dX + screenWidth) % screenWidth;
            float newY = (y + dY + screenHeight) % screenHeight;

            // if new position is impassable, change direction
            if (!map.passableCoordinate(newX, newY) && map.passableCoordinate(x, y)) {

                direction = getRandomDirection();
                return;
            }

            if (millis() > animationDurationCheck + animationDuration) {

                frame = (frame + 1) % numFrames;
                animationDurationCheck = millis();
            }

            x = newX;
            y = newY;
        }

        // stop
        else if (state == STOPPING) {

            frame = 0;
        }
    }

    int getRandomMoveDuration() {

        return int(random(moveDurationRange[0], moveDurationRange[1]));
    }

    int getRandomStopDuration() {

        return int(random(stopDurationRange[0], stopDurationRange[1]));
    }

    float getRandomDirection() {

        return random(360);
    }
}
