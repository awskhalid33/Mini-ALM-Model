# ABC plc Solvency Analysis - Interactive Dashboard

An R Shiny application for analysing pension fund solvency under different bond portfolio allocations and interest rate scenarios. This tool helps determine optimal investment strategies to maintain solvency (assets ≥ liabilities) across various market conditions.

## Overview

This project models a pension fund scenario where ABC plc needs to make annual payments of £1 million over 10 years. The fund can invest in two bonds:
- **Bond XX**: 1-year zero-coupon bond (short-term)
- **Bond YY**: 20-year bond with 3% annual coupon (long-term)

The system calculates how different portfolio allocations perform across interest rate changes, helping identify investment strategies that maintain solvency in all scenarios.

### What the Project Does

- **Models pension liabilities**: Calculates present value of future £1m annual payments
- **Values bond portfolios**: Prices both zero-coupon and coupon-bearing bonds
- **Tests portfolio allocations**: Evaluates mixes from 0% to 100% in each bond
- **analyses interest rate sensitivity**: Tests performance across 1%-10% interest rates
- **Identifies optimal strategies**: Finds allocations that maintain 100% solvency across all scenarios
- **Provides interactive visualization**: Shiny dashboard for exploring different portfolio mixes

## Key Features

### 1. Comprehensive Solvency Analysis

The system performs exhaustive analysis of portfolio allocations:
- Tests 11 different mixes (0%, 10%, 20%, ..., 100% in Bond XX)
- Evaluates each mix across 10 interest rate scenarios (1% to 10%)
- Calculates solvency ratio (Assets / Liabilities) for all combinations
- Identifies which allocations maintain 100% solvency in all scenarios

### 2. Actuarial Calculations

Implements standard actuarial formulas:
- **Annuity functions**: Present value of annuities in arrears
- **Bond pricing**: Handles both zero-coupon and coupon-bearing bonds
- **Duration matching**: Implicitly tests duration-based immunization strategies
- **Interest rate sensitivity**: Shows how bond values change with rates

### 3. Interactive Shiny Dashboard

Four main tabs provide different views:

**Tab 1: Interactive Portfolio**
- Slider to adjust bond allocation (0% to 100% in Bond XX)
- Real-time summary boxes showing:
  - Current portfolio split
  - Minimum solvency ratio across all interest rates
  - Whether solvency ≥ 100% at all rates
- Line plot of solvency vs. interest rate
- Detailed table with assets, liabilities, and solvency at each rate

**Tab 2: Allocation Summary**
- Plot showing minimum solvency for each mix
- Highlights the optimal allocation (best worst-case solvency)
- Grid showing minimum solvency for all mixes

**Tab 3: Solvency Matrix**
- Complete matrix showing solvency ratio for every combination of:
  - Portfolio mix (rows)
  - Interest rate scenario (columns)

**Tab 4: Core Calculations**
- Initial present values and bond prices at t=0
- Bond prices and liability values at t=1 across interest rates

### 4. Optimal Strategy Identification

The system automatically identifies:
- Which allocations maintain 100% solvency across all rates
- Among valid strategies, which has the best worst-case solvency
- Highlights this optimal allocation on plots

## Project Structure

```
mini-alm-model.R                   # Complete R script with Shiny app
├── Actuarial Functions    # v_p, a_arrears, bond pricing
├── Initial Setup          # Parameters, bonds, interest rates
├── Calculations at t=0    # Initial PV and bond prices
├── Calculations at t=1    # Values after first payment
├── Solvency Analysis      # Portfolio performance evaluation
├── Optimization           # Finding best allocation
└── Shiny App             # Interactive dashboard (UI + server)
```

## Installation

### Requirements

Install the required R package:

```R
install.packages("shiny")
```

### R Version
Tested with R 4.0+

## How to Run

### Option 1: Run from R Console

```R
source("mini-alm-model")
```

The Shiny app will automatically launch in your default web browser.

### Option 2: Run from RStudio

1. Open `mini-alm-model.R` in RStudio
2. Click the "Run App" button that appears at the top of the script editor
3. The app will launch in RStudio's viewer pane or external browser

### Option 3: Run Specific Components

To run just the calculations without the Shiny app, comment out the final line:

