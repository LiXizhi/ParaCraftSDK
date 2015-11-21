--[[
Title: TransitionTypes
Author(s): Leio Zhang
Date: 2008/3/19
Desc: Based on Flash Tweener Actionscript library 
NPL.load("(gl)script/ide/Transitions/TweenEquations.lua");
--]]
if(not CommonCtrl)then CommonCtrl={}; end
local TweenEquations={};
CommonCtrl.TweenEquations=TweenEquations;
TweenEquations.TransitionType=
	 {
        easeNone="easeNone",
        easeInQuad="easeInQuad",
        easeOutQuad="easeOutQuad",
        easeInOutQuad="easeInOutQuad",
        easeOutInQuad="easeOutInQuad",
        easeInCubic="easeInCubic",
        easeOutCubic="easeOutCubic",
        easeInOutCubic="easeInOutCubic",
        easeOutInCubic="easeOutInCubic",
        easeInQuart="easeInQuart",
        easeOutQuart="easeOutQuart",
        easeInOutQuart="easeInOutQuart",
        easeOutInQuart="easeOutInQuart",
        easeInQuint="easeInQuint",
        easeOutQuint="easeOutQuint",
        easeInOutQuint="easeInOutQuint",
        easeOutInQuint="easeOutInQuint",
        easeInSine="easeInSine",
        easeOutSine="easeOutSine",
        easeInOutSine="easeInOutSine",
        easeOutInSine="easeOutInSine",
        easeInCirc="easeInCirc",
        easeOutCirc="easeOutCirc",
        easeInOutCirc="easeInOutCirc",
        easeOutInCirc="easeOutInCirc",
        easeInExpo="easeInExpo",
        easeOutExpo="easeOutExpo",
        easeInOutExpo="easeInOutExpo",
        easeOutInExpo="easeOutInExpo",
        --easeInElastic="easeInElastic",
        --easeOutElastic="easeOutElastic",
        --easeInOutElastic="easeInOutElastic",
        --easeOutInElastic="easeOutInElastic",
        --easeInBack="easeInBack",
        --easeOutBack="easeOutBack",
        --easeInOutBack="easeInOutBack",
        --easeOutInBack="easeOutInBack",
        easeInBounce="easeInBounce",
        easeOutBounce="easeOutBounce",
        easeInOutBounce="easeInOutBounce",
        easeOutInBounce="easeOutInBounce"
    }
--Easing equation function for a simple linear tweening, with no easing.
-- @param t		Current time (in seconds).
-- @param b		Starting value.
-- @param c		Change needed in value.
-- @param d		Expected easing duration (in seconds).
-- @return		The correct value.
function TweenEquations.easeNone(t , b , c , d)
            return c * t / d + b;
end

--Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity.
function TweenEquations.easeInQuad(t , b , c , d)
			t=t/d;
            return c * (t) * t + b;
end

--Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
function TweenEquations.easeOutQuad(t , b , c , d)
	t=t/d;
	return -c * (t) * (t - 2) + b;
end

--Easing equation function for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutQuad(t , b , c , d)
	t=t/d;
	if ((t / 2) < 1) then return c / 2 * t * t + b; end
	t=t-1;
	return -c / 2 * (t * (t - 2) - 1) + b;
end

