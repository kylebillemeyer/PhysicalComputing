import java.util.*;
import java.lang.Math;

final int PUCK_RADIUS = 15;
final int NUM_PLAYERS = 2;
final int FLICK_RADIUS = 40;

float line1;
float line2;
float line3;
float boardLeft;
float boardRight;
int boardTop;
int boardBot;
float halfWidth;

int turn;
int currentPlayerTurn;
boolean turnStart;
boolean dragMoved;
PVector flickStartPos;
int flickStartTime;

ArrayList<Puck> pucks;

void setup(){
  size(400, 700);
  
  line1 = 20 + (height * .1);
  line2 =  20 + (height * .2);
  line3 = 20 + (height * .3);
  boardLeft = width * .25;
  boardRight = width * .75;
  boardTop = 10;
  boardBot = height - 10;
  halfWidth = width * .5;
  
  pucks = new ArrayList<Puck>();
  switchTurns();
}

void draw(){
  background(0);
  
  rect(boardLeft, 20, halfWidth, height - 40);
  line(boardLeft, line1, boardRight, line1);
  line(boardLeft, line2, boardRight, line2);
  line(boardLeft, line3, boardRight, line3);
  
  textSize(32);
  fill(0);
  float halfLine = (line1 - 20) / 2;
  text("3", halfWidth - 10, line1 - halfLine);
  text("2", halfWidth - 10, line2 - halfLine);
  text("1", halfWidth - 10, line3 - halfLine); 
  fill(255);
  
  boolean anyMoving = false;
  for(Puck p : pucks){
     p.update();
   }
   
   handleCollisions();
   clipPucks();
   
   for(Puck p : pucks){
     p.draw();
     anyMoving |= p.velocity.mag() != 0;
   }
   
   if (!turnStart && !anyMoving){
     switchTurns();
   }
}

void mousePressed(){
  PVector mouse =  new PVector(mouseX, mouseY);
  if (turnStart && pucks.get(pucks.size() - 1).containsPoint(mouse)){
      flickStartPos = mouse;
  }  
}

void mouseDragged(){
  if (flickStartPos != null){    
    PVector offset = PVector.sub(new PVector(mouseX, mouseY), flickStartPos);
    if (dragMoved){
      if (offset.mag() > FLICK_RADIUS){
        offset.normalize();
        shootPuck(offset, millis() - flickStartTime);
        turnStart = false;
        flickStartPos = null;
        dragMoved = false;
      }
    }
    else{
      dragMoved = offset.mag() != 0;      
      flickStartTime = millis();
    }    
  }
}
 
Puck createPuck(){
  return new Puck(new PVector(width * .5, height * .95), 
    new PVector(0, 0), 
    currentPlayerTurn);
}

void switchTurns(){  
  pucks.add(createPuck());
  turnStart = true;
  currentPlayerTurn = (currentPlayerTurn + 1) % NUM_PLAYERS;
}

void shootPuck(PVector direction, float flickTime){
  pucks.get(pucks.size() - 1).velocity = 
    PVector.mult(direction, FLICK_RADIUS / (flickTime / 20));
}
  

void handleCollisions(){
  for(int i = 0; i < pucks.size(); i++){
    int remaining = pucks.size() - i;
    for(int j = 0; j < pucks.size(); j++){
        if (i != j)
        pucks.get(i).performCollision(pucks.get(j));
    }
  }
}

boolean onBoard(Puck puck){
  return puck.position.x > boardLeft  || 
         puck.position.x < boardRight || 
         puck.position.y < boardTop   ||
         puck.position.y > boardBot;
}

void clipPucks(){
  ArrayList<Puck> delList = new ArrayList<Puck>();
  for(Puck puck : pucks){
    if (puck.position.x < boardLeft    || 
          puck.position.x > boardRight || 
          puck.position.y < boardTop   ||
          puck.position.y > boardBot){
        delList.add(puck);
    }
  }
  
  for(Puck p : delList){
    pucks.remove(p);
  }
}

class Puck {
  PVector position;
  PVector velocity;
  int player;
  
  public Puck(PVector position, PVector velocity, int player){
    this.position = position;
    this.velocity = velocity;
    this.player = player;
  }
  
  void update(){
    position.add(velocity);
    velocity.mult(.97);
    if (Math.abs(velocity.x) < .01) velocity.x = 0;
    if (Math.abs(velocity.y) < .01) velocity.y = 0; //friction + clamping
  }
  
  boolean containsPoint(PVector point){
    return PVector.sub(point, position).mag() < PUCK_RADIUS;
  }
  
  void performCollision(Puck p){
    if (PVector.sub(p.position, position).mag() < 2 * PUCK_RADIUS){
      float storeX = velocity.x;
      float storeY = velocity.y;
      velocity.x = p.velocity.x;
      velocity.y = p.velocity.y;
      p.velocity.x = storeX;
      p.velocity.y = storeY;
 
      System.out.println("a: " + velocity.x + ", b: " + p.velocity.x);     
      
      position.x += velocity.x;
      position.y += velocity.y;
      p.position.x += p.velocity.x;
      p.position.y += p.velocity.y;     
    }
  }
 
  void fix(float fixAmt, PVector offset){
    position.add(PVector.mult(offset, fixAmt));
  }
  
  void draw(){
     if (player == 1){
       fill(255, 0, 0);
     }
     else{
       fill(0, 0, 255);
     }
     
    ellipse(position.x, position.y, 2 * PUCK_RADIUS, 2 * PUCK_RADIUS);
    
    fill(255);
  }
}
