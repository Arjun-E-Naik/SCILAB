# SCILAB Image Processing Utilities

A small collection of Scilab (.sci) implementations of common image-processing routines and test harnesses. This repository aims to provide simple, portable, and well-tested Scilab functions for educational and prototyping use.

Core features
- `bwmorph_old.sci` — Reference Zhang-Suen thinning implementation (loop-based).
- `bwmorph_new.sci` — LUT-accelerated Zhang-Suen thinning (faster implementation).
- `immse/`, `Imgradientxy/`, `Otsuthresh/` — Other utility functions with tests.
- `tests/` — Test scripts and a runner to validate behavior non-interactively.

Requirements
- Ubuntu or compatible Linux
- Scilab (scilab-cli) installed

Quick start
1. Install Scilab:

```bash
sudo apt-get update
sudo apt-get install -y scilab scilab-cli
```

2. Run the bwmorph demo:

```bash
scilab-cli -nb -f tests/run_bwmorph.sci
```

3. Run the complete test suite:

```bash
bash tests/run_all_tests.sh
```

Usage examples

- Thinning a binary image with the new implementation:

```scilab
exec('bwmorph/bwmorph_new.sci');
I = zeros(7,7);
I(3:5,3:5) = 1;
out = bwmorph_new(I, 'thin');
disp(out);
```

- Using the denoise operation:

```scilab
exec('bwmorph/bwmorph_new.sci');
noisy = rand(20,20) > 0.5;
den = bwmorph_new(noisy, 'denoise');
disp(den);
```

Testing

- Run a single function test with `scilab-cli -nb -f tests/test_imgradientxy.sci`.
- Run the full test runner with `bash tests/run_all_tests.sh`.

Contributing

Contributions are welcome. Please:
- Fork the repository
- Make changes on a feature branch
- Add or update tests where applicable
- Open a pull request with a clear description of changes

License

This project is MIT licensed. See the `LICENSE` file for details.

Repository

https://github.com/Arjun-E-Naik/SCILAB