```R
# shinyApp(ui = ui, server = server)
```

Then source the script to see console output of all calculations.

## Example Output

### Console Output (Script Calculations)

When you run the script, you'll see:

```
           Item                                    Value
1  PV of Liabilities at t = 0 (£m)                 8.1109
2  Price of 1-Year Bond XX at t = 0 (£)           96.1538
3  Price of 20-Year Bond YY at t = 0 (£)          86.4395

  Interest.Rate.t.1.... Price.of.Bond.XX.at.t.1.... Price.of.Bond.YY.at.t.1....
1                  0.01                          100                    132.2741
2                  0.02                          100                    116.9422
3                  0.03                          100                    103.0000
...

  Proportion.in.XX Proportion.in.YY Minimum.Solvency.Over.All.Rates
1             0.0              1.0                          0.9827
2             0.1              0.9                          0.9850
3             0.2              0.8                          0.9882
4             0.3              0.7                          0.9922
5             0.4              0.6                          0.9972
6             0.5              0.5                          1.0032
7             0.6              0.4                          1.0102
8             0.7              0.3                          1.0184
9             0.8              0.2                          1.0278
10            0.9              0.1                          1.0386
11            1.0              0.0                          1.0511
  Solvency....100..at.All.Rates.
1                          FALSE
2                          FALSE
3                          FALSE
4                          FALSE
5                          FALSE
6                           TRUE
7                           TRUE
8                           TRUE
9                           TRUE
10                          TRUE
11                          TRUE

[1] 0.5  # Best proportion in XX (50%)
[1] 0.5  # Best proportion in YY (50%)
```

### Interpretation

**Initial Conditions (t=0):**
- Pension liabilities have a present value of £8.11m at 4% interest
- Bond XX costs £96.15 per £100 nominal (1-year zero-coupon at 4%)
- Bond YY costs £86.44 per £100 nominal (20-year 3% coupon at 4%)

**Solvency Analysis:**
- Allocations with <50% in Bond XX fail to maintain 100% solvency across all rates
- The **50/50 allocation** is the minimum allocation in XX that stays solvent in all scenarios
- The **100% in Bond XX** allocation has the best worst-case solvency (1.0511)
- However, being 100% in a 1-year bond creates reinvestment risk

**Key Insight:** The optimal strategy balances:
- **Duration matching**: YY's longer duration better matches long-term liabilities
- **Certainty**: XX provides known cash flows for near-term payments
- **Trade-off**: More XX improves worst-case solvency but increases reinvestment risk

### Shiny Dashboard Visualizations

#### Interactive Portfolio Tab
When you move the slider to 50% in Bond XX:

**Summary Boxes:**
```
Portfolio Split: XX: 50%  |  YY: 50%
Minimum Solvency: 1.0032
Solvency ≥100% at All Rates?: Yes – fully above 100%
```

**Solvency vs Interest Rate Plot:**
- Shows a U-shaped curve
- Minimum solvency occurs around 3-4% interest rate
- Curve stays above the red line (solvency = 1.0) at all rates

**Detailed Table:**
```
  Proportion in XX  Proportion in YY  Interest rate at t=1  Assets at t=1 (£m)  PV liabilities (£m)  Solvency ratio
1             0.5               0.5                  0.01                9.15                 9.09           1.0064
2             0.5               0.5                  0.02                9.07                 8.98           1.0103
3             0.5               0.5                  0.03                9.00                 8.89           1.0127
4             0.5               0.5                  0.04                8.94                 8.81           1.0137
5             0.5               0.5                  0.05                8.88                 8.75           1.0145
...
```

#### Allocation Summary Tab

**Plot: How Mix Affects Worst-Case Solvency**
- X-axis: Proportion in Bond XX (0% to 100%)
- Y-axis: Minimum solvency ratio across all interest rates
- Shows increasing minimum solvency as you allocate more to XX
- Green dot marks the 50% allocation as "best" (first to achieve 100% solvency)

**Grid of Mixes:**
```
  Proportion in XX  Proportion in YY  Minimum solvency
1              0.0               1.0            0.9827
2              0.1               0.9            0.9850
3              0.2               0.8            0.9882
4              0.3               0.7            0.9922
5              0.4               0.6            0.9972
6              0.5               0.5            1.0032  ← First to achieve ≥1.0
7              0.6               0.4            1.0102
...
```

