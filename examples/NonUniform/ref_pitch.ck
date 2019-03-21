//
// Reference pitch for tuning stochastic oscs
//

SinOsc s => dac;

440 => s.freq;
0.5 => s.gain;

while (true) {
  5::second => now;
}
