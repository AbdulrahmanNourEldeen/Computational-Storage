#Defining two lists
preloaded_values = []
final_values = [] 

#open text files
with open("MEM_PRE_HEX.txt", "r") as file:
   preloaded_values = file.readlines()

with open("MEM_FINAL_HEX.txt", "r") as file:
   for line in file:
      if not line or line.startswith("//"):
         continue
      else:
         final_values.append(line)
         
#compare contents
numMatchValues = 0
numDiffValues = 0

for index in range(len(preloaded_values)):
   if preloaded_values[index] == final_values[index]:
      numMatchValues +=1
   else:
      numDiffValues +=1

#print results
print(f"Number of modified values: {numDiffValues}\nNumber of unchanged values: {numMatchValues}")
