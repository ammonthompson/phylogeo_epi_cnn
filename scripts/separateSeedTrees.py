#!/usr/bin/env python3
import sys

infile = sys.argv[1]
outfile = sys.argv[2]
file_type = sys.argv[3]

# get string from file
f = open(infile,'r')
a = f.readlines()

if file_type == "newick":
	s = a[0]
	first_parenth_idx = 0
elif file_type == "nexus":
	tree_line_idx = [idx for idx, i in enumerate(a) if '(' in i][0]
	s = a[tree_line_idx]
	first_parenth_idx = s.index("(")


s = list(s.strip('\n').strip(";"))
f.close()

# mark split points with `!`
split = False
parenth_count = 0
bracket_count = 0
tree_count = 1

for i in range(first_parenth_idx, len(s)):
	if s[i] == '(':
		parenth_count += 1
	elif s[i] == ')':
		parenth_count -= 1
	if parenth_count == 0 and (i + 1) < len(s) and s[i+1] == '[':
		bracket_count += 1
	elif parenth_count == 0 and s[i] == ']':
		bracket_count -= 1
	if parenth_count == 0 and file_type == 'newick':
		split = True
	elif parenth_count == 0 and file_type == 'nexus' and bracket_count == 0:
		split = True
	if split and s[i] == ',':
		if file_type == 'newick':
			s[i] = '!'
			split = False
		elif file_type == 'nexus':
			s[i] = '!tree TREE_' + str(tree_count) + ' ' + '=' + ' '
			split = False
			tree_count += 1


# one tree per line

s = ''.join(s)
toks = [ x+';' for x in s.split('!') ]

toks = '\n'.join(toks)
#print(toks)

# write
f = open(outfile,'w')
if file_type == "nexus":
	f.write("#nexus\n\nBegin trees;\n")
f.write(toks)
if file_type == "nexus":
	f.write("\nEnd;")
f.close()
