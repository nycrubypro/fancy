FancySpec describe: Range with: {
  it: "has the correct amount of elements" with: 'size when: {
    Range new: 1 to: 10 . to_a size is: 10
    (1..10) to_a size is: 10
    ("a".."z") to_a size is: 26
  }

  it: "has a working literal syntax" when: {
    (1..10) is: (Range new: 1 to: 10)
  }
}
