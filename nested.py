#python3 nested.py
def clout(k):
   closv1 = k
   def clin():
       closv2 = 2
       def inn():
          nonlocal closv2, closv1
          closv2 += closv1
          closv1 += 1
          return closv2
       return inn
   return clin
fun = clout(2)()
print (fun(), fun())
