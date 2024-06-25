#!/usr/bin/python
import sys
DEBUG     = False	# Turn on or off debug to help debug program
loopCount = 5		# defaults to 5

if (len(sys.argv) > 1): loopCount = int(sys.argv[1])
if (len(sys.argv) > 2): DEBUG     = True if (int(sys.argv[2])> 0) else False
if (DEBUG):  print (f'DEBUG: Number of times through loop: {loopCount}')
if (DEBUG):  print (f'DEBUG: Name of program: {sys.argv[0]}')

i = 0
while (i < loopCount):
   i = i + 1
   print (f'Looping: {i}')
 
loopCount = int(input('Enter new loop count:'))
 
i = 0
while (i < loopCount):
   i = i + 1
   print (f'Looping: {i}')
