# Import necessary modules
import sys
import os
print "hello"
# Check that the correct number of arguments were provided
if len(sys.argv) != 2:
    print('Usage: python split_columns.py <input_file>')
    sys.exit()

# Get the input file from the command line arguments
input_file = sys.argv[1]

# Check that the input file exists
if not os.path.exists(input_file):
    print('Error: input file does not exist')
    sys.exit()

        # Open the input file and read the lines
with open(input_file, 'r') as f:
    lines = f.readlines()

        # Split each line into columns
columns = [line.split() for line in lines]

        # Get the number of columns
num_columns = len(columns)
print num_columns
# Create a file for each column
for i in range(num_columns):
    with open('column_{}.txt'.format(i), 'w') as f:
        for line in columns:
            f.write(line[i] + '\n')

