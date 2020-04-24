import processing.sound.*; //<>//

FFT fft;
Amplitude amplitude;
SoundFile in;
int bands = 1024;
float[] spectrum;
float barWidth = 20;
Bar[] bars = new Bar[bands];
int mem = 5;
int roof = 16;
float scale = 0.4;
Bar amp;

File musicFolder;
File[] music;
ArrayList<File> songsNotPlayed;
SoundFile song;
ArrayList<File> songQueue;
int songPlaying = 0;
int framesPlayed = 0;

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
  
  noCursor();
}      

void draw() {
  background(0);
  fft.analyze(spectrum);

  dots();
  
  amp.history[0] = amplitude.analyze();
  for (int i = bands / roof - 1; i >= 0; i--) {
    bars[i].history[0] = spectrum[i];shape(bars[i].donut, width / 2, height / 2);  
    bars[i].update();
  }
  border();
  amp.update();
  checkSongOver();
}
