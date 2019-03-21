//
// Synthesize samples from a descrete independent random variable by given pmf
//
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
  // Debug dump of computed cdf
  //
  fun void print_cdf()
  {
    for (0 => int i; i < cdf.cap(); i++) {
      <<< "Index:", i, "is", cdf[i] >>>;
    }
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
}
