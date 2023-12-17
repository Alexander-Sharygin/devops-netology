def increment(index):
    index += 1
    return index
def get_square(numb):
    return numb*numb
def print_numb(numb):
    print("Number is {}".format(numb))

index2 = 0
while (index2 < 10):
    index2 = increment(index2)
    print(get_square(index2))
