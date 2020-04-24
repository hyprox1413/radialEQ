import processing.sound.*; //<>// //<>//

FFT fft;
Amplitude amplitude;
SoundFile in;
AudioIn inn;
int bands = 1024;
float[] spectrum;
float barWidth = 20;
Bar[] bars = new Bar[bands];
int mem = 5;
int roof = 16;
float scale = 0.4;
Bar amp;
float dotDepth = 10;
boolean donutMade = false;

File musicFolder;
File[] music;
ArrayList<File> songsNotPlayed;
SoundFile song;
ArrayList<File> songQueue;
int songPlaying = 0;
int framesPlayed = 0;

PShape makeDonut(float innerRadius, float outerRadius, float steps) {
  PShape s = createShape();
  s.beginShape();
  for (float a=0; a<TAU; a+=TAU/steps) {
    s.vertex(outerRadius*cos(a), outerRadius*sin(a));
  }
  s.beginContour();
  for (float a=0; a<TAU; a+=TAU/steps) {
    s.vertex(innerRadius*cos(-a), innerRadius*sin(-a));
  }
  s.endContour();
  s.noStroke();
  s.endShape(CLOSE);
  return s;
}

class Bar {
  float[] history;
  int memory;
  PShape donut;
  Bar(int m) {
    memory = m;
    history = new float[memory];
    for (int i = 0; i < history.length; i ++) {
      history[i] = 0;
    }
  }

  void update() {
    for (int i = history.length - 1; i > 0; i --) {
      history[i] = history[i - 1];
    }
  }

  float val() {
    float total = 0;
    for (int i = 0; i < history.length; i ++) {
      total += history[i];
    }
    return total / history.length;
  }
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == 1) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == 2) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}

void vignette() {
  color c1 = color(150);
  color c2 = color(0);
  setGradient(0, 0, width / 6, height, c2, c1, 2);
  setGradient(width * 5 / 6, 0, width / 6, height, c1, c2, 2);
}

void border() {
  //fill(amp.val() * 255 > 255 ? 255 : amp.val() * 255);2
  fill(0);
  noStroke();
  rect(0, 0, width, 20);
  rect(0, 0, 20, height);
  rect(width - 20, 0, 20, height);
  rect(0, height - 20, width, 20);
}

void dots() {
  noStroke();
  for (float i = dotDepth; i >= 0; i --) {
    fill(255, 255 * (amp.val() / 2 > i / dotDepth ? min(dotDepth * (amp.val() / 2 - i / dotDepth), (dotDepth - i) / dotDepth) : 0));
    pushMatrix();
    translate(width / 2, height / 2);
    scale((dotDepth - i) / dotDepth);
    translate(- width / 2, - height / 2);
    for (float x = width / 8 / 2; x < width; x += width / 8) {
      for (float y = height / 6 / 2; y < height; y += height / 6) {
        ellipse(x, y, sqrt(width * width + height * height) * scale * 0.01, sqrt(width * width + height * height) * scale * 0.01);
      }
    }
    popMatrix();
  }
}

void checkSongOver() {
  framesPlayed ++;
  println(framesPlayed + " " + song.duration() * 60);
  if (framesPlayed > song.duration() * 60) {
    skipSong();
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    skipSong();
  } else if (mouseButton == RIGHT) {
    rewindSong();
  }
}

void setup() {
  fullScreen(P2D);
  background(255);

  spectrum = new float[bands / roof];

  barWidth = roof * width / bands;

  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  amplitude = new Amplitude(this);
  musicSetup();
  queueAdd();
  playSong();

  for (int i = 0; i < bars.length; i ++) {
    bars[i] = new Bar(mem);
  }

  amp = new Bar(10);

  for (int i = bands / roof - 1; i >= 0; i--) {
    bars[i].donut = makeDonut(sqrt(width * width + height * height) * scale * i / 2 / (bands / roof - 1), sqrt(width * width + height * height) * scale * (i + 1) / 2 / (bands / roof - 1), 80);
  }
}      

void draw() {
  background(0);
  //vignette();
  fft.analyze(spectrum);

  dots();

  fill(150);
  noStroke();
  //ellipse(width / 2, height / 2, sqrt(width * width + height * height) * scale * 1.05, sqrt(width * width + height * height) * scale * 1.05);

  amp.history[0] = amplitude.analyze();
  for (int i = bands / roof - 1; i >= 0; i--) {
    bars[i].history[0] = spectrum[i]; //<>//
    noStroke();
    bars[i].donut.setFill(color(255, bars[i].val() * 4 * 255 > 255 ? 255 : bars[i].val() * 4 * 255));
    shape(bars[i].donut, width / 2, height / 2);  
    bars[i].update();
  }
  border();
  amp.update();
  checkSongOver();
}
