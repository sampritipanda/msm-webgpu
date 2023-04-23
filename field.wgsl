alias BaseField = BigInt256;
alias ScalarField = BigInt256;

const BASE_MODULUS: BigInt256 = BigInt256(
    array(1u, 0u, 12525u, 39213u, 63771u, 2380u, 39164u, 8774u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 16384u)
);

const BASE_MODULUS_MEDIUM_WIDE: BigInt272 = BigInt272(
    array(1u, 0u, 12525u, 39213u, 63771u, 2380u, 39164u, 8774u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 16384u, 0u)
);

const BASE_MODULUS_WIDE: BigInt512 = BigInt512(
    array(1u, 0u, 12525u, 39213u, 63771u, 2380u, 39164u, 8774u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 16384u,
        0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u)
);

const BASE_NBITS = 255;

const BASE_M = BigInt256(
    array(65532u, 65535u, 15435u, 39755u, 7057u, 56012u, 39951u, 30437u, 65535u, 65535u, 65535u, 65535u, 65535u, 65535u, 65535u, 65535u)
);

const ZERO: BigInt256 = BigInt256(
    array(0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u)
);

const ONE: BigInt256 = BigInt256(
    array(1u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u)
);

fn get_higher_with_slack(a: BigInt512) -> BaseField {
    var out: BaseField;
    const slack = L - BASE_NBITS;
    for (var i = 0u; i < N; i = i + 1u) {
        out.limbs[i] = ((a.limbs[i + N] << slack) + (a.limbs[i + N - 1] >> (W - slack))) & W_mask;
    }
    return out;
}

// once reduces once (assumes that 0 <= a < 2 * mod)
fn field_reduce(a: BigInt256) -> BaseField {
    var res: BigInt256;
    var underflow = sub(a, BASE_MODULUS, &res);
    if (underflow == 1u) {
        return a;
    } else {
        return res;
    }
}

fn shorten(a: BigInt272) -> BigInt256 {
    var out: BigInt256;
    for (var i = 0u; i < N; i = i + 1u) {
        out.limbs[i] = a.limbs[i];
    }
    return out;
}

// reduces l times (assumes that 0 <= a < multi * mod)
fn field_reduce_272(a: BigInt272, multi: u32) -> BaseField {
    var res: BigInt272;
    var cur = a;
    var cur_multi = multi + 1;
    while (cur_multi > 0u) {
        var underflow = sub_272(cur, BASE_MODULUS_MEDIUM_WIDE, &res);
        if (underflow == 1u) {
            return shorten(cur);
        } else {
            cur = res;
        }
        cur_multi = cur_multi - 1u;
    }
    return ZERO;
}

fn field_add(a: BaseField, b: BaseField) -> BaseField { 
    var res: BaseField;
    add(a, b, &res);
    return field_reduce(res);
}

fn field_sub(a: BaseField, b: BaseField) -> BaseField {
    var res: BaseField;
    var carry = sub(a, b, &res);
    if (carry == 0u) {
        return res;
    }
    add(res, BASE_MODULUS, &res);
    return res;
}

fn field_mul(a: BaseField, b: BaseField) -> BaseField {
    var xy: BigInt512 = mul(a, b);
    var xy_hi: BaseField = get_higher_with_slack(xy);
    var l: BigInt512 = mul(xy_hi, BASE_M);
    var l_hi: BaseField = get_higher_with_slack(l);
    var lp: BigInt512 = mul(l_hi, BASE_MODULUS);
    var r_wide: BigInt512;
    sub_512(xy, lp, &r_wide);

    var r_wide_reduced: BigInt512;
    var underflow = sub_512(r_wide, BASE_MODULUS_WIDE, &r_wide_reduced);
    if (underflow == 0u) {
        r_wide = r_wide_reduced;
    }
    var r: BaseField;
    for (var i = 0u; i < N; i = i + 1u) {
        r.limbs[i] = r_wide.limbs[i];
    }
    return field_reduce(r);
}

// This is slow, probably don't want to use this
// fn field_small_scalar_mul(a: u32, b: BaseField) -> BaseField {
//     var constant: BaseField;
//     constant.limbs[0] = a;
//     return field_mul(constant, b);
// }

fn field_small_scalar_shift(l: u32, a: BaseField) -> BaseField { // max shift allowed is 16
    // assert (l < 16u);
    var res: BigInt272;
    for (var i = 0u; i < N; i = i + 1u) {
        let shift = a.limbs[i] << l;
        res.limbs[i] = res.limbs[i] | (shift & W_mask);
        res.limbs[i + 1] = (shift >> W);
    }

    var output = field_reduce_272(res, (1u << l)); // can probably be optimised
    return output;
}

fn field_pow(p: BaseField, e: u32) -> BaseField {
    var res: BaseField = p;
    for (var i = 1u; i < e; i = i + 1u) {
        res = field_mul(res, p);
    }
    return res;
}

fn field_eq(a: BaseField, b: BaseField) -> bool {
    for (var i = 0u; i < N; i = i + 1u) {
        if (a.limbs[i] != b.limbs[i]) {
            return false;
        }
    }
    return true;
}

fn field_sqr(a: BaseField) -> BaseField {
    var xy: BigInt512 = sqr(a);
    var xy_hi: BaseField = get_higher_with_slack(xy);
    var l: BigInt512 = mul(xy_hi, BASE_M);
    var l_hi: BaseField = get_higher_with_slack(l);
    var lp: BigInt512 = mul(l_hi, BASE_MODULUS);
    var r_wide: BigInt512;
    sub_512(xy, lp, &r_wide);

    var r_wide_reduced: BigInt512;
    var underflow = sub_512(r_wide, BASE_MODULUS_WIDE, &r_wide_reduced);
    if (underflow == 0u) {
        r_wide = r_wide_reduced;
    }
    var r: BaseField;
    for (var i = 0u; i < N; i = i + 1u) {
        r.limbs[i] = r_wide.limbs[i];
    }
    return field_reduce(r);
}

/*
fn field_to_bits(a: BigInt256) -> array<bool, 256> {
  let res: array<bool, 256> = array();
  for (var i = 0u;i < N;i += 1) {
    for (var j = 0u;j < 32u;j += 1) {
      var bit = (a.limbs[i] >> j) & 1u;
      res[i * 32u + j] = bit == 1u;
    }
  }
  return res;
}
*/
