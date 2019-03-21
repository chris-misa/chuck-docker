//
// Test of Indep class for pitch
//
//
// use : to separate cli args
//
// Maybe have some better interface:
//  ...:0*4:... rather than ...:0:0:0:0:...
//

100::ms => dur T;
T - (now % T) => now;

5::ms => dur attack;

Indep pitchs;
Indep gains;

float pdist[0];

if (me.args()) {
  for (0 => int i; i < me.args(); i++) {
    pdist << Std.atoi(me.arg(i));
  }
} else {
  [0.0,1,0,1,0, 0, 2, 1, 0, 1, 0, 0, 1, 0.5] @=> pdist;
}

pitchs.init(pdist);
gains.init([2.0, 0.5, 0.2, 0.1, 1, 0.3]);

SinOsc s => Envelope e => dac;

0.3 => s.gain;

while (true) {
  pitchs.next() + 50 => Std.mtof => s.freq;

  (gains.next() - 1) $ float / 6.0 => s.gain;

  attack => e.duration;
  e.keyOn();
  attack => now;
  
  T - attack => e.duration;
  e.keyOff();
  T - attack => now;
}
