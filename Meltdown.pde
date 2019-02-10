
int START = 0;
int GAME = 1;
int END = 2;

float TS;

int mapSize = 28;

int currentScreen = START;

Map map;
ArrayList <Person> personList;
ArrayList <Fan> fanList;

int numUniquePeople = 11;
int numPeople = 100;
int numFans = 30;

int fanCountdown = 50000;
int fanCountdownCheck;

PImage iconImg;
PImage tileImg, gameoverImg;

int fansQuarantined = 0;
int peopleKilled = 0;

void setup() {

    iconImg = loadImage("assets/images/icon.png");
    surface.setTitle("Meltdown");
    surface.setIcon(iconImg);

    size(640, 640);
    //fullScreen();
    frameRate(30);
    TS = float(width) / mapSize;

    noSmooth();

    map = new Map(mapSize, mapSize);

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
}

void draw() {

    surface.setTitle("Meltdown - " + round(frameRate) + "FPS");

    if (currentScreen == START) {

        drawStartScreen();
    }
    else if (currentScreen == GAME) {

        drawGameScreen();

        textSize(32);
        fill(255);
        text("People killed: " + peopleKilled + "      Fans quarantined:" + fansQuarantined, 8, 32);
    }
    else if (currentScreen == END) {

        drawEndScreen();
    }
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
        randomX = random(0, width);
        randomY = random(0, height);
    } while (!map.passableCoordinate(randomX, randomY));

    personList.add(new Person(id, randomX, randomY, TS * 3 / 2, TS * 3 / 2, direction, 2));
}

void addFanAtRandomSpot() {

    float randomX = TS * int(random(1, map.w - 1));
    float randomY = TS * int(random(1, map.h - 1));

    fanList.add(new Fan(randomX, randomY, 2 * TS, 2 * TS));
}

void setRandomFanToIrradiated() {

    Fan fan;

    do {
        int randomIndex = int(random(0, fanList.size()));
        fan = fanList.get(randomIndex);
    } while (fan.irradiated || fan.quarantined);
    
    fan.irradiated = true;
}

void addIrridatedFans() {

    if (millis() - fanCountdownCheck >= fanCountdown) {

        setRandomFanToIrradiated();
        fanCountdownCheck = millis();
    }
}

void drawGameScreen() {

    addIrridatedFans();

    map.draw();

    for (Fan fan : fanList) {
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
}

void drawStartScreen() {

    image(tileImg, 0, 0);
}

void drawEndScreen() {

    image(gameoverImg, 0, 0);
}