//
// Test of the IndepSaw class
//
// Give pmf as list of arguments
//

float pdist[0];

if (me.args()) {
  for (0 => int i; i < me.args(); i++) {
    pdist << Std.atoi(me.arg(i));
  }
} else {
  [0.0,1,0,1,0, 0, 2, 1, 0, 1, 0, 0, 1, 0.5] @=> pdist;
}

IndepSaw ids => dac;

ids.init(pdist, 440, 0.5);

while (true) {
  1::second => now;
}
