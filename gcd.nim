proc gcd(a, b: int): int =
  if b == 0: return abs(a)
  gcd(b, a mod b)

assert gcd(3, 2) == 1
assert gcd(4, 6) == 2
assert gcd(4, -6) == 2
assert gcd(17, 0) == 17

proc extended_gcd(a: int, b: int): (int, int, int) =
  var (old_r, r) = (a, b)
  var (old_s, s) = (1, 0)
  var (old_t, t) = (0, 1)

  while r != 0:
    let quotient = old_r div r
    (old_r, r) = (r, old_r - quotient * r)
    (old_s, s) = (s, old_s - quotient * s)
    (old_t, t) = (t, old_t - quotient * t)

  return (old_r, old_s, old_t)

let (gc, x, y) = extended_gcd(240, 46)
echo "GCD: ", gc
echo "x0:  ", x
echo "y0:  ", y

type
  DiofanticSolution = object
    x0, y0, xmul, ymul: int

proc solve_diofantic_eq(a, b, c: int): DiofanticSolution =
  let (gcdab, x, y) = extended_gcd(a, b)
  echo gcdab
  return DiofanticSolution(x0: x * c, y0: y * c, xmul: b div gcdab,
      ymul: a div gcdab)

let df = solve_diofantic_eq(3, 4, 5)
echo df
