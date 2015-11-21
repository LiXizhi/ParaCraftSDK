--[[
Title: BezierSegment
Author(s): Leio Zhang
Date: 2008/4/14
Desc: Based on Actionscript library 
/**
 * A Bezier segment consists of four Point objects that define a single cubic Bezier curve.
 * The BezierSegment class also contains methods to find coordinate values along the curve.
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword BezierSegment, Copy Motion as ActionScript
 * @see ../../motionXSD.html Motion XML Elements  
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/BezierSegment.lua");
------------------------------------------------------------
--]]
local BezierSegment = {
	--[[
	/**
     * The first point of the Bezier curve.
     * It is a node, which means it falls directly on the curve.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript     
     */
     --]]
	a = nil,
	--[[
	**
     * The second point of the Bezier curve. 
     * It is a control point, which means the curve moves toward it,
     * but usually does not pass through it.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
     --]]
	b = nil,
	--[[
	/**
     * The third point of the Bezier curve. 
     * It is a control point, which means the curve moves toward it,
     * but usually does not pass through it.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
     --]]
	c = nil,
	--[[
	/**
     * The fourth point of the Bezier curve.
     * It is a node, which means it falls directly on the curve.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript          
     */
     --]]
	d = nil,
				};
commonlib.setfield("CommonCtrl.Motion.BezierSegment",BezierSegment);
			
function BezierSegment:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

--[[
 /**
     * Calculates the location of a two-dimensional cubic Bezier curve at a specific time.
     *
     * @param t The <code>time</code> or degree of progress along the curve, as a decimal value between <code>0</code> and <code>1</code>.
     * <p><strong>Note:</strong> The <code>t</code> parameter does not necessarily move along the curve at a uniform speed. For example, a <code>t</code> value of <code>0.5</code> does not always produce a value halfway along the curve.</p>
     *
     * @return A point object containing the x and y coordinates of the Bezier curve at the specified time. 
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     */
 --]]
function BezierSegment:getValue(t)
	local ax = self.a.x;
	local x = (t*t*(self.d.x-ax) + 3*(1-t)*(t*(self.c.x-ax) + (1-t)*(self.b.x-ax)))*t + ax;
	local ay = self.a.y;
	local y = (t*t*(self.d.y-ay) + 3*(1-t)*(t*(self.c.y-ay) + (1-t)*(self.b.y-ay)))*t + ay;
	return CommonCtrl.Motion.Point.new(x,y);	
end
--[[
/**
     * Finds the <code>y</code> value of a cubic Bezier curve at a given x coordinate.
     * Some Bezier curves overlap themselves horizontally, 
     * resulting in more than one <code>y</code> value for a given <code>y</code> value.
     * In that case, self method will return whichever value is most logical.
     * 
     * Used by CustomEase and BezierEase interpolation.
     *
     * @param x An x coordinate that lies between the first and last point, inclusive.
     * 
     * @param coefficients An optional array of number values that represent the polynomial
     * coefficients for the Bezier. This array can be used to optimize performance by precalculating 
     * values that are the same everywhere on the curve and do not need to be recalculated for each iteration.
     * 
     * @return The <code>y</code> value of the cubic Bezier curve at the given x coordinate.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, Copy Motion as ActionScript        
     */
--]]
function BezierSegment:getYForX(x, coefficients)
		--[[
		// Clamp to range between end points.
		// The padding with the small decimal value is necessary to avoid bugs
		// that result from reaching the limits of decimal precision in calculations.
		// We have tests that demonstrate self.
		--]]
		if (self.a.x < self.d.x) then
	 		if (x <= self.a.x+0.0000000000000001) then return self.a.y; end
	 		if (x >= self.d.x-0.0000000000000001) then return self.d.y;	end
	 	else	 	
	 		if (x >= self.a.x+0.0000000000000001) then return self.a.y; end
	 		if (x <= self.d.x-0.0000000000000001) then return self.d.y; end
	 	end

		if (not coefficients) then
		
			coefficients = CommonCtrl.Motion.BezierSegment.getCubicCoefficients(self.a.x, self.b.x, self.c.x, self.d.x);
		end
   		
   		--// x(t) = a*t^3 + b*t^2 + c*t + d
   		--log(string.format("%s,%s,%s,%s\n",coefficients[1], coefficients[2], coefficients[3], coefficients[4]-x));
 		local roots = CommonCtrl.Motion.BezierSegment.getCubicRoots(coefficients[1], coefficients[2], coefficients[3], coefficients[4]-x); 
 		local time = nil;
 		local len = table.getn(roots);
  		if (len == 0) then
 			time = 0;
 		elseif (len == 1) then
 			time = roots[1];
  		else 
  			for k,root in ipairs(roots) do
  				if(0 <=root and root <=1)then
  					
  					time = root;
  					break;
  				end
  			end
   		end
		if (time==nil) then
			return nil;
		end
   		local y = CommonCtrl.Motion.BezierSegment.getSingleValue(time, self.a.y, self.b.y, self.c.y, self.d.y);
   		--log(string.format("%s,%s,%s,%s,%s\n",time,coefficients[1], coefficients[2], coefficients[3], coefficients[4]-x));
   		return y;
