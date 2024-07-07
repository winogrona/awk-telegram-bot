function alen(array) {
  count = 0
  for (i in array) {
    count++
  }
  return count
}

function join(array, separator) {
  result = array[0]

  for (i = 1; i < alen(array); i++) {
    result = result separator array[i]
  }

  return result
}
