#import "../common.typ": *

= Use Case

---

== What is Anomaly Detection?
#title-slide[Anomaly Detection][What and Why?]

#info[Anomaly detection is the process of identifying patterns, data points, or observations that deviate significantly from expected behaviour in a dataset or data stream.]

#v(8pt)

#text(weight: "bold", fill: important-color)[In the context of sensor data:]

#v(4pt)

#block(fill: bg-light, radius: 4pt, inset: 10pt, width: 100%)[
  A sensor reading is anomalous when it falls outside the statistical or physical envelope of normal operation — whether a single spike, a slow drift, or a structural change in the signal's distribution.
]

---

#important[Why does it matter?]

#v(4pt)

/ Early fault detection: catch equipment degradation before catastrophic failure
/ Safety: trigger alerts when process variables exceed safe operating limits
/ Quality control: reject defective products in real-time production lines
/ Cost reduction: unplanned downtime costs orders of magnitude more than preventive action
/ Data integrity: flag sensor malfunctions and corrupted measurements automatically

#v(10pt)

#block(fill: rgb("#FFF3CD"), radius: 4pt, inset: 8pt, width: 100%)[
  ⚡ *Key insight* — in industrial systems, the cost of a missed anomaly _(false negative)_ almost always exceeds the cost of a false alarm. Detection sensitivity must be tuned accordingly.
]

---

== Approaches to Anomaly Detection
#title-slide[Three broad families of methods][Statistical, Machine Learning, and Rule-Based]

#hl[Statistical Methods]

#v(3pt)

Model the signal as a stochastic process and flag deviations beyond a threshold.
Assumes a known (or learnable) underlying distribution.

#v(3pt)

/ Threshold-based: fixed or adaptive bounds ($mu plus.minus k sigma$, IQR fences)
/ Moving average / EWMA: track rolling mean and variance; alert on exceedance
/ CUSUM: cumulative sum control chart; sensitive to small persistent shifts
/ Spectral methods: FFT / PSD to detect unexpected frequency components

#v(8pt)

---

#hl[Machine Learning Methods]

#v(3pt)

Learn a model of normality from historical data; anomalies are points the model cannot explain or reconstruct well.

#v(3pt)

/ Unsupervised: Isolation Forest, One-Class SVM, $k$-NN density estimation
/ Reconstruction-based: Autoencoder, VAE; high reconstruction error $=>$ anomaly
/ Forecasting-based: LSTM, Transformer predict next value; residual triggers alert

---

#hl[Signal Processing Methods]

#v(3pt)

Exploit the time-frequency structure of the signal without explicit statistical assumptions.

#v(3pt)

/ FFT / STFT: detect spurious harmonics or missing spectral peaks
/ Wavelet decomposition: localise transient anomalies in both time and frequency
/ Hilbert–Huang transform: non-stationary, non-linear signal analysis

#v(10pt)

#block(fill: rgb("#FFF3CD"), radius: 4pt, inset: 8pt, width: 100%)[
  ⚡ *Practical choice* — signal processing methods excel at interpretability and low latency, making them ideal as a first detection layer in real-time embedded systems before heavier ML inference.
]

---

== Fourier Analysis for Sensor Data
#title-slide("Fourier Analysis", "Anomaly Detection in Sensor Data")

=== Continuous Fourier Transform (CFT)

#info[Any periodic _(or integrable)_ signal $x(t)$ can be decomposed into a sum of sinusoids, each characterised by a frequency $f$, an amplitude, and a phase.]

#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  [
    // #text(weight: "bold", fill: red)[Continuous Fourier Transform (CFT)]

    #block(
      fill: bg-light,
      radius: 4pt,
      inset: 8pt,
      width: 100%,
      [
        $ X(f) = integral_(-infinity)^(+infinity) x(t) times e^(-2 j pi f t) dif t $ <eq:analysis>

        #v(4pt)
        $ x(t) = integral_(-infinity)^(+infinity) X(f) times e^(+2 j pi f t) dif f $ <eq:synthesis-inverse>
      ],
    )
  ],

  [
    #text(weight: "bold", fill: amber)[Properties]

    #table(
      columns: (auto, 1fr),
      stroke: none,
      gutter: 1pt,
      [_Linearity_], [$ alpha x + beta y arrow.r alpha X + beta Y $],
      [_Shift_], [$ x(t-t_0) arrow.r X(f) e^(-2 j pi f t_0) $],
      [_Convolution_], [$ x(t) convolve h(t) arrow.r X(f) dot H(f) $],
      [_Parseval_], [$ integral |x|^2 dif t = integral |X|^2 dif f $],
    )
  ],
)

#v(6pt)
#block(
  fill: important-color.lighten(50%),
  radius: 4pt,
  inset: 7pt,
  width: 100%,
  text[⚡ Unexpected frequency components or sudden spectral shifts betray faults in sensors  and machinery.],
)

---

=== Discrete Fourier Transform (DFT)

