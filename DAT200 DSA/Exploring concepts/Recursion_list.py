def listSum(lst):
    if not lst:
        return "No elements to sum"
    if len(lst)==1:
        return f"The sum of the list is! {lst[0]}"
    else:
        lstsum = 0
        for i in range(len(lst) + 1):
            lstsum = lstsum + i
        return lstsum
    
liste1 = [1]
liste2 = []
liste3 = [1,2,3]    
print(listSum(liste1))
print(listSum(liste2))
print(listSum(liste3))
