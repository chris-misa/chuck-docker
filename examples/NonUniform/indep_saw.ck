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

  float f;
  float a;
  float da;
  float m;
  Indep dm;
  int pmf_len;

  fun void next_frame()
  {
    while (true) {
      a => s.next;
      da +=> a;
      if (a > 1.0) {
        2.0 -=> a;
      }
      (dm.next() * m / pmf_len)::ms => now;
    }
  }

  //
  // Start playing the saw with the given target frequencey, gain, and pmf
  //
  fun void init(float new_pmf[], float new_f, float new_g)
  { 
    new_g => g.gain;
    new_f => f;
    -1.0 => a;
    0.1 => da;
    2.0 / da => float n;
    1000 / (n * f) => m;
    dm.init(new_pmf);
    new_pmf.cap() => pmf_len;
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
