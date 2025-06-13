PRO DEMO_CIRCLE_INTERSECTION


;Date: 01/16/2002 at 12:43:18
;From: Doctor Peterson
;Subject: Re: Intersection of circles
;
;Hi, Peter.
;
;You can solve the equations you gave, if you approach it the right
;way:
;
;    (x-a)^2 + (y-b)^2 = R^2
;    (x-c)^2 + (y-d)^2 = r^2
;
;If you expand each of these and then subtract one from the other, you
;will eliminate the squares, and will be left with a linear equation
;that you can easily solve for y. Replace y in one of the original
;equations with that expression, and you have a quadratic you can solve
;for x. It will be extremely ugly, but is not really hard.
;
;When you are finished, compare your result to this, which I found by
;searching our archives for the words "intersection circles":
;
;   Intersecting Circles
;   http://mathforum.org/dr.math/problems/circintersect.html
;
;I found a clearer solution than Dr. Ken's computer-generated
;solution linked from that page. Here it is:
;
;Let the centers be: (a,b), (c,d)
;Let the radii be: r, s

a=0.
b=0.
r = 2.0
c=1.0
d=0.0
s = 2.0
s = 1.5
s = 2.5

  e = c - a                          ;[difference in x coordinates]
  f = d - b                          ;[difference in y coordinates]
  p = sqrt(e^2 + f^2)                ;[distance between centers]
  k = (p^2 + r^2 - s^2)/(2*p)         ;[distance from center 1 to line
                                      ;joining points of intersection]
  x = a + e*k/p + (f/p)*sqrt(r^2 - k^2)
  y = b + f*k/p - (e/p)*sqrt(r^2 - k^2)
;OR
  x = a + e*k/p - (f/p)*sqrt(r^2 - k^2)
  y = b + f*k/p + (e/p)*sqrt(r^2 - k^2)

;I found this solution using translation and rotation to simplify the
;math. To do the rotation, I used the fact that

;  sin(angle) = f/p
;  cos(angle) = e/p

;- Doctor Peterson, The Math Forum
;  http://mathforum.org/dr.math/

print, x,y

END