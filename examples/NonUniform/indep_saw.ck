//
// Class to generate saw waves with empirically distributed slopes
// (Based on Indep independant descrete random variate generator class)
//
// Example: {
//   IndepSaw ids => dac;
//   ids.init([0.0, 0, 1, 2, 3, 2, 1], 220, 0.5);
//   while (true) { 1::second => now; }
// }
//

public class IndepSaw extends Chubgraph
{
  Step s => Gain g => outlet;
  0.0 => s.next;

  float f;     // Target frequency
  float a;     // Current sample value in [-1.0, 1.0]
  float da;    // Sample value step
  float n;     // Number of steps per cycle
  Indep dm;    // Indep object for generating random variates
  int pmf_len; // Number of elements in pmf

  //
  // Sample update function, sporked by init
  //
  fun void next_frame()
  {
    while (true) {
      a => s.next;
      da +=> a;
      if (a > 1.0) {
        2.0 -=> a;
      }
      // Generate delta-time with dm.E() at f
      ((dm.next() * 1000) / (dm.E() * f * n))::ms => now;
    }
  }

  //
  // Start playing the saw with the given target frequencey, gain, and pmf
  //
  fun void init(float new_pmf[], float new_f, float new_g)
  { 
    new_g => g.gain;

    dm.init(new_pmf);
    new_pmf.cap() => pmf_len;

    new_f => f;

    -1.0 => a;
    0.1 => da;
    2.0 / da => n;

    spork ~ next_frame();
  }

  //
  // Overload with gain set
  //
  fun void init(float new_pmf[], float new_f)
  {
    init(new_pmf, new_f, 1.0);
  }
}
