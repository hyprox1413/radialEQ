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
  try{  
    song = new SoundFile(this, "music/" + songQueue.get(songPlaying).getName());
  } catch (IndexOutOfBoundsException e) {
    queueAdd();
    songPlaying = 0;
    song = new SoundFile(this, "music/" + songQueue.get(songPlaying).getName());
  }
  song.play();
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
