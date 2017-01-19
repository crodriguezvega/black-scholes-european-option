European option price and greeks using Matlab
=============================================

Matlab class that lets you easily display the price and greeks graphs for an European call or put option under the [Black-Scholes model](http://en.wikipedia.org/wiki/Black–Scholes_model, "Wikipedia entry for Black-Scholes model").

Usage
=====

Instantiate the Matlab class by passing as arguments:

1. the current asset price,
2. the strike price,
3. the annualized risk-free interest rate,
4. the time to expiration in years,
5. the annualized asset return volatility 
6. and the type of option ('call' or 'put').

For example:

```matlab
callOption = blsEuropeanOption(100, 130, 0.05, 1, 0.2, 'Call');
```

Now it is possible to execute a method on the object `callOption` to generate the graph of the option price:

```matlab
callOption.showPrice();
```
![Alt text](/sample/price.png "Price graph")

Similarly, we can execute methods to display the graph of the greeks:

```matlab
callOption.showDelta();
```
![Alt text](/sample/delta.png "Delta graph")
```matlab
callOption.showGamma();
```
![Alt text](/sample/gamma.png "Gamma graph")
```matlab
callOption.showVega();
```
![Alt text](/sample/vega.png "Vega graph")
```matlab
callOption.showTheta();
```
![Alt text](/sample/theta.png "Theta graph")
```matlab
callOption.showRho();
```
![Alt text](/sample/rho.png "Rho graph")
