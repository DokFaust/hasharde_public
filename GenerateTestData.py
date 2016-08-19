#!python

# Small script to create a VHDL std_logic_vector value
# (as 32 bit word) from a text string
#
# MOCA 2016 Talk "FPGA4Hackers"
# Author: Walter Tiberti <wtuniv@gmail.com>
# License: GPLv2


teststrings = [
	"ciao mondo",
	"moca2016",
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	# add here #
]

vhdl_word_template = "x\"%.2X%.2X%.2X%.2X\""

words_left = 256

for s in teststrings:
	l = len(s) % 4;
	if l == 0:
		l = 4; # always at least one NUL
	l += len(s);
	t = [0] * l
	for c in range(len(s)):
		t[c] = ord(s[c])
	for i in range(l/4):
		print vhdl_word_template % (
			t[i*4 + 0],
			t[i*4 + 1],
			t[i*4 + 2],
			t[i*4 + 3]
			) + ",",
		words_left -= 1
		if words_left % 16 == 0:
			print
for i in range(words_left):
	print vhdl_word_template % (0,0,0,0) + ",",
	if words_left % 16 == 0:
		print