--Easing equation function for a quadratic (t^2) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInQuad(t , b , c , d)
    if (t < d / 2) then return TweenEquations.easeOutQuad(t * 2, b, c / 2, d); end
     return TweenEquations.easeInQuad((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a cubic (t^3) easing in: accelerating from zero velocity.
function TweenEquations.easeInCubic(t , b , c , d)
	t=t/d;
    return c * t * t * t + b;
end

--Easing equation function for a cubic (t^3) easing out: decelerating from zero velocity.
function TweenEquations.easeOutCubic(t , b , c , d)
	t=t/d;
    return c * ((t - 1) * t * t + 1) + b;
end

--Easing equation function for a cubic (t^3) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutCubic(t , b , c , d)
	t=t/d;
    if ((t / 2) < 1) then  return c / 2 * t * t * t + b; end
    t=t-2;
    return c / 2 * (t * t * t + 2) + b;
end

--Easing equation function for a cubic (t^3) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInCubic(t , b , c , d)
    if (t < d / 2) then return TweenEquations.easeOutCubic(t * 2, b, c / 2, d); end
    return TweenEquations.easeInCubic((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a quartic (t^4) easing in: accelerating from zero velocity.
function TweenEquations.easeInQuart(t , b , c , d)
	t=t/d;
    return c * t * t * t * t + b;
end

--Easing equation function for a quartic (t^4) easing out: decelerating from zero velocity.
function TweenEquations.easeOutQuart(t , b , c , d)
	t=t/d;
    return -c * ((t - 1) * t * t * t - 1) + b;
end

--Easing equation function for a quartic (t^4) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutQuart(t , b , c , d)
	t=t/d;
    if ((t/ 2) < 1) then return c / 2 * t * t * t * t + b; end
    t=t-2;
    return -c / 2 * (t * t * t * t - 2) + b;
end

--Easing equation function for a quartic (t^4) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInQuart(t , b , c , d)
	
	if (t < d / 2) then return TweenEquations.easeOutQuart(t * 2, b, c / 2, d); end
	return TweenEquations.easeInQuart((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a quintic (t^5) easing in: accelerating from zero velocity.
function TweenEquations.easeInQuint(t , b , c , d)
	t=t/d;
    return c * t * t * t * t * t + b;
end

-- Easing equation function for a quintic (t^5) easing out: decelerating from zero velocity.
function TweenEquations.easeOutQuint(t , b , c , d)
	t=t/d;
    return c * ((t - 1) * t * t * t * t + 1) + b;
end

--Easing equation function for a quintic (t^5) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutQuint(t , b , c , d)
	t=t/d;
	if ((t / 2) < 1) then return c / 2 * t * t * t * t * t + b; end
    t=t-2;
    return c / 2 * (t * t * t * t * t + 2) + b;
end

--Easing equation function for a quintic (t^5) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInQuint(t , b , c , d)
    if (t < d / 2) then return TweenEquations.easeOutQuint(t * 2, b, c / 2, d); end
    return TweenEquations.easeInQuint((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a sinusoidal (sin(t)) easing in: accelerating from zero velocity.
function TweenEquations.easeInSine(t , b , c , d)
     return -c * math.cos(t / d * (math.pi / 2)) + c + b;
end

-- Easing equation function for a sinusoidal (sin(t)) easing out: decelerating from zero velocity.
function TweenEquations.easeOutSine(t , b , c , d)
     return c * math.sin(t / d * (math.pi / 2)) + b;
end

--Easing equation function for a sinusoidal (sin(t)) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutSine(t , b , c , d)
     return -c / 2 * (math.cos(math.pi * t / d) - 1) + b;
end

--Easing equation function for a sinusoidal (sin(t)) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInSine(t , b , c , d)
     if (t < d / 2) then return TweenEquations.easeOutSine(t * 2, b, c / 2, d); end
     return TweenEquations.easeInSine((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for an exponential (2^t) easing in: accelerating from zero velocity.
function TweenEquations.easeInExpo(t , b , c , d)
	if(t==0)then 
		return b;
	else
		return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001;
	end
end

--Easing equation function for an exponential (2^t) easing out: decelerating from zero velocity.
function TweenEquations.easeOutExpo(t , b , c , d)
	if(t == d) then
		return b+c;
	else
		return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b;
	end 
end

--Easing equation function for an exponential (2^t) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutExpo(t , b , c , d)
     if (t == 0) then return b; end
     if (t == d) then return b + c; end
     t=t/d;
     if ((t / 2) < 1) then return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005; end
     t=t-1;
     return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b;
end

--Easing equation function for an exponential (2^t) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInExpo(t , b , c , d)
      if (t < d / 2) then return TweenEquations.easeOutExpo(t * 2, b, c / 2, d); end
      return TweenEquations.easeInExpo((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a circular (sqrt(1-t^2)) easing in: accelerating from zero velocity.
function TweenEquations.easeInCirc(t , b , c , d)
		t=t/d;
        return -c * (math.sqrt(1 - t * t) - 1) + b;
end

--Easing equation function for a circular (sqrt(1-t^2)) easing out: decelerating from zero velocity.
function TweenEquations.easeOutCirc(t , b , c , d)
			t=t/d;
            return c * math.sqrt(1 - (t - 1) * t) + b;
end

--Easing equation function for a circular (sqrt(1-t^2)) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutCirc(t , b , c , d)
			t=t/d;
            if ((t / 2) < 1) then return -c / 2 * (math.sqrt(1 - t * t) - 1) + b; end
            t=t-2;
            return c / 2 * (math.sqrt(1 - t * t) + 1) + b;
end
        
--Easing equation function for a circular (sqrt(1-t^2)) easing out/in: deceleration until halfway, then acceleration.               
function TweenEquations.easeOutInCirc(t , b , c , d)
            if (t < d / 2) then return TweenEquations.easeOutCirc(t * 2, b, c / 2, d); end
            return TweenEquations.easeInCirc((t * 2) - d, b + c / 2, c / 2, d);
end
       
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in: accelerating from zero velocity.
function TweenEquations.easeInBounce(t , b , c , d)
            return c - TweenEquations.easeOutBounce(d - t, 0, c, d) + b;
end
        
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
function TweenEquations.easeOutBounce(t , b , c , d)
			t=t/d;
            if (t < (1 / 2.75)) then

                return c * (7.5625 * t * t) + b;

            elseif (t < (2 / 2.75)) then
				t=t-1.5 / 2.75;
                return c * (7.5625 * t * t + .75) + b;

            elseif (t < (2.5 / 2.75)) then
				t=t-2.25 / 2.75;
                return c * (7.5625 * t * t + .9375) + b;

            else
				t=t-2.625 / 2.75;
                return c * (7.5625 * t * t + .984375) + b;
			end
end
        
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in/out: acceleration until halfway, then deceleration.
function TweenEquations.easeInOutBounce(t , b , c , d)
            if (t < d / 2) then return TweenEquations.easeInBounce(t * 2, 0, c, d) * .5 + b; end
            
             return TweenEquations.easeOutBounce(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
end
        
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out/in: deceleration until halfway, then acceleration.
function TweenEquations.easeOutInBounce(t , b , c , d)
            if (t < d / 2) then return TweenEquations.easeOutBounce(t * 2, b, c / 2, d); end
            return TweenEquations.easeInBounce((t * 2) - d, b + c / 2, c / 2, d);
end                                                                       	
