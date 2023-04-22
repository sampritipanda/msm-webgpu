struct JacobianPoint {
    x: BaseField,
    y: BaseField,
    z: BaseField
};

fn is_inf(p: JacobianPoint) -> bool {
    return field_eq(p.z, ZERO);
}

fn jacobian_double(p: JacobianPoint) -> JacobianPoint {
    // https://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#doubling-dbl-2009-l
    let A = field_mul(p.x, p.x);
    let B = field_mul(p.y, p.y);
    let C = field_mul(B, B);
    let X1plusB = field_add(p.x, B);
    let D = field_small_scalar_shift(1, field_sub(field_mul(X1plusB, X1plusB), field_add(A, C)));
    let E = field_add(field_small_scalar_shift(1, A), A);
    let F = field_mul(E, E);
    let x3 = field_sub(F, field_small_scalar_shift(1, D));
    let y3 = field_sub(field_mul(E, field_sub(D, x3)), field_small_scalar_shift(3, C));
    let z3 = field_mul(field_small_scalar_shift(1, p.y), p.z);
    return JacobianPoint(x3, y3, z3);
}

// double p and add q
// todo: can be optimized if one of the z coordinates is 1
// fn jacobian_dadd(p: JacobianPoint, q: JacobianPoint) -> JacobianPoint {
//     if (is_inf(p)) {
//         return q;
//     } else if (is_inf(q)) {
//         return jacobian_double(p);
//     }

//     let twox = field_small_scalar_shift(1, p.x);
//     let sqrx = field_mul(p.x, p.x);
//     let dblR = field_add(field_small_scalar_shift(1, sqrx), sqrx);
//     let dblH = field_small_scalar_shift(1, p.y);

//     let x3 = field_mul(q.z, q.z);
//     let z3 = field_mul(p.z, q.z);
//     let addH = field_mul(p.z, p.z);

// }

fn jacobian_add(p: JacobianPoint, q: JacobianPoint) -> JacobianPoint {
    if (field_eq(p.y, ZERO)) {
        return q;
    }
    if (field_eq(q.y, ZERO)) {
        return p;
    }

    let Z1Z1 = field_mul(p.z, p.z);
    let Z2Z2 = field_mul(q.z, q.z);
    let U1 = field_mul(p.x, Z1Z1);
    let U2 = field_mul(q.x, Z2Z2);
    let S1 = field_mul(p.y, field_mul(Z2Z2, q.z));
    let S2 = field_mul(q.y, field_mul(Z1Z1, p.z));
    if (field_eq(U1, U2)) {
        if (field_eq(S1, S2)) {
            return jacobian_double(p);
        } else {
            return JacobianPoint(ZERO, ZERO, ONE);
        }
    }

    let H = field_sub(U2, U1);
    let I = field_small_scalar_shift(2, field_mul(H, H));
    let J = field_mul(H, I);
    let R = field_small_scalar_shift(1, field_sub(S2, S1));
    let V = field_mul(U1, I);
    let nx = field_sub(field_mul(R, R), field_add(J, field_small_scalar_shift(1, V)));
    let ny = field_sub(field_mul(R, field_sub(V, nx)), field_small_scalar_shift(1, field_mul(S1, J)));
    let nz = field_mul(H, field_sub(field_pow(field_add(p.z, q.z), 2), field_add(Z1Z1, Z2Z2)));
    return JacobianPoint(nx, ny, nz);
}

fn jacobian_mul(p: JacobianPoint, k: ScalarField) -> JacobianPoint {
    var r: JacobianPoint = JacobianPoint(ZERO, ZERO, ONE);
    var t: JacobianPoint = p;
    for (var i = 0u; i < N; i = i + 1u) {
        var k_s = k.limbs[i];
        for (var j = 0u; j < W; j = j + 1u) {
            if ((k_s & 1) == 1u) {
                r = jacobian_add(r, t);
            }
            t = jacobian_double(t);
            k_s = k_s >> 1;
        }
    }
    return r;
}