end

--[[
/**
     * Calculates the value of a one-dimensional cubic Bezier equation at a specific time.
     * By contrast, a Bezier curve is usually two-dimensional 
     * and uses two of these equations, one for the x coordinate and one for the y coordinate.
     *
     * @param t The <code>time</code> or degree of progress along the curve, as a decimal value between <code>0</code> and <code>1</code>.
     * <p><strong>Note:</strong> The <code>t</code> parameter does not necessarily move along the curve at a uniform speed. For example, a <code>t</code> value of <code>0.5</code> does not always produce a value halfway along the curve.</p>
     *
     * @param a The first value of the Bezier equation.
     *
     * @param b The second value of the Bezier equation.
     *
     * @param c The third value of the Bezier equation.
     *
     * @param d The fourth value of the Bezier equation.
     *
     * @return The value of the Bezier equation at the specified time. 
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     */
--]]
function CommonCtrl.Motion.BezierSegment.getSingleValue(t, a, b, c, d)
		if(not a ) then a = 0; end
		if(not b ) then b = 0; end
		if(not c ) then c = 0; end
		if(not d ) then d = 0; end
		return (t*t*(d-a) + 3*(1-t)*(t*(c-a) + (1-t)*(b-a)))*t + a;
end	


--[[
/**
     * Calculates the coefficients for a cubic polynomial equation,
     * given the values of the corresponding cubic Bezier equation.
     *
     * @param a The first value of the Bezier equation.
     *
     * @param b The second value of the Bezier equation.
     *
     * @param c The third value of the Bezier equation.
     *
     * @param d The fourth value of the Bezier equation.
     *
     * @return An array containing four number values,
     * which are the coefficients for a cubic polynomial.
     * The coefficients are ordered from the highest degree to the lowest,
     * so the first number in the array would be multiplied by t^3, the second by t^2, and so on.
     * 
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript        
     * @see #getCubicRoots()
     */	
--]]
function CommonCtrl.Motion.BezierSegment.getCubicCoefficients(a, b, c, d)
		return {  -a + 3*b - 3*c + d,
				 3*a - 6*b + 3*c, 
				-3*a + 3*b, 
				   a};
end

