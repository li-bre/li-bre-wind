function [polyFunction, yCalc, statParams] = polyfit(xVar, yVar, polyDeg, matlabForm, doGraph, polyChar)
//----------------------------------------------------------------------------//
// polyfit: polynomial regression for Scilab http://www.scilab.org/           //
// Author: Javier I. Carrero, jicarrerom@unal.edu.co                          // 
// Last modification date: 2010-12-06                                         //
// As long the author and the source are credited this file can be used in    //
// whatever form you want. But you must be aware that there is no implicit    //
// or explicit guarantee  about its results.                                  //
//----------------------------------------------------------------------------//
// Mathematical background:                                                   //
// Based on the minimization of residuals, see polyfit documentation          //
// and Chapra and Canale's "Numerical Methods for Engineers,                  //
// 5th ed., ch. 17 (McGraw-Hill, 2005)                                        //
//----------------------------------------------------------------------------//
// In its default behavior this function produces a scilab polynomial object  //
// that represent the best fit for the x-y input data in the form             //
//                                                                            //
// y = a0 + (a1*x) + (a2*x^2) + ... + (an*x^n )                               //
//                                                                            //
// where n = polyDeg. ai values are optimal in the sense of minimizing the    //
// sum of square residuals (see Sr in the output statParams). When invoked    //
// with the matlabForm option polyfit returns the same ai coefficients in the //
// Matlab's form, a row vector [an .. a1 a0].                                 //
//----------------------------------------------------------------------------//
// Arguments (function input)                                                 //
// * xVar: independent variable values, a one-row or one-column vector        //
// * yVar: dependent variable values, same length as xVar                     //
// * polyDeg: integer, degree of the polynomial                               //
// * matlabForm (optional): if present makes the function to produce an       //
//   output in the matlab form, see the output argument polyFunction. To      //
//   invoke this option it is enough to give any value to the variable, for   //
//   example write MComp = "Y"                                                //
// * doGraph (optional): if present produces a graphic with the input values  //
//   (as circles) and a line produced with the result polyFunction. To invoke //
//   this option it is enough to give any value to the variable, for example  //
//   write the argument as doGraph =  "Y"                                     //
// * polyChar (optional): a character to be used in the output polynomial     //
//   polyFunction. By default polyChar will be "x", but it can be changed,    //
//   for example invoking the function with polyChar = "z"                    //
//----------------------------------------------------------------------------//
// Return values (function output)                                            //  
// * polyFunction in the default form is a scilab polynomial of n degree that //
//   adjust the input data y(x). If the matlabForm option was used it becomes //
//   a vector with n+1 elements containing the values of ai, that is          //
//   polyFunction = [an ... a2 a1 a0]                                         //
// * yCalc is a vector with m elements corresponding to the y values          //
//   calculated with x1, x2, ..., xm                                          //
// * statParams is a vector with statistical parameters,                      //
//   statParams = [St Sr stdv r2] where                                       //
//   - St: sum of the squared differences between yi and yAvg, being yAvg     //
//     the average of y                                                       // 
//   - Sr: sum of the m residuals, being each residual (yi-yi_calc)^2         //
//     being yCalc the value obtained from the set x1i, x2i, ..., xni         // 
//   - stdv: standard deviation, defined as ( St / m-1 ) ^ 0.5                //
//   - r2: correlation coefficient, defined as r2 = ( St - Sr ) / St          //
//   - Syx: standard error, defined as Syx = (Sr/(m-(n+1)))^1/2               //
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Argument checking: xVar, yVar must be column vectors with equal lengths    //
//----------------------------------------------------------------------------//
//matlabForm=Y;
//doGraph=Y;
//polyChar=x;

abortFunction = %f

[lhs, rhs] = argn()

if ( ( rhs < 3 ) | ( rhs > 6 ) ) then
    error(" Wrong number of input arguments. ")
end

if ( lhs > 3 ) then
    error(" Wrong number of output arguments. ")
end

if ( typeof(xVar) <> "constant") then
    error("xVar should be a vector of real numbers")
end

if ( typeof(yVar) <> "constant") then
    error("yVar should be a vector of real numbers")
end

if ( ( modulo(polyDeg,1) <> 0 ) | ( polyDeg < 1 ) ) then
    error("polyDeg must be a positive integer, and polyDeg>=1")
end

[numRows numCols] = size(xVar)

if ( ~( ( numRows == 1 ) | ( numCols == 1 ) ) ) then
    error(" Inconsistent argument: xVar must be a vector. ")
    abortFunction = %t
