struct JacobianPoint {
    x: BaseField,
    y: BaseField,
    z: BaseField
};

fn jacobian_double(p: JacobianPoint) -> JacobianPoint {
    // https://www.hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#doubling-dbl-2009-l
    if (field_eq(p.y, ZERO)) {
        return JacobianPoint(ZERO, ZERO, ZERO);
    }

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

fn jacobian_add(p: JacobianPoint, q: JacobianPoint) -> JacobianPoint {
    if (field_eq(p.y, ZERO)) {
        return q;
    }
    if (field_eq(q.y, ZERO)) {
        return p;
    }

    let U1 = field_mul(p.x, field_pow(q.z, 2));
    let U2 = field_mul(q.x, field_pow(p.z, 2));
    let S1 = field_mul(p.y, field_pow(q.z, 3));
    let S2 = field_mul(q.y, field_pow(p.z, 3));
    if (field_eq(U1, U2)) {
        if (field_eq(S1, S2)) {
            return jacobian_double(p);
        } else {
            return JacobianPoint(ZERO, ZERO, ONE);
        }
    }

    let H = field_sub(U2, U1);
    let R = field_sub(S2, S1);
    let H2 = field_mul(H, H);
    let H3 = field_mul(H2, H);
    let U1H2 = field_mul(U1, H2);
    let nx = field_sub(field_sub(field_pow(R, 2), H3), field_small_scalar_mul(2, U1H2));
    let ny = field_sub(field_mul(R, field_sub(U1H2, nx)), field_mul(S1, H3));
    let nz = field_mul(field_mul(H, p.z), q.z);
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
