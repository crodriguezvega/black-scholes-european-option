% blsEuropeanOption displays European call and put option prices 
% and their greeks using the Black-Scholes-Merton model.
%
% Usage:
% option = blsEuropeanOption(S0, K, r, T, sigma, optionType)
%
% Inputs:
% S0         - Current price of the underlying asset.
% K          - Strike (i.e., exercise) price of the option.
% r          - Annualized continuously compounded risk-free rate of return
%              over the life of the option, expressed as a positive decimal
%              number.
% T          - Time to expiration of the option, expressed in years.
% sigma      - Annualized asset price volatility (i.e., annualized standard
%              deviation of the continuously compounded asset return),
%              expressed as a positive decimal number.
% optionType - 'call' or 'put'.
%
% Methods:
% showPrice
% showDelta
% showGamma
% showTheta
% showVega
% showRho
classdef (Sealed = true) blsEuropeanOption < handle
  properties (GetAccess = private, SetAccess = private)
    spotPrices
    timeToExpiry
    dplus
    dminus
  end
  properties (SetObservable, AbortSet)
    S0 = 0 
    K = 0
    T = 0
  end
  properties
    r = 0                        
    sigma = 0
    optionType
  end
  methods
    function obj = set.S0(obj, value)
      if value <= 0
        error('blsEuropeanOption:S0', 'S0 must be > 0.');
      else
        obj.S0 = value;
      end
    end
    function obj = set.K(obj, value)
      if value <= 0
        error('blsEuropeanOption:K', 'K must be > 0.');
      else
        obj.K = value;
      end
    end
    function obj = set.r(obj, value)
      if value <= 0
        error('blsEuropeanOption:r', 'r must be > 0.');
      else
        obj.r = value;
      end
    end
    function obj = set.T(obj, value)
      if value <= 0
        error('blsEuropeanOption:T', 'T must be > 0.');
      else
        obj.T = value;
      end
    end
  end
  methods
    function obj = blsEuropeanOption(S0, K, r, T, sigma, optionType)
      % Validate input parameters
      if nargin ~= 6
        error('blsEuropeanOption:invalidInputs', 'Wrong numer of input parameters.');
      end
      if strcmpi(optionType, 'call') ~= 1 && strcmpi(optionType, 'put') ~= 1
        error('blsEuropeanOption:invalidInputs', 'Option type must be "call" or "put".');
      end
      
      obj.spotPrices = 0;
      obj.timeToExpiry = 0;
      
      addlistener(obj, 'S0', 'PostSet', @obj.calculateGrid);
      addlistener(obj, 'K', 'PostSet', @obj.calculateGrid);
      addlistener(obj, 'T', 'PostSet', @obj.calculateGrid);
      
      % check option type                             
      obj.S0 = S0;
      obj.K = K;
      obj.r = r;
      obj.T = T;
      obj.sigma = sigma;
      obj.optionType = optionType;
    end
    function showPrice(obj)                     
      % Precompute terms that are used more than once
      A = obj.sigma .* sqrt(obj.timeToExpiry);
      E = obj.K .* exp(-obj.r .* obj.timeToExpiry);
      
      obj.dplus = (1 ./ A) .* (log(obj.spotPrices ./ obj.K) + obj.timeToExpiry .* (obj.r + obj.sigma.^2 / 2));
      % Handle the case when dplus has a 0/0. 
      obj.dplus(isnan(obj.dplus)) = 0;
      obj.dminus = obj.dplus - A;
      
      if strcmpi(obj.optionType, 'call') == 1
        % Price of European call option
        price = obj.spotPrices .* normcdf(obj.dplus)  -  E .* normcdf(obj.dminus);
      else           
        % Price of European put option
        price  =  E .* normcdf(-obj.dminus) - obj.spotPrices .* normcdf(-obj.dplus);
      end
      
      obj.draw(price, 'Option value');
    end
    function showDelta(obj)
      % Delta is the partial derivative of the option price with respect to the underlying
      if strcmpi(obj.optionType, 'call') == 1
        delta = normcdf(obj.dplus);
      else
        delta = normcdf(-obj.dplus);
      end
      obj.draw(delta, 'Delta');
    end
    function showGamma(obj)
      % Gamma is the partial derivative of the delta with respect to the underlying
      gamma = obj.normpdfPrima(obj.dplus) ./ (obj.spotPrices .* obj.sigma .* sqrt(obj.timeToExpiry));
      gamma(isnan(gamma)) = 0;
      obj.draw(gamma, 'Gamma');
    end
    function showVega(obj)
      % Vega is the partial derivative of the option value with respect to implied volatility
      vega = obj.spotPrices .* sqrt(obj.timeToExpiry) .* obj.normpdfPrima(obj.dplus);
      obj.draw(vega, 'Vega');
    end
    function showTheta(obj)
      % Theta is the partial derivative of the option value with respect to time
      theta = -(obj.spotPrices .* obj.sigma .* obj.normpdfPrima(obj.dplus) ./ 2 .* sqrt(obj.timeToExpiry));
      if strcmpi(obj.optionType, 'call') == 1
        theta = theta - obj.r .* obj.K .* normcdf(obj.dminus);
      else
        theta = theta + obj.r .* obj.K .* normcdf(-obj.dminus);
      end
      obj.draw(theta, 'Theta');
    end
    function showRho(obj)
      % Rho is the partial derivative of the option value with respect to the interest rate
      if strcmpi(obj.optionType, 'call') == 1
        rho = obj.K .* obj.timeToExpiry .* exp(-obj.r .* obj.timeToExpiry) .* normcdf(obj.dminus);
      else
        rho = -obj.K .* obj.timeToExpiry .* exp(-obj.r .* obj.timeToExpiry) .* normcdf(-obj.dminus);
      end
      obj.draw(rho, 'Rho');
    end
  end
  methods (Access = private)     
    function calculateGrid(obj, src, event)
      step = obj.S0 / 100;
      if obj.S0 >= obj.K                
        spotRange = obj.K / 2: step: 1.5 * obj.S0;
      else
        spotRange = obj.K / 2: step: 1.5 * obj.K;
      end    
      step = obj.T / 100;
      timeRange = 0: step: obj.T;
      
      [obj.spotPrices, obj.timeToExpiry] = meshgrid(spotRange, timeRange);
    end        
    function draw(obj, z, label)
      hqr = surf(obj.spotPrices, obj.timeToExpiry, z, gradient(z, diff(obj.spotPrices(1, 1:2)), diff(obj.timeToExpiry(1:2))));
      view(-125, 30);
      
      xlabel('Spot price');
      ylabel('Time to expiration');
      zlabel(label);
      
      set(hqr, 'FaceAlpha', .6);
      set(hqr, 'EdgeAlpha', .2);
      set(hqr, 'FaceLighting', 'phong');
      set(hqr, 'FaceColor', 'interp');
    end
    function x = normpdfPrima(obj, d)
      x = (exp((-d.^2)./2)./sqrt(2*pi));
    end
  end % methods
end % classdef