else
    if ( numRows == 1 ) then
        xVar = xVar'
        isColumnX = %f
    else
        isColumX = %t
    end,
end

[numRows numCols] = size(yVar)

if ( ~( ( numRows == 1 ) | ( numCols == 1 ) ) ) then
  error(" Inconsistent argument: yVar must be a vector. ")
  abortFunction = %t
else
  if ( numRows == 1 ) then
    yVar = yVar'
    isColumnY = %f
  else
    isColumnY = %t
  end,  
end

numPoints = length(xVar)

if ( length(yVar) <> numPoints ) then
    error(" Inconsistent arguments: xVar, and yVar must have the same length. ")
    abortFunction = %t  
end,

if ( ( polyDeg < 0 ) | ( ( numPoints - 1 ) < polyDeg  ) ) then
    error("Inconsistent argument: polyDeg must be in the range (0, m), where m=length(xVar). ")
  abortFunction = %t
end

for i=1:numPoints-1
    for j = i+1:numPoints
        if ( abs( xVar(i) - xVar(j) ) <= %eps ) then
            error(" Fail: there are repeated values.in xVar ")
            abortFunction = %t
        end
    end
end

if ( abortFunction ) then
    abort
end,

// check for the optional parameters

if exists('matlabForm') then
    doMatlabOutput = %t
else
    doMatlabOutput = %f
end,

if exists('doGraph') then
    doPlot = %t
else
    doPlot = %f
end,

if ( ~exists('polyChar') ) then
    polyChar = 'x'
end,

//----------------------------------------------------------------------------//
// Calculation procedure:                                                     //
// Since use of powers of x up to polyDeg tends to produce ill-conditioned    //
// matrices QR decomposition must be used to solve the associated linear      //
// system of equations. As the polynomial has powers up to polyDeg there are  //
// polyDeg+1 unknown variables: a0, a1, ..., an stored in listCoef. Finally   //
// the system is solved using the upper diagonal matrix R starting from the   //
// polyDeg+1 row up to row 1                                                  //
//----------------------------------------------------------------------------//
Z = zeros(numPoints, polyDeg+1);
Z(:,1) = 1

for i=1:polyDeg
    Z(:,i+1) = xVar .^ i
end,

A = Z' * Z
B = Z' * yVar

[Q, R] = qr(A)

Qtb = Q' * B

listCoef = zeros(polyDeg+1,1)
listCoef(polyDeg+1) = Qtb(polyDeg+1) / R(polyDeg+1,polyDeg+1)

for j=polyDeg:-1:1
    listCoef(j) = ( Qtb(j) - ( R(j,j+1:polyDeg+1) * listCoef(j+1:polyDeg+1) ) ) / R(j,j)
end,

//--------------------------------------------------------------------------//
// Main output                                                              //
//--------------------------------------------------------------------------//
poli  = poly(listCoef, polyChar, 'coeff')
yCalc = horner(poli, xVar)

if ( doMatlabOutput ) then
    polyFunction = flipdim(listCoef',2)
else
    polyFunction = poli
end,

//------------------------------------------------------------//  
// fit statistics, parameteter statParams                     //
//------------------------------------------------------------// 
yAvg = sum( yVar ) / numPoints
St   = sum( ( yVar - yAvg ) .^ 2 )
Sr   = sum( ( yCalc - yVar ) .^ 2 )
stdv = sqrt( St / ( numPoints - 1 ) )

if ( St >= %eps ) then
    r2 = ( St - Sr ) / St
else
    r2 = %inf
end

if ( numPoints > (polyDeg + 1) ) then
    Syx = sqrt( Sr / ( numPoints - ( polyDeg + 1 ) ) )
else
    Syx = %inf
end,

statParams = [St Sr stdv r2 Syx]

//-----------------------------------------------------------------//
// the original shape of yVar is mantained                         //
//-----------------------------------------------------------------//

if ( ~isColumnY ) then
  yCalc = yCalc'
end

//------------------------------------------------------------//  
// Produce graphic output, if requested                       //
//------------------------------------------------------------//  
if (doPlot) then
    numTestPoints = 100
    xTest = linspace(min(xVar), max(xVar), numTestPoints)
    yTest = horner(poli, xTest)

    clf()
    plot(xVar, yVar, 'o', xTest, yTest, '-')
    ejes = get("current_axes")
    ejes.x_label.text = polyChar
    ejes.y_label.text = "y"
end,

endfunction


