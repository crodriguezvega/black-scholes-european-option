European option price and greeks using Matlab
=============================================

Matlab class that lets you easily display the price and greeks graphs for an European call or put option under the Black-Scholes model.

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
callOption = blsEuropeanOption(100, 130, 0.05, 1, 0.2, 'Call')
```

Now it is possible to execute a method on the object `callOption` to generate the graph of the option price:

```matlab
callOption.showPrice()
```
![Alt text](/price.png "Visualisation using d3")

Similarly, we can execute methods to display the graph of the greeks:

```matlab
callOption.showDelta()
```
![Alt text](/delta.png "Visualisation using d3")
```matlab
callOption.showGamma()
```
![Alt text](/gamma.png "Visualisation using d3")
```matlab
callOption.showVega()
```
![Alt text](/vega.png "Visualisation using d3")
```matlab
callOption.showTheta()
```
![Alt text](/theta.png "Visualisation using d3")
```matlab
callOption.showRho()
```
![Alt text](/rho.png "Visualisation using d3")