--[[
/**
     * Finds the real solutions, if they exist, to a cubic polynomial equation of the form: at^3 + bt^2 + ct + d.
     * This method is used to evaluate custom easing curves.
     *
     * @param a The first coefficient of the cubic equation, which is multiplied by the cubed variable (t^3).
     *
     * @param b The second coefficient of the cubic equation, which is multiplied by the squared variable (t^2).
     *
     * @param c The third coefficient of the cubic equation, which is multiplied by the linear variable (t).
     *
     * @param d The fourth coefficient of the cubic equation, which is the constant.
     *
     * @return An array of number values, indicating the real roots of the equation. 
     * There may be no roots, or as many as three. 
     * Imaginary or complex roots are ignored.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript             
     */
--]]
function CommonCtrl.Motion.BezierSegment.getCubicRoots(a, b, c, d)
		if(not a ) then a = 0; end
		if(not b ) then b = 0; end
		if(not c ) then c = 0; end
		if(not d ) then d = 0; end
		-- make sure we really have a cubic
		if ( a==0 ) then return CommonCtrl.Motion.BezierSegment.getQuadraticRoots(b, c, d); end
		
		-- normalize the coefficients so the cubed term is 1 and we can ignore it hereafter
		if (a ~= 1) then
			b=b/a;
			c=c/a;
			d=d/a;
		end

		local q = (b*b - 3*c)/9;               -- won't change over course of curve
		local qCubed = q*q*q;                  -- won't change over course of curve
		local r = (2*b*b*b - 9*b*c + 27*d)/54; -- will change because d changes
													-- but parts with b and c won't change
		-- determine if there are 1 or 3 real roots using r and q
		local diff   = qCubed - r*r;           -- will change
		if (diff >= 0) then
			-- avoid division by zero
			if ( q==0 ) then return {0};end
			-- three real roots
			local theta = math.acos(r/math.sqrt(qCubed)); -- will change because r changes
			local qSqrt = math.sqrt(q); -- won't change

			local root1 = -2*qSqrt * math.cos(theta/3) - b/3;
			local root2 = -2*qSqrt * math.cos((theta + 2*math.pi)/3) - b/3;
			local root3 = -2*qSqrt * math.cos((theta + 4*math.pi)/3) - b/3;
			
			return {root1, root2, root3};
		else
			--one real root
			local tmp = math.pow( math.sqrt(-diff) + math.abs(r), 1/3);
			--local rSign = (r > 0) ?  1 : r < 0  ? -1 : 0;
			local rSign;
			if(r > 0) then
				rSign = 1
			elseif(r < 0 )then
				rSign = -1
			else
				rSign = 0;
			end
			local root = -rSign * (tmp + q/tmp) - b/3;
			return {root};
		end
		return {};
end

--[[
 /**
     * Finds the real solutions, if they exist, to a quadratic equation of the form: at^2 + bt + c.
     *
     * @param a The first coefficient of the quadratic equation, which is multiplied by the squared variable (t^2).
     *
     * @param b The second coefficient of the quadratic equation, which is multiplied by the linear variable (t).
     *
     * @param c The third coefficient of the quadratic equation, which is the constant.
     *
     * @return An array of number values, indicating the real roots of the equation. 
     * There may be no roots, or as many as two. 
     * Imaginary or complex roots are ignored.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Bezier curve, node, Copy Motion as ActionScript             
     */
--]]
function CommonCtrl.Motion.BezierSegment.getQuadraticRoots(a, b, c)
		local roots = {};
		--// make sure we have a quadratic
		if ( a==0 ) then
			if ( b==0 )then return {} end;
			roots[1] = -c/b;
			return roots;
		end

		local q = b*b - 4*a*c;
		--signQ = (q > 0) ?  1 : q < 0  ? -1: 0;
		local singQ;
			if(q > 0) then
				singQ = 1
			elseif(q < 0 )then
				singQ = -1
			else
				singQ = 0;
			end

		
		if (signQ < 0) then
			return {};
		elseif ( signQ==0 ) then  
			roots[1] = -b/(2*a);
		else  
			roots[1] = -b/(2*a);
			roots[2] = roots[1];
			local tmp = math.sqrt(q)/(2*a);
			roots[1] =roots[1]- tmp;
			roots[2] =roots[2]+ tmp;
		end
		
		return roots;
end
	

