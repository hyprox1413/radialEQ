void musicSetup() {
  musicFolder = new File("/Users/Hyprox1413/Documents/Processing/stellarEQ/data/music");
  music = musicFolder.listFiles();
  songsNotPlayed = new ArrayList<File>();
  songQueue = new ArrayList<File>();
}

void queueAdd() {
  for (File f : music) {
    songsNotPlayed.add(f);
  }
  while (!songsNotPlayed.isEmpty()) {
    int songNum = (int) (random(1) * songsNotPlayed.size());
    songQueue.add(songsNotPlayed.get(songNum));
    songsNotPlayed.remove(songNum);
  }
}

void playSong() {
  song = new SoundFile(stellarEQ.this, "music/" + songQueue.get(songPlaying).getName(), false);
  println("Loaded!"); //<>//
  song.play();
  fft = new FFT(this, bands);
  amplitude = new Amplitude(this);
  fft.input(song);
  amplitude.input(song);
  framesPlayed = 0;
}

void skipSong() {
  song.stop();
  songPlaying ++;
  playSong();
}

void rewindSong() {
  song.stop();
  playSong();
}