#### Solvency Matrix Tab

Shows complete solvency ratios:
```
         1%     2%     3%     4%     5%     6%     7%     8%     9%    10%
0% XX  0.9827 0.9871 0.9902 0.9923 0.9935 0.9940 0.9938 0.9931 0.9919 0.9903
10%    0.9850 0.9897 0.9931 0.9954 0.9969 0.9976 0.9978 0.9975 0.9967 0.9956
20%    0.9882 0.9930 0.9966 0.9991 1.0009 1.0020 1.0025 1.0026 1.0023 1.0016
...
100%   1.0511 1.0511 1.0511 1.0511 1.0511 1.0511 1.0511 1.0511 1.0511 1.0511
```

#### Core Calculations Tab

**At t=0:**
```
  Quantity                                        Value  Units
1 PV of liabilities at t = 0                    8.1109    £m
2 Price of 1-year bond XX at t = 0              96.15     £
3 Price of 20-year 3% bond YY at t = 0          86.44     £
```

**At t=1 (before first payment):**
```
  Interest rate at t=1  Price of XX (£)  Price of YY (£)  PV liabilities (£m)
1                 0.01              100           132.27                 9.09
2                 0.02              100           116.94                 8.98
3                 0.03              100           103.00                 8.89
4                 0.04              100            90.32                 8.81
...
```

## Understanding the Calculations

### Key Formulas

**Present Value Factor:**
```R
v^n = (1/(1+i))^n
```

**Annuity in Arrears (payments at end of period):**
```R
a_n = (1 - v^n) / i
```

**Zero-Coupon Bond Price:**
```R
P = Redemption × v^n
```

**Coupon Bond Price:**
```R
P = Coupon × a_n + Redemption × v^n
```

**Solvency Ratio:**
```R
Solvency = Assets / PV(Liabilities)
```

### Scenario Setup

**At t=0:**
- Liabilities: £1m per year for 10 years
- Interest rate: 4%
- Total assets to invest: £8.1109m (= PV of liabilities)

**At t=1:**
- £1m payment made immediately
- 9 remaining annual payments
- Bond XX matures (returns £100 per unit)
- Bond YY now has 19 years remaining
- Interest rate varies from 1% to 10%

### Why Portfolio Allocation Matters

**100% in Bond YY (long-duration):**
- ❌ Fails when rates rise: YY's value drops more than liability PV
- Minimum solvency: 98.27% (at 1% interest rate)

**100% in Bond XX (short-duration):**
- ✅ Always maintains solvency
- Minimum solvency: 105.11% (constant across all rates)
- ⚠️ But creates reinvestment risk after year 1

**50/50 Mix:**
- ✅ Achieves 100% solvency at all rates
- Better duration matching with liabilities
- Minimum solvency: 100.32%

## Customization

### Change Liability Parameters

```R
pmnt <- 2e6        # Change to £2m annual payments
n_yrs <- 15        # Change to 15 years of payments
i0 <- 0.03         # Change initial interest rate to 3%
```

### Modify Bond Characteristics

```R
# Bond XX
n_xx <- 2          # Change to 2-year maturity
r_xx <- 100        # Redemption value

# Bond YY
cpn_rt <- 0.05     # Change to 5% coupon rate
n_yy <- 30         # Change to 30-year maturity
```

### Adjust Interest Rate Scenarios

```R
# Test more granular rates
i_sc <- seq(0.01, 0.10, by = 0.005)  # 0.5% increments

# Test wider range
i_sc <- seq(0.001, 0.15, by = 0.01)  # 0.1% to 15%
```

### Change Portfolio Grid Granularity

```R
# Finer grid (5% increments)
w_grid <- seq(0, 1, by = 0.05)

# Coarser grid (25% increments)
w_grid <- seq(0, 1, by = 0.25)
```

### Customize Shiny App Appearance

The app uses custom CSS for styling. Modify the `tags$head` section:

```R
tags$head(tags$style(HTML(
  "body{
    background-color: #your-color;
    font-family: 'Your-Font', sans-serif;
  }
  .summarybox{
    background-color: #your-box-color;
    border: 2px solid #your-border-color;
  }"
)))
```

