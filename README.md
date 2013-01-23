PhysicalComputing
=================

A repository for all my assignments in PhysicalComputing (Processing/Arduino).

Assignment 1: Data Visualization

The first assignment, which can be found under /StepGraphVisualizer, was to create a simple Processing app which in order to get used to the API.  The "theme" was that it had to visualize data in some way.  I chose to create a Step Graph that would treat each step as a platform in a Mario style (super basic) platformer.  I acknowledge that this is probably not a useful way to visualize data, but usefulness was not part of the criteria.  However, you could make a claim that in some cases there can be a correlation between data and the amount of "fun" it translates to in game form.

To use the application simply run it with the Processing interpreter. I created a TestData file with some sample data.  You can play with the file create "levels" or import something more realistic.  The format of the file is such:

[xPos], [yPos]\n
...
...
[lastX]

xPos represents where the step starts and yPos is the its height. The end of the step is determined by the xPos on the next line (each step must be on its own line).  For this reason, all steps will be continuous along the x-axis, and each step in the file must be in order from - to +. lastX is a single integer which is used to give an ending position to the last step.