#text(weight: "bold", fill: accent)[Naïve DFT]
#block(
  fill: bg-light,
  radius: 4pt,
  inset: 8pt,
  width: 100%,
  [
    For a sequence $x[n]$, $n = 0, dots, N-1$:

    $
      X[k] = sum_(n=0)^(N-1) x[n] times W_N^(k n) quad "and" quad x[n] = frac(1, N) sum_(k=0)^(N-1) X[k] times W_N^(-k n) quad "where" quad W_N = e^(-2 j pi / N)
    $ <eq:naive-DFT>
  ],
)

#grid(
  columns: (auto, auto),
  gutter: 14pt,
  [
    ```julia
    N = 1024
    I = 0:N-1
    w = exp(-2 * pi * im / N)
    DFT = w .^ (I' .* I)
    using Plots
    heatmap(real(DFT))
    ```
  ],
  [
    #align(center)[
      #image("../images/DFT_hm.svg", width: 85%)
    ]
  ],
)

---

#text(weight: "bold", fill: accent)[Cooley–Tukey _(divide-and-conquer)_]
#grid(
  columns: (auto, auto),
  gutter: 2pt,
  [
    #block(
      fill: bg-light,
      radius: 4pt,
      inset: 8pt,
      width: 100%,
      [
        Split $N = 2^p$ into even / odd sub-sequences:

        $
          X[k] = underbrace(sum_(m=0)^(N\/2-1) x[2m] times W_(N\/2)^(m k), E[k]) + W_N^k underbrace(sum_(m=0)^(N\/2-1) x[2m+1] times W_(N\/2)^(m k), O[k])
        $
        Butterfly recursion until $N=1$.
      ],
    )
  ],
  [
    #align(center)[
      #image("../images/butterfly.svg", width: 60%)
    ]
  ],
)

---

#align(center)[
  #image("../images/fft.svg", width: 60%)
]

---

#text(weight: "bold", fill: amber)[Complexity]

#align(center)[
  #table(
    columns: (auto, auto),
    stroke: 0.4pt + muted,
    inset: 5pt,
    fill: (col, row) => if row == 0 { rgb("#23373b") } else if calc.odd(row) { luma(240) } else { white },
    text(fill: white, weight: "bold")[Algorithm], text(fill: white, weight: "bold")[Cost],
    [Naïve DFT], [$cal(O)(N^2)$],
    [Cooley–Tukey FFT], [$cal(O)(N log_2 N)$],
  )]

#v(6pt)

#text(weight: "bold", fill: amber)[Practical notes for streaming sensors]

#list(
  [Choose $N = 2^p$ _(e.g. 512, 1024)_ for radix-2 FFT;],
  [Apply a window _(Hann, Hamming)_ to reduce spectral leakage;],
  [Use overlapping frames (50 %) to track transient anomalies.],
)

---

#align(center)[
  #image("../images/anomaly-detection-fft.svg", width: 65%)
]

#url-block("codes/anomaly-detection-fft.jl")

---

=== Power Spectral Density (PSD)

#block(
  fill: bg-light,
  radius: 4pt,
  inset: 8pt,
  width: 100%,
  [
    The PSD is the Fourier transform of the autocorrelation function $R_x (tau)$:
    $ S_(x x) (f) = integral_(-infinity)^(+infinity) R_x (tau) times e^(-2 j pi f tau) dif tau $

    #v(4pt)
    Equivalently:
    $ S_(x x)(f) = lim_(T -> infinity) frac(1, T) lr(| X_T (f) |)^2 $ <eq:wiener-khinchin>

  ],
)

#v(6pt)
*Total power (Parseval)*

$
  P_x = integral_(-infinity)^(+infinity) S_(x x)(f) dif f
  = overline(x^2(t))
$

---

*Estimation methods*

#table(
  columns: (auto, 1fr),
  stroke: 0.4pt + muted,
  inset: 5pt,
  fill: (col, row) => if row == 0 { rgb("#23373b") } else if calc.odd(row) { luma(240) } else { white },
  text(fill: white, weight: "bold")[Method], text(fill: white, weight: "bold")[Description],
  [Periodogram \ _(high variance)_], [$ hat(S)(f) = frac(1, N) lr(| X[k] |)^2 $],
  [Welch \ _(low variance)_], [Average periodograms over overlapping windows],
  [Bartlett \ _(special case of Welch)_], [Non-overlapping segments],
  [AR / Burg \ _(high resolution for short records)_], [Parametric],
)

#v(6pt)
#block(
  fill: rgb("#FFF3CD"),
  radius: 4pt,
  inset: 7pt,
  width: 100%,
  text[
    ⚡ *Anomaly detection* — monitor baseline PSD; flag frames where spectral energy in a band exceeds a threshold $gamma$ _(e.g. $mu + 3sigma$ from a reference window)_.
  ],
)

---

#align(center)[
  #image("../images/anomaly-detection-psd.svg", width: 65%)
]

#url-block("codes/anomaly-detection-psd.jl")