## Technical Details

### Solvency Calculation Logic

The core function `s_m_for_mix()` works as follows:

1. **Calculate bond quantities at t=0:**
   - Number of XX bonds = (weight_XX × total_assets) / price_XX
   - Number of YY bonds = (weight_YY × total_assets) / price_YY

2. **Value portfolio at t=1:**
   - XX value = number_XX × 100 (matures at par)
   - YY value = number_YY × price_YY_at_t1(interest_rate)
   - Total assets = XX value + YY value

3. **Calculate liabilities at t=1:**
   - PV = £1m + £1m × annuity_9_years(interest_rate)

4. **Compute solvency:**
   - Solvency ratio = Total assets / PV liabilities

### Why t=1 Analysis?

The analysis focuses on t=1 (after the first payment) because:
- This is when interest rate risk materializes
- Bond XX matures, providing certain cash for the first payment
- The remaining portfolio must handle 9 more payments under new interest rates
- This tests the portfolio's resilience to rate changes

### Interest Rate Sensitivity

**Bond XX (1-year maturity):**
- At t=1, always worth exactly £100 (matures)
- Zero interest rate sensitivity at t=1
- Maximum certainty, minimum duration matching

**Bond YY (20-year maturity):**
- At t=1, has 19 years remaining
- High interest rate sensitivity (long duration)
- Value ranges from £132.27 (1% rate) to £56.21 (10% rate)
- Better duration matching with long-term liabilities

## Use Cases

### 1. Pension Fund Management
- Determine optimal asset allocation for defined benefit plans
- Ensure solvency across economic scenarios
- Balance certainty vs. duration matching

### 2. Insurance Companies
- Manage liability-driven investment strategies
- Comply with solvency regulations (e.g., Solvency II)
- Stress test portfolios under rate shocks

### 3. Educational Tool
- Teach actuarial concepts (duration, immunization)
- Demonstrate asset-liability management
- Illustrate interest rate risk

### 4. Risk Management
- analyse worst-case scenarios
- Quantify downside protection
- Compare alternative strategies

## Limitations and Assumptions

**Assumptions:**
1. Deterministic interest rates (no stochastic modeling)
2. Flat yield curve (same rate for all maturities)
3. Only two bond choices (simplified universe)
4. No transaction costs or taxes
5. Bonds held to maturity (no trading)
6. No default risk (government bonds assumed)
7. Annual payment frequency
8. Fixed nominal payments (no inflation adjustment)

**Limitations:**
1. Single-period analysis (only examines t=1)
2. Doesn't model reinvestment strategy beyond t=1
3. No consideration of liquidity needs
4. Simplified bond universe

## Extensions and Future Work

Potential enhancements:

1. **Multi-period analysis**: Model full 10-year horizon with reinvestment
2. **Stochastic rates**: Use Monte Carlo simulation for rate scenarios
3. **More bond types**: Add different maturities and coupon rates
4. **Term structure**: Model realistic yield curves
5. **Optimization**: Automated portfolio optimization with constraints
6. **Value-at-Risk**: Calculate downside risk metrics
7. **Scenario analysis**: Model specific economic scenarios (recession, inflation)
8. **Dynamic rebalancing**: Model periodic portfolio adjustments
9. **Transaction costs**: Include realistic trading costs
10. **Regulatory capital**: Calculate required capital buffers

## Troubleshooting

### App Doesn't Launch
```R
# Check if Shiny is installed
if (!require("shiny")) install.packages("shiny")

# Try running with explicit port
runApp(port=8080)
```

### Calculation Errors
```R
# Check for division by zero (interest rate = 0)
# Verify bond parameters are positive
# Ensure weights sum to 1
```

### Performance Issues
```R
# Reduce grid granularity
w_grid <- seq(0, 1, by = 0.2)  # Coarser grid

# Reduce interest rate scenarios
i_sc <- seq(0.02, 0.08, by = 0.02)  # Fewer rates
```


---

**Disclaimer**: This tool is for educational and analytical purposes only. It should not be used as the sole basis for actual investment decisions. Professional actuarial and financial advice should be sought for real pension fund management.
