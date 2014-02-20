## Stata Bartels Test
A Stata implementation of the Bartels Test for serial correlation.

See "The Rank Version of von Neuman's Ratio Test for Randomness". **Robert Bartels**, _Journal of the American Statistical Association_, Vol. 77, No. 377 (Mar.,1982), pp. 40-46

## Installation

```bash
# Example copies the necessary files to
# the personal ado directory on Mac OS X, but can easily 
# modify to your own OS

$ git clone https://github.com/coderigo/stata-bartels-test.git

# Create the directory for user-installed packages starting with `s`
# (optional - only needed if directory does not already exist)
$ mkdir ~/Library/Application Support/Stata/ado/plus/b

# Copy the files needed for `bartelsTest` to the above directory
$ mv stata-bartels-test/bartels* ~/Library/Application Support/Stata/ado/plus/b
```

## Usage

```javascript
/* Using the data from the Bartels 1982 paper */
bartelsTest delta_real_undist_income
bartelsTest delta_real_undist_income, alternative("pos") /* Positive autocorrelation alternative hypothesis */
bartelsTest delta_real_undist_income, alternative("neg") /* Negative autocorrelation alternative hypothesis */
```

## Contributing
Happy to take contributions.
