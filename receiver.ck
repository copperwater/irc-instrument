/* Good nicks:
 * a1a2, b1b5, d357r0y3r
 */

fun int hash(string nick) {
  /* corned beef hash algorithm, as seen in Data Structures Homework 4 */
  0xDEADBEEF => int theThing;
  for(0=> int i; i<nick.length(); ++i) {
    nick.charAt(i) => int thisChar;
    theThing ^ ((thisChar << (thisChar & 31)) & 0xFFFFFFFF) => theThing;

    for(7=> int bit; bit >= 0; --bit) {
      if((thisChar >> bit) & 1)
        (theThing >> bit) ^ (theThing << (32-bit)) => theThing;
      else {
        (theThing ^ (((theThing >> 16) & 65535) - 1)) => theThing;
        theThing ^ (thisChar << 24) ^ (-thisChar - 1) => theThing;
      }
    }
  }

  // goes into long long int territory
  return (theThing << 32) >> 32;
}

fun int isVowel(int chr) {
  if(chr == 65 || chr == 69 || chr == 73 || chr == 79 || chr == 85 || chr == 89 ||
     chr == 97 || chr == 101 || chr == 105 || chr == 111 || chr == 117 || chr == 121) {
     return 1;
  }
  return 0;
}

/** Given a string that is part of a message, return a sequence of numbers
 * intended to be transposed into pitch values.
 * The string is assumed not to contain any spaces.
 */
fun int numSyllables(string word) {
  /* without any advanced language processing,
   * have to estimate the number of syllables in the word
   * Algorithm:
   * 1. Remove trailing e, if it exists.
   * 2. Count number of vowel clusters, regarding y as always a vowel.
   * 3. If zero, set to 1.
   * 4. Return this number.
   */
  word.charAt(word.length()-1) => int lastLetter;
  if(lastLetter == 69 || lastLetter == 101) {
    word.substring(0, word.length()-1) => word;
  }

  0 => int vowelCount;
  0 => int lastWasVowel;
  for(0 => int i; i<word.length(); ++i) {
    if(isVowel(word.charAt(i))) {
      if(!lastWasVowel) {
        vowelCount + 1 => vowelCount;
      }
      1 => lastWasVowel;
    }
    else {
      0 => lastWasVowel;
    }
  }
  if(vowelCount == 0) {
    1 => vowelCount;
  }
  return vowelCount;
}

fun void handleMsg(string msg) {
  // get sending nick, which is the first space-delimited substring
  msg.find(' ') => int firstSpace;
  msg.substring(0,firstSpace) => string nick;
  msg.erase(0, firstSpace+1);

  // Psuedorandomly hash the nickname
  hash(nick) => int nickHash;

  // Seed the RNG with this hash.
  // This will allow for any amount of random numbers to be generated
  // deterministically from this same nick.
  Std.srand(nickHash);

  // create and instantiate array of overtone objects
  SinOsc gens[8];

  SinOsc mod;
  Math.random2(30,1200) => float modfreq;
  modfreq => mod.freq;
  Math.random2(50,1000) => float modindex;
  modindex => mod.gain;

  Gain master => JCRev rev => Pan2 p => dac;
  0.1 => float defaultGain;
  defaultGain => master.gain;

  (Math.randomf() * 2) - 1 => float panamt;
  panamt => p.pan;
  Math.randomf() / 12 => float revmix;
  revmix => rev.mix;
  Math.random2(-20,20) - 8 => int pitchshift;

  <<< "Profile of", nick, ":" >>>;
  <<< "modfreq", modfreq, "modgain/index", modindex >>>;
  <<< "panned", panamt >>>;
  <<< "reverbed", revmix >>>;
  <<< "shifted", pitchshift >>>;

  mod => SinOsc tonic => master;
  tonic =< master;

  // initialize gains to overtone values,
  // route everything to master
  for(0=>int i; i < 8; ++i) {
    (10- i) * Math.randomf() / 16 => gens[i].gain;
    Math.randomf() => gens[i].phase;
    2 => gens[i].sync;
    mod => gens[i] => master;
  }

  0 => int wordParsing;
  if (! wordParsing) {
    for(0 => int i; i < msg.length(); ++i) {
      msg.charAt(i) => int ascii;
      // <<< ascii >>>;
      if(ascii == 32) {
        //space; rest
        0 => master.gain;
      }
      else {
        defaultGain => master.gain;
        ascii + pitchshift => ascii;
        Std.mtof(ascii) => tonic.freq;
        for(0=>int i; i<8; ++i) {
          Std.mtof(ascii) * (i+1) => gens[i].freq;
        }
      }

      80::ms => now;
    }
  }
  else {
    StringTokenizer tok;
    tok.set(msg);
    while(tok.more() > 0) {
      defaultGain => master.gain;
      tok.next() => string word;
      Std.srand(hash(word));
      numSyllables(word) => int syll;
      for(0 => int i; i<syll; ++i) {
        Math.random2(40, 120) => int pitch;
        pitch + pitchshift => pitch;
        Std.mtof(pitch) => tonic.freq;
        for(0=>int i; i<8; ++i) {
          Std.mtof(pitch) * (i+1) => gens[i].freq;
        }
        150::ms => now;
      }
      0 => master.gain;
      100::ms => now;
    }
  }

  0 => master.gain;
}

/*
Blit b => dac;
0.5 => b.gain;
Std.mtof(80) => b.freq;
1 => b.harmonics;
500::ms => now;
2 => b.harmonics;
500::ms => now;
3 => b.harmonics;
500::ms => now;
1 => b.harmonics;
500::ms => now;
20 => b.harmonics;
500::ms => now;
*/

/* handleMsg("aosdict what are you doing today?   "); */
/* handleMsg("sdfsdf not much, you?   "); */
/* handleMsg("qerqer I've been doing homework all day :("); */

/** Main loop to catch OSC messages and spork them off into the
 * message handler, which will deal with all the sound control
 * and playing on its own. Naturally, it simply cleans itself up
 * when it's finished playing the sound from the message.
 */
//*
OscRecv orec;
6666 => orec.port;
orec.listen();

orec.event("/irc/message,s") @=> OscEvent string_event;
while(true) {
  string_event => now;
  while(string_event.nextMsg() != 0) {
    string_event.getString() @=> string privmsg;
    spork ~ handleMsg(privmsg);
  }
}
/**/


/* Parse nick out and ignore the first space
 * Give timbre based on words
 * 1: Break message up into a simple sequence of MIDI numbers mapped from ASCII values, maybe ignoring or resting on spaces.
 * 2: Estimate number of syllables from each word, break word up into that number, interpret letter clusters for sound or chords
 */
