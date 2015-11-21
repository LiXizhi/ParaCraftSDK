--[[
Title: MotionTypes
Author(s): Leio
Date: 2010/05/18
Desc:

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
--]]
------------------------------------------------------------
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
MotionTypes.Types=
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
function MotionTypes.easeNone(t , b , c , d)
            return c * t / d + b;
end

--Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity.
function MotionTypes.easeInQuad(t , b , c , d)
			t=t/d;
            return c * (t) * t + b;
end

--Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
function MotionTypes.easeOutQuad(t , b , c , d)
	t=t/d;
	return -c * (t) * (t - 2) + b;
end

--Easing equation function for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutQuad(t , b , c , d)
	t=t/d;
	if ((t / 2) < 1) then return c / 2 * t * t + b; end
	t=t-1;
	return -c / 2 * (t * (t - 2) - 1) + b;
end

--Easing equation function for a quadratic (t^2) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInQuad(t , b , c , d)
    if (t < d / 2) then return MotionTypes.easeOutQuad(t * 2, b, c / 2, d); end
     return MotionTypes.easeInQuad((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a cubic (t^3) easing in: accelerating from zero velocity.
function MotionTypes.easeInCubic(t , b , c , d)
	t=t/d;
    return c * t * t * t + b;
end

--Easing equation function for a cubic (t^3) easing out: decelerating from zero velocity.
function MotionTypes.easeOutCubic(t , b , c , d)
	t=t/d;
    return c * ((t - 1) * t * t + 1) + b;
end

--Easing equation function for a cubic (t^3) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutCubic(t , b , c , d)
	t=t/d;
    if ((t / 2) < 1) then  return c / 2 * t * t * t + b; end
    t=t-2;
    return c / 2 * (t * t * t + 2) + b;
end

--Easing equation function for a cubic (t^3) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInCubic(t , b , c , d)
    if (t < d / 2) then return MotionTypes.easeOutCubic(t * 2, b, c / 2, d); end
    return MotionTypes.easeInCubic((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a quartic (t^4) easing in: accelerating from zero velocity.
function MotionTypes.easeInQuart(t , b , c , d)
	t=t/d;
    return c * t * t * t * t + b;
end

--Easing equation function for a quartic (t^4) easing out: decelerating from zero velocity.
function MotionTypes.easeOutQuart(t , b , c , d)
	t=t/d;
    return -c * ((t - 1) * t * t * t - 1) + b;
end

--Easing equation function for a quartic (t^4) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutQuart(t , b , c , d)
	t=t/d;
    if ((t/ 2) < 1) then return c / 2 * t * t * t * t + b; end
    t=t-2;
    return -c / 2 * (t * t * t * t - 2) + b;
end

--Easing equation function for a quartic (t^4) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInQuart(t , b , c , d)
	
	if (t < d / 2) then return MotionTypes.easeOutQuart(t * 2, b, c / 2, d); end
	return MotionTypes.easeInQuart((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a quintic (t^5) easing in: accelerating from zero velocity.
function MotionTypes.easeInQuint(t , b , c , d)
	t=t/d;
    return c * t * t * t * t * t + b;
end

-- Easing equation function for a quintic (t^5) easing out: decelerating from zero velocity.
function MotionTypes.easeOutQuint(t , b , c , d)
	t=t/d;
    return c * ((t - 1) * t * t * t * t + 1) + b;
end

--Easing equation function for a quintic (t^5) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutQuint(t , b , c , d)
	t=t/d;
	if ((t / 2) < 1) then return c / 2 * t * t * t * t * t + b; end
    t=t-2;
    return c / 2 * (t * t * t * t * t + 2) + b;
end

--Easing equation function for a quintic (t^5) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInQuint(t , b , c , d)
    if (t < d / 2) then return MotionTypes.easeOutQuint(t * 2, b, c / 2, d); end
    return MotionTypes.easeInQuint((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a sinusoidal (sin(t)) easing in: accelerating from zero velocity.
function MotionTypes.easeInSine(t , b , c , d)
     return -c * math.cos(t / d * (math.pi / 2)) + c + b;
end

-- Easing equation function for a sinusoidal (sin(t)) easing out: decelerating from zero velocity.
function MotionTypes.easeOutSine(t , b , c , d)
     return c * math.sin(t / d * (math.pi / 2)) + b;
end

--Easing equation function for a sinusoidal (sin(t)) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutSine(t , b , c , d)
     return -c / 2 * (math.cos(math.pi * t / d) - 1) + b;
end

--Easing equation function for a sinusoidal (sin(t)) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInSine(t , b , c , d)
     if (t < d / 2) then return MotionTypes.easeOutSine(t * 2, b, c / 2, d); end
     return MotionTypes.easeInSine((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for an exponential (2^t) easing in: accelerating from zero velocity.
function MotionTypes.easeInExpo(t , b , c , d)
	if(t==0)then 
		return b;
	else
		return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001;
	end
end

--Easing equation function for an exponential (2^t) easing out: decelerating from zero velocity.
function MotionTypes.easeOutExpo(t , b , c , d)
	if(t == d) then
		return b+c;
	else
		return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b;
	end 
end

--Easing equation function for an exponential (2^t) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutExpo(t , b , c , d)
     if (t == 0) then return b; end
     if (t == d) then return b + c; end
     t=t/d;
     if ((t / 2) < 1) then return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005; end
     t=t-1;
     return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b;
end

--Easing equation function for an exponential (2^t) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInExpo(t , b , c , d)
      if (t < d / 2) then return MotionTypes.easeOutExpo(t * 2, b, c / 2, d); end
      return MotionTypes.easeInExpo((t * 2) - d, b + c / 2, c / 2, d);
end

--Easing equation function for a circular (sqrt(1-t^2)) easing in: accelerating from zero velocity.
function MotionTypes.easeInCirc(t , b , c , d)
		t=t/d;
        return -c * (math.sqrt(1 - t * t) - 1) + b;
end

--Easing equation function for a circular (sqrt(1-t^2)) easing out: decelerating from zero velocity.
function MotionTypes.easeOutCirc(t , b , c , d)
			t=t/d;
            return c * math.sqrt(1 - (t - 1) * t) + b;
end

--Easing equation function for a circular (sqrt(1-t^2)) easing in/out: acceleration until halfway, then deceleration.
function MotionTypes.easeInOutCirc(t , b , c , d)
			t=t/d;
            if ((t / 2) < 1) then return -c / 2 * (math.sqrt(1 - t * t) - 1) + b; end
            t=t-2;
            return c / 2 * (math.sqrt(1 - t * t) + 1) + b;
end
        
--Easing equation function for a circular (sqrt(1-t^2)) easing out/in: deceleration until halfway, then acceleration.               
function MotionTypes.easeOutInCirc(t , b , c , d)
            if (t < d / 2) then return MotionTypes.easeOutCirc(t * 2, b, c / 2, d); end
            return MotionTypes.easeInCirc((t * 2) - d, b + c / 2, c / 2, d);
end
       
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in: accelerating from zero velocity.
function MotionTypes.easeInBounce(t , b , c , d)
            return c - MotionTypes.easeOutBounce(d - t, 0, c, d) + b;
end
        
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
function MotionTypes.easeOutBounce(t , b , c , d)
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
function MotionTypes.easeInOutBounce(t , b , c , d)
            if (t < d / 2) then return MotionTypes.easeInBounce(t * 2, 0, c, d) * .5 + b; end
            
             return MotionTypes.easeOutBounce(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
end
        
--Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out/in: deceleration until halfway, then acceleration.
function MotionTypes.easeOutInBounce(t , b , c , d)
            if (t < d / 2) then return MotionTypes.easeOutBounce(t * 2, b, c / 2, d); end
            return MotionTypes.easeInBounce((t * 2) - d, b + c / 2, c / 2, d);
end                                                                       	
