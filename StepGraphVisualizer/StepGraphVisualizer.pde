final int SCREEN_WIDTH = 600;
final int SCREEN_HEIGHT = 400;

int[] xPositions;
int[] yPositions;
int lastXEnd;
int playerX;
int playerY;
int lastPlayerY;
int playerVelY;
boolean playerOnGround;

int matchIndex;

boolean canJump;
boolean rightDown;
boolean leftDown;

PImage mario;

//Setup function runs once at start up
void setup(){  
  //Processing Setup
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  background(0);
  
  //Run external functions
  loadData();
  loadImage();
  
  resetPlayer();
}

void loadImage(){
  mario = loadImage("mario.jpg");
}

void resetPlayer(){
  playerX = xPositions[0] + mario.width;
  playerY = yPositions[0] - mario.height;
  lastPlayerY = playerY;
  playerVelY = 0;
  playerOnGround = false;
}

//The draw function runs continuously each frame
void draw(){
  background(0);
  handleInput();
  updatePlayer();
  updateCamera();
  drawStepGraph();
  drawMario();
  drawText();
}

//This function loads the external file and sets variables
void loadData(){
  //load test data
  String[] stepData = loadStrings("TestData.txt");
  xPositions = new int[stepData.length - 1];
  yPositions = new int[stepData.length - 1];
  for (int i = 0; i < stepData.length - 1; i++){
    //each line should be of the form "xPos, yPos"
    String[] tokenizedString = split(stepData[i], ',');
    xPositions[i] = int(tokenizedString[0]);
    yPositions[i] = -int(trim(tokenizedString[1]));
  }
  
  //the last line should just be a single integer representing the endpoint of the last step.
  lastXEnd = int(stepData[stepData.length-1]);
}

//Handles keyboard input
void handleInput(){  
  if (leftDown)  playerX -= 4;
  if (rightDown) playerX += 4;
}

void keyPressed(){
  if (key == CODED){
      switch(keyCode){
        case LEFT:  leftDown = true;
                    break;
        case RIGHT: rightDown = true;
                    break;
        case UP:    
          if (playerOnGround){
            playerVelY = -20;
            playerOnGround = false;
            break;
          }
      }
    }
    else{
      if (key == ' ' && playerOnGround){
         playerVelY = -20;
         playerOnGround = false;
      }
    }
}

void keyReleased(){
  if (key == CODED){
    switch(keyCode){
        case LEFT:  leftDown = false;
                    break;
        case RIGHT: rightDown = false;
                    break;
      }
  }
}

void drawStepGraph(){
  stroke(255);
  
  //draw each step
  for(int i = 0; i < xPositions.length - 1; i++){
    line(xPositions[i], yPositions[i], xPositions[i+1], yPositions[i]);
  }
  
  // the last one needs to be drawn differently since the endPoint is not defined by a "next step".
  line(xPositions[xPositions.length - 1], 
       yPositions[yPositions.length - 1], 
       lastXEnd, 
       yPositions[yPositions.length - 1]);
}

void drawMario(){
  image(mario, playerX - mario.width / 2, playerY - mario.height);
}

void drawText(){
  if (matchIndex >= 0)
  {
    println(xPositions.length);
    int xEnd = (matchIndex < xPositions.length - 1) ? xPositions[matchIndex + 1] : lastXEnd;
    text("X: " + xPositions[matchIndex] + "-" + xEnd + ", Y:" + yPositions[matchIndex],
        xPositions[matchIndex],
        yPositions[matchIndex] + 10,
        100,
        50);
  }
}

void updateCamera(){
  translate(-playerX + (SCREEN_WIDTH / 2), -playerY + (SCREEN_HEIGHT / 2));
}

void updatePlayer(){  
  performGravity();  
  performCollision();
  performDeathFix();
}

void performGravity(){
  lastPlayerY = playerY;
  if (!playerOnGround){
    playerY += playerVelY;
    playerVelY += 1;
  }
}

void performCollision(){
  //find the step mario's x component is over.  
  //could binary search since the list is ordered, but I'm lazy :)
  matchIndex = -1;
  for (int i = 0; i < xPositions.length - 1; i++){
    if (xPositions[i] < playerX && xPositions[i+1] > playerX){
      matchIndex = i;
      break;
    }
  }

  //check the last segment
  if (matchIndex == -1 && playerX > xPositions[0] && playerX < lastXEnd){
    matchIndex = xPositions.length - 1;
  } 
  
  playerOnGround = false;
  if (matchIndex >= 0){
      //clamp mario's height to the platform's
      if (playerY >= yPositions[matchIndex] &&
          lastPlayerY <= yPositions[matchIndex])
      {
        playerY = yPositions[matchIndex];
        playerVelY = 0;
        playerOnGround = true;
      }
  }
}

void performDeathFix(){
  for (int i = 0; i < yPositions.length; i++){
    //println(playerY + ", " + yPositions[i]);
    if (playerY - 1000 < yPositions[i]){
      return;
    }
  }
  
  resetPlayer();
}
