# newtonRootCalc
IA program in x86 assembly language that finds a single root of a polynomial of complex coefficients, written for CS Arch class.
This program finds a point z 
where:
c0 + c1 · z + c2 · z
2 + · · · + cn · z
n = 0
Using the x87 subsystem, the
SSE register set, and the C standard library.
The x87 does not support complex numbers, so I have implemented the
representation for complex numbers and the functions defined over them
using support for floating-point numbers in the x87 subsystem.

The input to the program
The program shall read from stdin the following items:

• A specification of tolerance (how close must we get to an actual zero
of the function)

• A specification of the order (highest power in the polynomial)

• The coeffcients (since they are indexed, these may be given in any
order)

• An initial value z with which to start the computation

Sample input:

2

epsilon = 1.0e-8

order = 2

coeff 2 = 2.0 0.0

coeff 1 = 5.0 0.0

coeff 0 = 3.0 0.0

initial = 1.0 -1.0


The blanks around the equal (=) sign are intentional and mandatory
