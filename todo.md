# Ideas for improvements

## General
- [ ] Plan some classroom discussion for each session.
- [ ] Add an exam-style question to each chapter.
- [ ] Set all assessment quizzes to allow corrections with a 30% penalty.
- [ ] Add a pen icon to exercises to be done with pen and paper and a keyboard icon to those requiring coding.
- [ ] Use docstrings consistently throughout the example code.
- [ ] Be consistent about whether to append errors to a list or put them into a numpy vector. I prefer vector.
- [ ] Follow standard Python style conventions, in particular in function names.
- [ ] Harmonise the presentation of Taylor's theorem throughout the notes.
- [ ] Consider moving the Optimisation chapter before the Calculus chapter.
- [ ] Add import of matplotlib to all code blocks that use `plt`
- [ ] In all iterative methods, write the function to return a list of all iterates, not just the last one.

## Possible new material
- [ ] The module page says I will be teaching " interpolation of data points using polynomials and splines"
- [ ] Add FFT somewhere
- [ ] Add Monte Carlo integration

## Chapter 1 Essential Python
- [ ] Check whether all info about Colab and Gemini is still up-to-date.
- [ ] Introduce docstrings in the first colab notebook.

## Chapter 1 Numbers

## Chapter 2 Functions

## Chapters 3 and 4 Roots

## Chapter 5 Calculus
- [ ] Take out Exercise 5.13 about writing the inefficient version of ForwardDiff and go straight to the vectorised case.
- [ ] Students took a long time on the Differentiation section. Streamline.

## Chapter 6 Optimisation
- [ ] Use gradient descent for regression
- [ ] Add exam question on least squares.

## Chapters 7 and 8 ODEs
- [ ] Print out Figures 6.1 and 6.2 and bring them to session
- [ ] Remove first three parts of Exercise 7.9 and give the second-order equation directly. Update the labels on the corresponding feedback quiz questions.
- [ ] Change the name of the variables from x1, x2 to u and v, which is what we'll use in Example 8.5.
- [ ] Change the ODE example in Exercise 7.9 part to make it agree with the one in the feedback quiz.
- [ ] Wrap the plotting code in Exercise 7.9 into functions.
- [ ] Ask students to also draw the backward Euler method
- [ ] Make more interesting choices for stepsizes in Exercise 8.15 closer to the stability limit of 0.02. 0.01, 0.02, 0.03 for example.
- [ ] Make the discussion of the error in the stability discussion more similar to the discussion for PDEs

## Chapters 9 and 10 PDEs

- [ ] Be careful when creating the vector of times in cases where the interval
      length is not an exact multiple of dt. Probably best to first determine
      an integer number of intervals and then create the vector of times with
      np.linspace and then determine an updated h = t[1] - t[0].
- [ ] In Exercise 9.5 ask for a plot of the final time step instead of a plot over the entire time range.
- [ ] For observing instability, recommend looking at the plot of the final time step.
- [ ] Use central difference approximation for advection term
- [ ] Include more interesting examples

