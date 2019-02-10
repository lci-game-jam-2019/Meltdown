
int START = 0;
int GAME = 1;
int GAMEOVER = 2;
int WIN = 3;

int TS;

int mapSize = 28;
int screenWidth, screenHeight;

int currentScreen = START;

Map map;
ArrayList <Person> personList;
ArrayList <Fan> fanList;

int numUniquePeople = 11;
int numPeople = 100;
int numFans = 20;

int fanCountdown = 15000;
int fanCountdownCheck;

PImage iconImg;
PImage tileImg, gameoverImg, winImg;

int fansQuarantined = 0;
int peopleKilled = 0;
int activeFans = 0;

void setup() {

    iconImg = loadImage("assets/images/icon.png");
    surface.setTitle("Meltdown");
    surface.setIcon(iconImg);

    fullScreen();
    frameRate(30);

    noSmooth();
    noStroke();

    map = new Map(mapSize, mapSize);

    TS = height / mapSize;
    screenWidth = map.w * TS;
    screenHeight = map.h * TS;

    personList = new ArrayList();
    fanList = new ArrayList();

    for (int i = 0; i < numPeople; i++) {
        addPersonAtRandomSpot();
    }

    for (int i = 0; i < numFans; i++) {
        addFanAtRandomSpot();
    }

    setRandomFanToIrradiated();

    tileImg = loadImage("assets/images/title.png");
    gameoverImg = loadImage("assets/images/gameover.png");
    winImg = loadImage("assets/images/win.png");
}

void draw() {

    pushMatrix();

    translate((width - screenWidth) / 2, (height - screenHeight) / 2);

    if (currentScreen == START) {

        drawStartScreen();
    }
    else if (currentScreen == GAME) {

        drawGameScreen();

        textSize(24);
        fill(255);
        text("People killed: " + peopleKilled + "      Fans quarantined:" + fansQuarantined + "      Active fans: " + activeFans, 8, 32);
    }
    else if (currentScreen == GAMEOVER) {

        drawGameoverScreen();
    }
    else if (currentScreen == WIN) {

        drawWinScreen();
    }

    popMatrix();

    fill(0, 0, 0);
    rect(0, 0, width, (height - screenHeight) / 2);
    rect(0, height, width, -(height - screenHeight) / 2);
    rect(0, 0, (width - screenWidth) / 2, height);
    rect(width, 0, -(width - screenWidth) / 2, height);

    fill(255);
    textSize(24);
    text(round(frameRate) + "FPS", 4, 28);
}

float gameMouseX() {

    return mouseX - (width - screenWidth) / 2;
}

float gameMouseY() {

    return mouseY - (height - screenHeight) / 2;
}

void mousePressed() {

    if (currentScreen == GAME) {

        for (Fan fan : fanList) {

            if (fan.quarantined) {
                continue;
            }

            fan.remove();
        }
    }
}

void mouseReleased() {

    if (currentScreen == START) {
        currentScreen = GAME;
    }
}

void addPersonAtRandomSpot() {

    int id = int(random(0, numUniquePeople));
    float direction = random(0, 360);
    float randomX, randomY;

    do {
        randomX = random(0, screenWidth);
        randomY = random(0, screenHeight);
    } while (!map.passableCoordinate(randomX, randomY));

    personList.add(new Person(id, randomX, randomY, TS * 3 / 2, TS * 3 / 2, direction, 2));
}

void addFanAtRandomSpot() {

    float randomX;
    float randomY;

    do {
      randomX = TS * int(random(1, map.w - 1));
      randomY = TS * int(random(1, map.h - 1));
    } while (!goodFanLocation(int(randomX / TS),int(randomY / TS)));

    fanList.add(new Fan(randomX, randomY, 2 * TS, 2 * TS));
}

boolean goodFanLocation(int tileX, int tileY) {

    if (map.getTile(tileX - 1, tileY - 1) != 0) {
        return false;
    }
    if (map.getTile(tileX, tileY - 1) != 0) {
        return false;
    }
    if (map.getTile(tileX - 1, tileY) != 0) {
        return false;
    }
    if (map.getTile(tileX, tileY) != 0) {
        return false;
    }

    for (Fan fan : fanList) {
        
        if (abs(tileX - int(fan.x / TS)) <= 1 && abs(tileY - int(fan.y / TS)) <= 1) {
            return false;
        }
    }
    return true;
}

void setRandomFanToIrradiated() {

    if (activeFans == numFans - fansQuarantined) {
        return;
    }

    Fan fan;

    do {
        int randomIndex = int(random(0, fanList.size()));
        fan = fanList.get(randomIndex);
    } while (fan.irradiated || fan.quarantined);

    fan.irradiated = true;
    activeFans++;  
}

void addIrradiatedFans() {

    if (millis() - fanCountdownCheck >= fanCountdown) {

        setRandomFanToIrradiated();
        fanCountdownCheck = millis();
    }
}

void drawGameScreen() {

    addIrradiatedFans();

    map.draw();

    for (Fan fan : fanList) {
        fan.updateRotation();
        fan.draw();
    }

    for (Person person : personList) {

        if (person.dead) {
            continue;
        }

        person.turnGreen();
        person.die();
        person.move();
        person.irradiate();
        person.draw();
    }
    
    for (Fan fan : fanList) {

        if (!fan.quarantined && fan.touchingCoordinate(gameMouseX(), gameMouseY())) {

            tint(255,0,0);
            fan.draw();
            tint(255,255,255);
        }
    }
}

void drawStartScreen() {

    image(tileImg, 0, 0, screenWidth, screenHeight);
}

void drawGameoverScreen() {

    image(gameoverImg, 0, 0, screenWidth, screenHeight);
}

void drawWinScreen() {

    image(winImg, 0, 0, screenWidth, screenHeight);
}
