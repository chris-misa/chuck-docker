//
// Implements a descrete random variate based on the given probability mass function.
// Note that the given PMF does not need to be normalized.
//
// 2019, Chris Misa
//
//
// Methods of note:
//
// fun void init(float new_pmf[]);
//   Initialize with the given (psudo) probability mass function.
//
// fun int next();
//   Returns the next sample of the random variate given it's current pmf.
//
// fun void to(float new_pmf[], dur dur_to_new);
//   Morphs from current pmf to new_pmf over given duration.
//   For now, new pmf must have same length as original pmf.
//   Probably want to spork this in its own shred.
//
// fun float E()
//   Returns the current expected value (mean) calculated from the CDF.
//
// Debug methods:
//
// fun void print_cdf();
//   Dumps the current computed distribution function on chuck stdout.
//

public class Indep
{
  float cdf[0];
  float next_cdf[0];
  float prev_cdf[0];
  10::ms => dur dt;

  fun float [] get_cdf(float new_pmf[])
  {
    float new_cdf[0];
    0 => float max;
    new_cdf << 0.0;
    for (0 => int i; i < new_pmf.cap(); i++) {
      new_pmf[i] + max => max;
      new_cdf << max;
    }
    for (0 => int i; i < new_cdf.cap(); i++) {
      new_cdf[i] / max => new_cdf[i];
    }
    return new_cdf;
  }

  fun void copy_array(float a[], float b[])
  {
    a.size() => b.size;
    for (0 => int i; i < a.size(); i++) {
      a[i] => b[i];
    }
  }

  //
  // Initialize pmf as array of floats
  //
  fun void init(float new_pmf[])
  {
    (new_pmf) => get_cdf @=> cdf;
  }

  //
  // Get next random value
  // (Binary search to pass a uniform variate through inverse of cdf)
  //
  fun int next()
  {
    Math.randomf() => float unif;
    0 => int l;
    cdf.cap() => int r;
    r / 2 => int m;
    while (true) {
      if (cdf[m] >= unif && unif >= cdf[m-1]) {
        return m;
      } else if (unif > cdf[m]) {
        m => l;
        (l + r) / 2 => m;
      } else {
        m => r;
        (l + r) / 2 => m;
      }
    }
  }

  //
  // Ramp from prev to next cdf
  //
  fun void to(float new_pmf[], dur dur_to_new) 
  {
    if (new_pmf.size() + 1 != cdf.size()) {
      <<< "Indep::to() only supports same-size arrays" >>>;
    } else {
      (cdf, prev_cdf) => copy_array;
      (new_pmf) => get_cdf @=> next_cdf;
      0.0 => float n;
      dt / dur_to_new => float dn;

      while (n < 1.0) {
        dt => now;
        dn +=> n;
        for (0 => int i; i < cdf.size(); i++) {
          prev_cdf[i] * (1.0 - n) + next_cdf[i] * n => cdf[i];
        }
      }
    }
  }

  //
  // Computes the expected value off the current CDF
  // Note that is is wrt to 1-based length where are .next() is wrt 0-based values
  //
  fun float E()
  {
    0.0 => float sum;
    for (1 => int i; i < cdf.size(); i++) {
      (cdf[i] - cdf[i - 1]) * i +=> sum;
    }
    return sum;
  }

  //
  // Debug dump of computed cdf
  //
  fun void print_cdf()
  {
    for (0 => int i; i < cdf.cap(); i++) {
      <<< "Index:", i, "is", cdf[i] >>>;
    }
  }
}
