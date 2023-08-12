import secrets

Depth = 1024
Width = 32

#open text file
with open("MEM_PRE_HEX.txt", "w") as file:

   #write random hex values 
   for index in range(Depth):
      file.write(secrets.token_hex(int(Width/8))+'\n')

